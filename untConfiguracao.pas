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
    lblUsuario: TLabel;
    lblServidor: TLabel;
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
    IniFile : tIniFile;
begin
  // Gravar as configurações no arquivo ini
  IniFile := tIniFile.Create(arquivoConfiguracao);
  try;
    for i := 0 to ComponentCount - 1 do
    begin
      // Gravar as configurações de campos de texto
      if components[i].ClassType = tEdit then
      begin
        IniFile.WriteString('CONFIGURACAO', components[i].Name, tEdit(components[i]).Text);
      end;
      // Gravar as configurações de campos booleanos
      if components[i].ClassType = tCheckBox then
      begin
        IniFile.WriteBool('CONFIGURACAO', components[i].Name, tCheckBox(components[i]).Checked);
      end;
    end;
  finally
    freeAndNil(IniFile);
  end;
  // fechar configuração
  close;
end;

procedure TfrmConfiguracao.FormShow(Sender: TObject);
var i : integer;
    IniFile : tIniFile;
begin
  // Carregar as configurações do arquivo ini
  IniFile := tIniFile.Create(arquivoConfiguracao);
  try;
    for i := 0 to ComponentCount - 1 do
    begin
      // buscar as configurações de texto
      if components[i].ClassType = tEdit then
      begin
        tEdit(components[i]).Text := IniFile.ReadString('CONFIGURACAO', components[i].Name, tEdit(components[i]).Hint);
      end;
      // buscar as configurações booleanas
      if components[i].ClassType = tCheckBox then
      begin
        tCheckBox(components[i]).Checked := IniFile.ReadBool('CONFIGURACAO', components[i].Name, false);
      end;
    end;
  finally
    freeAndNil(IniFile);
  end;
end;

end.
