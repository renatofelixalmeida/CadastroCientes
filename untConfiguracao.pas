unit untConfiguracao;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, IniFiles, untPrincipal;

type
  TfrmConfiguracao = class(TForm)
    pnlFundo: TPanel;
    pnlControles: TPanel;
    pnlBotoes: TPanel;
    gpbConfiguracoes: TGroupBox;
    edtUsuario: TEdit;
    Label2: TLabel;
    Label1: TLabel;
    edtServidorSmtp: TEdit;
    edtSenha: TEdit;
    lblSenha: TLabel;
    lblPorta: TLabel;
    edtPorta: TEdit;
    btnGravar: TButton;
    btnCancelar: TButton;
    chkSSL: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure btnGravarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmConfiguracao: TfrmConfiguracao;

implementation

{$R *.dfm}

procedure TfrmConfiguracao.btnGravarClick(Sender: TObject);
var i : integer;
    ini : tIniFile;
begin
  // Gravar as configurações no arquivo ini
  ini := tIniFile.Create(arquivoConfiguracao);
  try;
    for i := 0 to ComponentCount - 1 do
    begin
      // buscar as configurações de texto
      if components[i].ClassType = tEdit then
      begin
        ini.WriteString('CONFIGURACAO', components[i].Name, tEdit(components[i]).Text);
      end;
      // buscar as configurações booleanas
      if components[i].ClassType = tCheckBox then
      begin
        ini.WriteBool('CONFIGURACAO', components[i].Name, tCheckBox(components[i]).Checked);
      end;
    end;
  finally
    ini.Free;
  end;
  // fechar configuração
  close;
end;

procedure TfrmConfiguracao.FormShow(Sender: TObject);
var i : integer;
    ini : tIniFile;
begin
  // Carregar as configurações do arquivo ini
  ini := tIniFile.Create(arquivoConfiguracao);
  try;
    for i := 0 to ComponentCount - 1 do
    begin
      // buscar as configurações de texto
      if components[i].ClassType = tEdit then
      begin
        tEdit(components[i]).Text := ini.ReadString('CONFIGURACAO', components[i].Name, '');
      end;
      // buscar as configurações booleanas
      if components[i].ClassType = tCheckBox then
      begin
        tCheckBox(components[i]).Checked := ini.ReadBool('CONFIGURACAO', components[i].Name, false);
      end;
    end;
  finally
    ini.Free;
  end;
end;

end.
