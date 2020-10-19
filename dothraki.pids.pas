unit dothraki.pids;

interface
uses System.Generics.Collections, System.SysUtils;

type
  TPidService = class
  private
    FCode: string;
    FBytesCount: Integer;
    FDescricao: string;
    FEnable: Boolean;
  public
    property Descricao: string read FDescricao;
    property BytesCount: Integer read FBytesCount;
    property Code: string read FCode;
    property Enable: Boolean read FEnable write FEnable;
  end;

  TObd2Pids = class
  private
    FList: TObjectDictionary<Integer,TPidService>;
    procedure AddPid(pCode: String; pBytesCount: integer; pDescricao: string);
    procedure CarregarPids;
  public
    constructor Create;
    destructor Destroy; override;
    property List: TObjectDictionary<Integer,TPidService> read FList write FList;
  end;


implementation

{ TObd2Pids }

procedure TObd2Pids.AddPid(pCode: String; pBytesCount: integer;
  pDescricao: string);
var
  lPidService: TPidService;
begin
  lPidService := TPidService.Create;
  lPidService.FCode := pCode;
  lPidService.FBytesCount := pBytesCount;
  lPidService.FDescricao  := pDescricao;
  lPidService.Enable := True;
  FList.Add(StrToInt('$'+pCode),lPidService);
end;

