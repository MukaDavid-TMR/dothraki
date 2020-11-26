program DothrakiApp;

uses
  System.StartUpCopy,
  FMX.Forms,
  dothraki.frmPrincipal in 'dothraki.frmPrincipal.pas' {frmPrincipal},
  dothraki.obd2 in '..\dothraki.obd2.pas',
  dothraki.pids in '..\dothraki.pids.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.
