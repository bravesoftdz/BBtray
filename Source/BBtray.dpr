program BBtray;

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  Mesg in 'Mesg.pas' {frmMesg};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Big Brother Tray Notification';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TfrmMesg, frmMesg);
  Application.Run;
end.