procedure TObd2Pids.CarregarPids;
begin
  AddPid('00',4,'PIDs supported [01 - 20]');
  AddPid('01',4,'Monitor status since DTCs cleared.');
  AddPid('02',2,'Freeze DTC');
  AddPid('03',2,'Fuel system status');
  AddPid('04',1,'Calculated engine load');
  AddPid('05',1,'Engine coolant temperature');
  AddPid('06',1,'Short term fuel trim—Bank 1');
  AddPid('07',1,'Long term fuel trim—Bank 1');
  AddPid('08',1,'Short term fuel trim—Bank 2');
  AddPid('09',1,'Long term fuel trim—Bank 2');
  AddPid('0A',1,'Fuel pressure');
  AddPid('0B',1,'Intake manifold absolute pressure');
  AddPid('0C',2,'Engine speed');
  AddPid('0D',1,'Vehicle speed');
  AddPid('0E',1,'Timing advance');
  AddPid('0F',1,'Intake air temperature');
  AddPid('10',2,'Mass air flow sensor');
  AddPid('11',1,'Throttle position');
  AddPid('12',1,'Commanded secondary air status');
  AddPid('13',1,'Oxygen sensors present (in 2 banks)');
  AddPid('14',2,'Oxygen Sensor 1');
  AddPid('15',2,'Oxygen Sensor 2');
  AddPid('16',2,'Oxygen Sensor 3');
  AddPid('17',2,'Oxygen Sensor 4');
  AddPid('18',2,'Oxygen Sensor 5');
  AddPid('19',2,'Oxygen Sensor 6');
  AddPid('1A',2,'Oxygen Sensor 7');
  AddPid('1B',2,'Oxygen Sensor 8');
  AddPid('1C',1,'OBD standards this vehicle conforms to');
  AddPid('1D',1,'Oxygen sensors present (in 4 banks)');
  AddPid('1E',1,'Auxiliary input status');
  AddPid('1F',2,'Run time since engine start');
  AddPid('20',4,'PIDs supported [21 - 40]');
  AddPid('21',2,'Distance traveled with malfunction indicator lamp (MIL) on');
  AddPid('22',2,'Fuel Rail Pressure (relative to manifold vacuum)');
  AddPid('23',2,'Fuel Rail Gauge Pressure (diesel, or gasoline direct injection)');
  AddPid('24',4,'Oxygen Sensor 1');
  AddPid('25',4,'Oxygen Sensor 2');
  AddPid('26',4,'Oxygen Sensor 3');
  AddPid('27',4,'Oxygen Sensor 4');
  AddPid('28',4,'Oxygen Sensor 5');
  AddPid('29',4,'Oxygen Sensor 6');
  AddPid('2A',4,'Oxygen Sensor 7');
  AddPid('2B',4,'Oxygen Sensor 8');
  AddPid('2C',1,'Commanded EGR');
  AddPid('2D',1,'EGR Error');
  AddPid('2E',1,'Commanded evaporative purge');
  AddPid('2F',1,'Fuel Tank Level Input');
  AddPid('30',1,'Warm-ups since codes cleared');
  AddPid('31',2,'Distance traveled since codes cleared');
  AddPid('32',2,'Evap. System Vapor Pressure');
  AddPid('33',1,'Absolute Barometric Pressure');
  AddPid('34',4,'Oxygen Sensor 1');
  AddPid('35',4,'Oxygen Sensor 2');
  AddPid('36',4,'Oxygen Sensor 3');
  AddPid('37',4,'Oxygen Sensor 4');
  AddPid('38',4,'Oxygen Sensor 5');
  AddPid('39',4,'Oxygen Sensor 6');
  AddPid('3A',4,'Oxygen Sensor 7');
  AddPid('3B',4,'Oxygen Sensor 8');
  AddPid('3C',2,'Catalyst Temperature: Bank 1, Sensor 1');
  AddPid('3D',2,'Catalyst Temperature: Bank 2, Sensor 1');
  AddPid('3E',2,'Catalyst Temperature: Bank 1, Sensor 2');
  AddPid('3F',2,'Catalyst Temperature: Bank 2, Sensor 2');
  AddPid('40',4,'PIDs supported [41 - 60]');
  AddPid('41',4,'Monitor status this drive cycle');
  AddPid('42',2,'Control module voltage');
  AddPid('43',2,'Absolute load value');
  AddPid('44',2,'Fuel–Air commanded equivalence ratio');
  AddPid('45',1,'Relative throttle position');
  AddPid('46',1,'Ambient air temperature');
  AddPid('47',1,'Absolute throttle position B');
  AddPid('48',1,'Absolute throttle position C');
  AddPid('49',1,'Accelerator pedal position D');
  AddPid('4A',1,'Accelerator pedal position E');
  AddPid('4B',1,'Accelerator pedal position F');
  AddPid('4C',1,'Commanded throttle actuator');
  AddPid('4D',2,'Time run with MIL on');
  AddPid('4E',2,'Time since trouble codes cleared');
  AddPid('4F',4,'Maximum value for Fuel–Air equivalence ratio, oxygen sensor voltage, oxygen sensor current, and intake manifold absolute pressure');
  AddPid('50',4,'Maximum value for air flow rate from mass air flow sensor');
  AddPid('51',1,'Fuel Type');
  AddPid('52',1,'Ethanol fuel %');
  AddPid('53',2,'Absolute Evap system Vapor Pressure');
  AddPid('54',2,'Evap system vapor pressure');
  AddPid('55',2,'Short term secondary oxygen sensor trim, A: bank 1, B: bank 3');
  AddPid('56',2,'Long term secondary oxygen sensor trim, A: bank 1, B: bank 3');
  AddPid('57',2,'Short term secondary oxygen sensor trim, A: bank 2, B: bank 4');
  AddPid('58',2,'Long term secondary oxygen sensor trim, A: bank 2, B: bank 4');
  AddPid('59',2,'Fuel rail absolute pressure');
  AddPid('5A',1,'Relative accelerator pedal position');
  AddPid('5B',1,'Hybrid battery pack remaining life');
  AddPid('5C',1,'Engine oil temperature');
  AddPid('5D',2,'Fuel injection timing');
  AddPid('5E',2,'Engine fuel rate');
  AddPid('5F',1,'Emission requirements to which vehicle is designed');
  AddPid('60',4,'PIDs supported [61 - 80]');
  AddPid('61',1,'Driverʼs demand engine - percent torque5');
  AddPid('62',1,'Actual engine - percent torque');
  AddPid('63',2,'Engine reference torque');
  AddPid('64',5,'Engine percent torque data');
  AddPid('65',2,'Auxiliary input / output supported');
  AddPid('66',5,'Mass air flow sensor');
  AddPid('67',3,'Engine coolant temperature');
  AddPid('68',7,'Intake air temperature sensor');
  AddPid('69',7,'Commanded EGR and EGR Error');
  AddPid('6A',5,'Commanded Diesel intake air flow control and relative intake air flow position');
  AddPid('6B',5,'Exhaust gas recirculation temperature');
  AddPid('6C',5,'Commanded throttle actuator control and relative throttle position');
  AddPid('6D',6,'Fuel pressure control system');
  AddPid('6E',5,'Injection pressure control system');
  AddPid('6F',3,'Turbocharger compressor inlet pressure');
  AddPid('70',9,'Boost pressure control');
  AddPid('71',5,'Variable Geometry turbo (VGT) control');
  AddPid('72',5,'Wastegate control');
  AddPid('73',5,'Exhaust pressure');
  AddPid('74',5,'Turbocharger RPM');
  AddPid('75',7,'Turbocharger temperature');
  AddPid('76',7,'Turbocharger temperature');
  AddPid('77',5,'Charge air cooler temperature (CACT)');
  AddPid('78',9,'Exhaust Gas temperature (EGT) Bank 1');
  AddPid('79',9,'Exhaust Gas temperature (EGT) Bank 2');
  AddPid('7A',7,'Diesel particulate filter (DPF)');
  AddPid('7B',7,'Diesel particulate filter (DPF)');
  AddPid('7C',9,'Diesel Particulate filter (DPF) temperature');
  AddPid('7D',1,'NOx NTE (Not-To-Exceed) control area status');
  AddPid('7E',1,'PM NTE (Not-To-Exceed) control area status');
  AddPid('7F',13,'Engine run time');
  AddPid('80',4,'PIDs supported [81 - A0]');
  AddPid('81',21,'Engine run time for Auxiliary Emissions Control Device(AECD)');
  AddPid('82',21,'Engine run time for Auxiliary Emissions Control Device(AECD)');
  AddPid('83',5,'NOx sensor');
  AddPid('84',1,'Manifold surface temperature');
  AddPid('85',10,'NOx reagent system');
  AddPid('86',5,'Particulate matter (PM) sensor');
  AddPid('87',5,'Intake manifold absolute pressure');
  AddPid('88',13,'SCR Induce System');
  AddPid('89',41,'Run Time for AECD #11-#15');
  AddPid('8A',41,'Run Time for AECD #16-#20');
  AddPid('8B',7,'Diesel Aftertreatment');
  AddPid('8C',16,'O2 Sensor (Wide Range)');
  AddPid('8D',1,'Throttle Position G');
  AddPid('8E',1,'Engine Friction - Percent Torque');
  AddPid('8F',5,'PM Sensor Bank 1 & 2');
  AddPid('90',3,'WWH-OBD Vehicle OBD System Information');
  AddPid('91',5,'WWH-OBD Vehicle OBD System Information');
  AddPid('92',2,'Fuel System Control');
  AddPid('93',3,'WWH-OBD Vehicle OBD Counters support');
  AddPid('94',12,'NOx Warning And Inducement System');
  AddPid('98',9,'Exhaust Gas Temperature Sensor');
  AddPid('99',9,'Exhaust Gas Temperature Sensor');
  AddPid('9A',6,'Hybrid/EV Vehicle System Data, Battery, Voltage');
  AddPid('9B',4,'Diesel Exhaust Fluid Sensor Data');
  AddPid('9C',17,'O2 Sensor Data');
  AddPid('9D',4,'Engine Fuel Rate');
  AddPid('9E',2,'Engine Exhaust Flow Rate');
  AddPid('9F',9,'Fuel System Percentage Use');
  AddPid('A0',4,'PIDs supported [A1 - C0]');
  AddPid('A1',9,'NOx Sensor Corrected Data');
  AddPid('A2',2,'Cylinder Fuel Rate');
  AddPid('A3',9,'Evap System Vapor Pressure');
  AddPid('A4',4,'Transmission Actual Gear');
  AddPid('A5',4,'Diesel Exhaust Fluid Dosing');
  AddPid('A6',4,'Odometer');
  AddPid('C0',4,'PIDs supported [C1 - E0]');
  AddPid('C3',0,'Other date (Drive Condition ID, Engine Speed...)');
  AddPid('C4',0,'Engine Idle Request and Engine Stop Request');
end;

constructor TObd2Pids.Create;
begin
  FList := TObjectDictionary<Integer,TPidService>.Create([doOwnsValues]);
  CarregarPids;
end;

destructor TObd2Pids.Destroy;
begin
  FList.Free;
  inherited;
end;

end.
