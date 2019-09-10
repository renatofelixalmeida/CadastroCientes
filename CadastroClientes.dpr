program CadastroClientes;

uses
  Vcl.Forms,
  untPrincipal in 'untPrincipal.pas' {frmPrincipal},
  untConfiguracao in 'untConfiguracao.pas' {frmConfiguracao},
  untFuncoes in 'untFuncoes.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.CreateForm(TfrmConfiguracao, frmConfiguracao);
  Application.Run;
end.
