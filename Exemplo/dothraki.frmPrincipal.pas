unit dothraki.frmPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMXTee.Series,
  FMXTee.Engine, FMXTee.Procs, FMXTee.Chart, FMX.Objects, FMX.StdCtrls,
  FMX.ListBox, FMX.Controls.Presentation, FMX.Layouts, FMX.TabControl,
  System.Bluetooth, System.Bluetooth.Components, dothraki.obd2, FMX.Memo.Types,
  FMX.ScrollBox, FMX.Memo;

type
  TfrmPrincipal = class(TForm)
    TabControl1: TTabControl;
    TabConexao: TTabItem;
    Layout4: TLayout;
    btnListarDispositivos: TButton;
    cbxDevice: TComboBox;
    Layout5: TLayout;
    lblConectado: TLabel;
    btnConectar: TButton;
    TabGraficos: TTabItem;
    Rectangle1: TRectangle;
    Layout1: TLayout;
    Layout3: TLayout;
    Image1: TImage;
    imgPonteiro: TImage;
    lblTemperatura: TLabel;
    Label4: TLabel;
    Chart3: TChart;
    Series1: TPieSeries;
    lblAbertura: TLabel;
    Rectangle2: TRectangle;
    Layout2: TLayout;
    Chart1: TChart;
    SeriesRpm: TAreaSeries;
    Chart2: TChart;
    SeriesSpeed: TAreaSeries;
    Label1: TLabel;
    Label3: TLabel;
    Bluetooth1: TBluetooth;
    lbxPidSuportados: TListBox;
    btnPidsSuportados: TButton;
    Timer1: TTimer;
    TabControl2: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    Memo1: TMemo;
    Button1: TButton;
    procedure btnListarDispositivosClick(Sender: TObject);
    procedure btnConectarClick(Sender: TObject);
    procedure btnPidsSuportadosClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FOBD2: TOBD2;
    procedure OnConectado(Sender: TObject);
    procedure AdicionarValorNaSerie(pSerie: TCustomSeries; pValor: Double);
    procedure AjustarBorboleta(Percentual: Double);
    procedure AjustarPonteiro(pTemperatura: Double);
    procedure IniciarSeriesChart;
  public
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.fmx}

procedure TfrmPrincipal.IniciarSeriesChart;
begin
  //Series1.YValue[li-1] := Series1.YValue[li];
  for var li := 0 to 29 do
  begin
    SeriesRpm.Add(0);
    SeriesSpeed.Add(0);
  end;

  Series1.Add(0,'',$FF404040);
  Series1.Add(100,'',$FFFA0B8C);

end;


procedure TfrmPrincipal.btnConectarClick(Sender: TObject);
begin
  if FOBD2 = nil then
    FOBD2 := TOBD2.Create(self);

  FOBD2.OnConnect := OnConectado;
  FOBD2.Conectar(cbxDevice.Selected.Text);
end;

procedure TfrmPrincipal.btnListarDispositivosClick(Sender: TObject);
begin
  cbxDevice.Clear;
  for var lDevice in Bluetooth1.PairedDevices do
  begin
    cbxDevice.Items.Add(lDevice.DeviceName);
  end;
end;

procedure TfrmPrincipal.btnPidsSuportadosClick(Sender: TObject);
begin
  FOBD2.VerificarPidsHabilitados;

  lbxPidSuportados.Clear;
  for var lPidService in FOBD2.PidList.Values do
  begin
    if lPidService.Enable then
      lbxPidSuportados.Items.Add(lPidService.Descricao);
  end;
end;

procedure TfrmPrincipal.Button1Click(Sender: TObject);
begin
  Memo1.Lines.Add('Aceleração: '+FormatFloat('0.,00',FOBD2.EngineSpeed)+' rpm');
  Memo1.Lines.Add('Velocidade: '+FormatFloat('0.,00',FOBD2.Velocidade)+' km/h');
  Memo1.Lines.Add('Temperatura do Motor: '+FormatFloat('0.,00',FOBD2.TemperaturaMotor)+ ' °C');
  Memo1.Lines.Add('Abertura da Borboleta: '+FormatFloat('0.,00',FOBD2.AberturaBorboleta)+ ' %');
  Memo1.Lines.Add('Nível de Combustível: '+FormatFloat('0.,00',FOBD2.NivelCombustivel)+ ' %');
  Memo1.Lines.Add('DISTANCE_PERC: '+FormatFloat('0.,00',FOBD2.DISTANCE_PERC));
  Memo1.Lines.Add('-----------------------');
  Memo1.Lines.Add('');
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  IniciarSeriesChart;
end;

procedure TfrmPrincipal.FormDestroy(Sender: TObject);
begin
  FOBD2.Free;
end;

procedure TfrmPrincipal.OnConectado(Sender: TObject);
begin
  if FOBD2.Conectado then
    lblConectado.Text := 'Conectado'
  else
    lblConectado.Text := 'Desconectado';
end;


procedure TfrmPrincipal.AdicionarValorNaSerie(pSerie: TCustomSeries; pValor: Double);
begin

  var lPosAtual := pSerie.YValues.Count - 1;
  for var li := 0 to lPosAtual - 1 do
  begin
    pSerie.YValue[li] := pSerie.YValue[li+1];
  end;

  pSerie.YValue[lPosAtual] := pValor;
end;

procedure TfrmPrincipal.AjustarBorboleta(Percentual: Double);
begin
  Series1.YValue[1] := Percentual;
  Series1.YValue[0] := 100 - Percentual;
  lblAbertura.Text := FormatFloat('0',Percentual)+'%';
end;

procedure TfrmPrincipal.AjustarPonteiro(pTemperatura: Double);
var
  lAngulo: Double;
begin
  if (pTemperatura - 77) < -35 then
    lAngulo := -35
  else if (pTemperatura - 77) > 45 then
    lAngulo := 45
  else
    lAngulo := pTemperatura - 77;

  imgPonteiro.RotationAngle := lAngulo;
  lblTemperatura.Text := FormatFloat('00.0',pTemperatura)+'ºC';
end;


procedure TfrmPrincipal.Timer1Timer(Sender: TObject);
begin
  if (FOBD2 <> nil) and (FOBD2.Conectado) then
  begin
    AdicionarValorNaSerie(SeriesRpm,FOBD2.EngineSpeed);
    AdicionarValorNaSerie(SeriesSpeed,FOBD2.Velocidade);
    AjustarPonteiro(FOBD2.TemperaturaMotor);
    AjustarBorboleta(FOBD2.AberturaBorboleta);
  end;
end;


end.

