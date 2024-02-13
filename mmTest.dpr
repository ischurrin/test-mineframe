program mmTest;

uses
  Vcl.Forms,
  F_ImportMicroMine in 'src\F_ImportMicroMine.pas' {Form_ImportMicroMine},
  U_Tools in 'src\U_Tools.pas',
  U_MicroMineFile in 'src\U_MicroMineFile.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm_ImportMicroMine, Form_ImportMicroMine);
  Application.Run;
end.
