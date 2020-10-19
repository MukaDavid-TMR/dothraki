unit dothraki.obd2;

interface
uses
  System.Classes, System.Bluetooth.Components, System.Bluetooth,
  System.SysUtils, System.Variants, System.Math, dothraki.pids;

type
  TFluxoDados = (TfdEnvio, TfdRecebimento);

  TOnLogEvent = procedure(Sender: TObject; pFluxoDados: TFluxoDados;
    pDados: TArray<System.Byte>) of object;

  TOBD2Code = class
  const
    SERVICE_01 = '01';
    OBD2_UUID = '{00001101-0000-1000-8000-00805F9B34FB}';
    ENGINE_SPEED = '0C';
    AMBIENT_AIR_TEMPERATURE = '46';
    ODOMETER = 'A6';
    ACCELERATOR_PEDAL_POSITION_E = '4A';
    P_COMBUSTIVEL = '23';
    TIPO_COMBUSTIVEL = '51';
    COMBUSTIVEL = '5E';
    FUEL_TANK = '2F';
    DISTANCE_PERC = '31';
    ENGINE_COOLANT_TEMP = '05';

    PIDS_SUPPORTED_01_20 = '00';
    PIDS_SUPPORTED_21_40 = '20';
    PIDS_SUPPORTED_11_60 = '40';
    PIDS_SUPPORTED_61_80 = '80';
  end;

  TOBD2Data = record
    NoData: boolean;
    A: integer;
    B: integer;
    C: integer;
    D: integer;
    Tamanho: integer;
  end;

  TOBD2 = class(TComponent)
  private
    FBluetooth: TBluetooth;
    FSocket: TBluetoothSocket;
    FOnConnect: TNotifyEvent;
    FOnLogEvent: TOnLogEvent;
    FSendDelay: integer;
    FPids: TObd2Pids;
    function ConvertToObd2Code(pObd2Code: string):TArray<System.Byte>;
    procedure EnviarDados(pObd2Code: string);
    function ReceberDados:TArray<System.Byte>;
    function ConsultarDados(pObd2Code: string):TOBD2Data;
    function BytesToOBD2Data(pDados: TArray<System.Byte>): TOBD2Data;
    function ExecutarComando(pObd2Code: string): boolean;
    function RetornoOk(pDados: TArray<System.Byte>): Boolean;
    procedure ConfigurarPidsAtivos(pDados: TArray<System.Byte>);
    function IntToBinByte(Value: Byte): string;
    function GetPids(index: string): TPidService;
  protected
    destructor Destroy; override;
  public
    constructor Create(AOwner: TComponent); override;
    function Conectado: Boolean;
    procedure Conectar(pDeviceName: String);
    procedure Desconectar;
    function EngineSpeed: Double;
    function AmbientAirTemperature: Double;
    function Odometer: Double;
    function AcceleratorPedalPositionE: Double;
    function DISTANCE_PERC: Double;
    function ENGINE_COOLANT_TEMP: Double;
    procedure VerificarPidsHabilitados;
    property OnConnect: TNotifyEvent read FOnConnect write FOnConnect;
    property OnLogEvent: TOnLogEvent read FOnLogEvent write FOnLogEvent;
    property SendDelay: Integer read FSendDelay write FSendDelay;
    property Pids[index: string]: TPidService read GetPids;

  end;



implementation


function TOBD2.DISTANCE_PERC: Double;
begin
  if not Conectado then
    Exit(0);

  var lOBD2Data := ConsultarDados(TOBD2Code.DISTANCE_PERC);

  if not lOBD2Data.NoData then
  begin
    Result := ((lOBD2Data.A * 256) + lOBD2Data.B);
  end;
end;

function TOBD2.EngineSpeed: Double;
begin
  if not Conectado then
    Exit(0);

  var lOBD2Data := ConsultarDados(TOBD2Code.ENGINE_SPEED);

  if not lOBD2Data.NoData then
  begin
    Result := ((lOBD2Data.A * 256) + lOBD2Data.B)/4;
  end;
end;

function TOBD2.ENGINE_COOLANT_TEMP: Double;
begin
  if not Conectado then
    Exit(0);

  var lOBD2Data := ConsultarDados(TOBD2Code.ENGINE_COOLANT_TEMP);

  if not lOBD2Data.NoData then
  begin
    Result := (lOBD2Data.A - 40);
  end;
end;


function TOBD2.Odometer: Double;
begin
  if not Conectado then
    Exit(0);

  var lOBD2Data := ConsultarDados(TOBD2Code.ODOMETER);

  if not lOBD2Data.NoData then
  begin
    Result :=
          ((lOBD2Data.A*power(2,24))+
          (lOBD2Data.B*power(2,16))+
          (lOBD2Data.C*power(2,8))+
          (lOBD2Data.D))/10;
  end;
