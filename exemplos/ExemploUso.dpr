program ExemploUso;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {FormMain};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Ghorvix Hub - Exemplo de Uso';
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