end;

function TOBD2.AcceleratorPedalPositionE: Double;
begin
  if not Conectado then
    Exit(0);

  var lOBD2Data := ConsultarDados(TOBD2Code.ACCELERATOR_PEDAL_POSITION_E);

  if not lOBD2Data.NoData then
  begin
    Result := (100/255)*lOBD2Data.A;
  end;

end;

function TOBD2.AmbientAirTemperature: Double;
begin
  if not Conectado then
    Exit(0);

  var lOBD2Data := ConsultarDados(TOBD2Code.AMBIENT_AIR_TEMPERATURE);

  if not lOBD2Data.NoData then
  begin
    Result := (lOBD2Data.A-40);
  end;
end;

procedure TOBD2.VerificarPidsHabilitados;
begin
  EnviarDados(TOBD2Code.PIDS_SUPPORTED_01_20);
  ConfigurarPidsAtivos(ReceberDados);

  if Pids[TOBD2Code.PIDS_SUPPORTED_21_40].Enable then
  begin
    EnviarDados(TOBD2Code.PIDS_SUPPORTED_21_40);
    ConfigurarPidsAtivos(ReceberDados);
  end;

  if Pids[TOBD2Code.PIDS_SUPPORTED_11_60].Enable then
  begin
    EnviarDados(TOBD2Code.PIDS_SUPPORTED_11_60);
    ConfigurarPidsAtivos(ReceberDados);
  end;

  if Pids[TOBD2Code.PIDS_SUPPORTED_61_80].Enable then
  begin
    EnviarDados(TOBD2Code.PIDS_SUPPORTED_61_80);
    ConfigurarPidsAtivos(ReceberDados);
  end;
end;


function TOBD2.Conectado: Boolean;
begin
  result := (FSocket <> nil) and (FSocket.Connected);
end;

function TOBD2.ConvertToObd2Code(pObd2Code: string): TArray<System.Byte>;
var
  lTam: Integer;
begin
  lTam := Length(pObd2Code);
  SetLength(Result, lTam+1);

  for var li:= 0 to lTam-1 do
     Result[li] := Ord(pObd2Code[li+1]);

  Result[lTam] := 13;
end;

constructor TOBD2.Create(AOwner: TComponent);
begin
  FBluetooth := TBluetooth.Create(Self);
  FBluetooth.Enabled := True;
  FSendDelay := 200;
  FPids := TObd2Pids.Create;
end;

procedure TOBD2.Desconectar;
begin
  FSocket.Close;
  FreeAndNil(FSocket);
end;

destructor TOBD2.Destroy;
begin
  FSocket.Free;
  FPids.Free;
  inherited;
end;

procedure TOBD2.EnviarDados(pObd2Code: string);
var
  lDadosEnviados: TArray<System.Byte>;
begin
  lDadosEnviados := ConvertToObd2Code(TOBD2Code.SERVICE_01+pObd2Code);
  if Assigned(OnLogEvent) then
    FOnLogEvent(Self,TFluxoDados.TfdEnvio,lDadosEnviados);
  FSocket.SendData(lDadosEnviados);
  Sleep(FSendDelay);
end;

function TOBD2.BytesToOBD2Data(pDados:TArray<System.Byte>):TOBD2Data;
var
  lDados: string;
  lRetorno: TStringList;

begin
  Result.NoData := True;
  Delete(pDados,Length(lDados)-3,Length(lDados));
  lRetorno := TStringList.Create;
  try
    lRetorno.Text := TEncoding.ASCII.GetString(pDados);
    lDados := lRetorno[0];

    if pos('NO DATA',lDados) <> 0 then
    begin
      Exit;
    end;

    if pos('NO DATA',lDados) = 0 then
    begin
      Result.NoData := False;
      if Length(lDados)>=6 then
        Result.A := StrToInt('$'+lDados[5]+lDados[6]);
      if Length(lDados)>=8 then
        Result.B := StrToInt('$'+lDados[7]+lDados[8]);
      if Length(lDados)>=10 then
        Result.C := StrToInt('$'+lDados[9]+lDados[10]);
      if Length(lDados)>=12 then
        Result.D := StrToInt('$'+lDados[10]+lDados[12]);

      Result.Tamanho := (Length(lDados) div 2) - 2;
    end;
  finally
    lRetorno.Free;
  end;
end;


function TOBD2.IntToBinByte(Value: Byte): string;
var
  i: Integer;
begin
  SetLength(Result, 4);
  for i := 1 to 4 do begin
    if (Value shr (4-i)) and 1 = 0 then begin
      Result[i] := '0'
    end else begin
      Result[i] := '1';
    end;
  end;
end;

{
procedure TOBD2.Button1Click;
var
  lValor: byte;
  lCodigo, lResultado: string;
  li: integer;
begin
  lCodigo := edtTexto.Text;
  lResultado := '';
  for li := 1 to Length(lCodigo) do
  begin
    if trim(lCodigo[li]) <> '' then
    begin
      lValor:= StrToInt('$'+lCodigo[li]);
      lResultado := lResultado+IntToBinByte(lValor);
    end;
  end;

  for li := 1 to Length(lResultado) do
  begin
    if lResultado[li] = '1' then
      Memo1.Lines.Add(IntToHex(li,2)+':'+lResultado[li]);
  end;
end;
}

procedure TOBD2.ConfigurarPidsAtivos(pDados:TArray<System.Byte>);
var
  lResultado, lDados: string;
  lRetorno: TStringList;
  lGrupo: Integer;

begin
  Delete(pDados,Length(lDados)-3,Length(lDados));
  lRetorno := TStringList.Create;
  try
    lRetorno.Text := TEncoding.ASCII.GetString(pDados);
    lDados := lRetorno[0];

    if pos('NO DATA',lDados) <> 0 then
    begin
      Exit;
    end;

    if pos('NO DATA',lDados) = 0 then
    begin
      lGrupo := StrToInt('$'+lDados[3]+lDados[4]);

      for var lx := 0 to 7 do
      begin
        lResultado := IntToBinByte(StrToInt('$'+lDados[5+lx]));
        for var li := 1 to Length(lResultado) do
        begin
          var lKey := lGrupo+(4*lx)+li;
          if FPids.List.ContainsKey(lKey) then
            FPids.List.Items[lKey].Enable := (lResultado[li] = '1');
        end;
      end;
    end;
  finally
    lRetorno.Free;
  end;
end;


function TOBD2.RetornoOk(pDados:TArray<System.Byte>):Boolean;
var
  lDados: string;
  lRetorno: TStringList;
begin
  Result := True;
  Delete(pDados,Length(lDados)-3,Length(lDados));
  lRetorno := TStringList.Create;
  try
    lRetorno.Text := TEncoding.ASCII.GetString(pDados);
    lDados := lRetorno[0];

    Result := pos('OK',lDados) <> 0;
  finally
    lRetorno.Free;
  end;
end;

function TOBD2.ReceberDados: TArray<System.Byte>;
var
  lRetorno: TStringList;
begin
  Result := FSocket.ReceiveData;
  lRetorno := TStringList.Create;
  try
    lRetorno.Text := TEncoding.ANSI.GetString(Result);
    if Assigned(OnLogEvent) then
      FOnLogEvent(Self,TFluxoDados.TfdRecebimento,Result);
  finally
    lRetorno.Free;
  end;
end;

procedure TOBD2.Conectar(pDeviceName: String);
var
  lDevice: TBluetoothDevice;
begin
  if Conectado then
    exit;

  for lDevice in FBluetooth.PairedDevices do
  begin
    if lDevice.DeviceName = pDeviceName then
    begin
      FreeAndNil(FSocket);
      FSocket := lDevice.CreateClientSocket(StringToGUID(TOBD2Code.OBD2_UUID),True);
      if FSocket <> nil then
      begin
        FSocket.Connect;
        EnviarDados('ATH0');
        ReceberDados;
        EnviarDados('ATSO');
        ReceberDados;
        if (Assigned(FOnConnect)) then
          FOnConnect(self);
      end;
    end;
  end;
end;

function TOBD2.ConsultarDados(pObd2Code: string): TOBD2Data;
begin
  if not Conectado then
    raise Exception.Create('Sem conexão com o OBD2');

  EnviarDados(pObd2Code);
  var lDadosRecebidos := ReceberDados;
  result := BytesToOBD2Data(lDadosRecebidos);
end;

function TOBD2.ExecutarComando(pObd2Code: string): boolean;
begin
  if not Conectado then
    raise Exception.Create('Sem conexão com o OBD2');

  EnviarDados(pObd2Code);
  var lDadosRecebidos := ReceberDados;
  result := RetornoOk(lDadosRecebidos);
end;


function TOBD2.GetPids(index: string): TPidService;
begin
  var lKey := StrToInt('$'+index);
  if FPids.List.ContainsKey(lKey) then
    Result := FPids.List.Items[lKey];
end;

end.
