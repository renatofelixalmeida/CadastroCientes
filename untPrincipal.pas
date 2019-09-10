unit untPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.StdCtrls, Vcl.DBCtrls,
  Vcl.Mask, Vcl.ExtCtrls, Data.DB, Datasnap.DBClient, Json, IniFiles;

type
  TfrmPrincipal = class(TForm)
    mnuPrincipal: TMainMenu;
    mnuArquivo: TMenuItem;
    mnuConfiguracoes: TMenuItem;
    mnuSeparador1: TMenuItem;
    mnuSair: TMenuItem;
    pnlFundo: TPanel;
    pnlCabecalho: TPanel;
    lblDescricao: TLabel;
    pnlDadosCadastrais: TPanel;
    gpbDadosCadastrais: TGroupBox;
    lblNome: TLabel;
    lblIdentidade: TLabel;
    lblCpf: TLabel;
    lblTelefone: TLabel;
    lblEmail: TLabel;
    dbeNome: TDBEdit;
    dbeIdentidade: TDBEdit;
    dbeCpf: TDBEdit;
    dbeTelefone: TDBEdit;
    dbeEmail: TDBEdit;
    pnlEndereco: TPanel;
    gpbEndereco: TGroupBox;
    lblCep: TLabel;
    lblNumero: TLabel;
    lblComplemento: TLabel;
    lblBairro: TLabel;
    lblLogradouro: TLabel;
    lblCidade: TLabel;
    Label1: TLabel;
    lblPais: TLabel;
    dbeCep: TDBEdit;
    dbeNumero: TDBEdit;
    dbeComplemento: TDBEdit;
    dbeBairro: TDBEdit;
    dbeLogradouro: TDBEdit;
    dbeCidade: TDBEdit;
    dbcEstado: TDBComboBox;
    dbePais: TDBEdit;
    pnlControles: TPanel;
    btnNovoCadastro: TButton;
    btnGravarCadastro: TButton;
    btnCancelarCadastro: TButton;
    btnFechar: TButton;
    dtsCliente: TDataSource;
    cdsCliente: TClientDataSet;
    cdsClienteNOME: TStringField;
    cdsClienteIDENTIDADE: TStringField;
    cdsClienteCPF: TStringField;
    cdsClienteTELEFONE: TStringField;
    cdsClienteEMAIL: TStringField;
    cdsClienteCEP: TStringField;
    cdsClienteLOGRADOURO: TStringField;
    cdsClienteNUMERO: TStringField;
    cdsClienteCOMPLEMENTO: TStringField;
    cdsClienteBAIRRO: TStringField;
    cdsClienteCIDADE: TStringField;
    cdsClienteESTADO: TStringField;
    cdsClientePAIS: TStringField;
    procedure mnuConfiguracoesClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure mnuSairClick(Sender: TObject);
    procedure dtsClienteStateChange(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCancelarCadastroClick(Sender: TObject);
    procedure btnGravarCadastroClick(Sender: TObject);
    procedure dbeCpfExit(Sender: TObject);
    procedure dbeCepExit(Sender: TObject);
    procedure btnNovoCadastroClick(Sender: TObject);
    procedure cdsClienteNewRecord(DataSet: TDataSet);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;
  arquivoConfiguracao : string;
  arquivoDados : string;
  arquivoXml : string;
const
  NOME_ARQUIVO_CONFIGURACAO = 'config.ini';
  NOME_ARQUIVO_DADOS = 'cadastro.cds';
  NOME_ARQUIVO_XML = 'documento.xml';
implementation

{$R *.dfm}

uses untConfiguracao, untFuncoes;

procedure TfrmPrincipal.btnCancelarCadastroClick(Sender: TObject);
begin
  // confirmar o cancelamento do cadastro
  if MessageDlg('Deseja cancelar o cadastro em andamento?',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes
    then  cdsCliente.Cancel
end;

procedure TfrmPrincipal.btnFecharClick(Sender: TObject);
begin
  // tenta sair do sistema mas pode ser impedido pelo evento on close que ir�
  // checar se existe alguma altera��o pendente
  close;
end;

procedure TfrmPrincipal.btnGravarCadastroClick(Sender: TObject);
var i : integer;
    Mensagem : string;
    Html : string;
begin
  // inicializando
  Mensagem := '';
  i := 0;

  // vou fazer uma valida��o basica levando em considera��o que
  // os campos s�o obrigat�rios tem atribuindo a tag "1" ao compomente.
  // O processo ser� simples, o sistema ira varrer todos os compomentes
  // da classe tDbEdit e verificar� se o campo est� nulo, ao encontrar
  // ele ir� adicionar como mensagem de erro na string MSG o t�tulo do campo
  // informado no HINT do compomente, al�m de setar o foco para o primeiro
  // campo que dever� ser preenchido
  // ao final do processo se a vari�vel MSG n�o estiver vazia ele exibir�
  // para o cliente a mensagem e n�o realizar� o cadastro.

  for i := 0 to ComponentCount - 1 do
  begin
    if (Components[i].Tag = 1) and
       (Components[i].ClassType = tdbEdit) then
    begin
      if tdbEdit(components[i]).Field.IsNull then
      begin
        if Mensagem = '' then
          tdbEdit(components[i]).SetFocus;
          Mensagem := Mensagem + #13 + tdbEdit(components[i]).Hint;
      end;
    end;
  end;

  // exibir a mensagem se existir ou cancelar efetivar o cadastro
  if Mensagem <> '' then
  begin
    showMessage('Existem algumas pend�ncias no cadastro:' + Mensagem);
  end
  else
  begin
    cdsCliente.Post;
    cdsCliente.SaveToFile(arquivoDados);
    // criar o documento xml, os campos relativos ao endere�o ficar�o
    // dentro de uma subchave endere�o
    criarDocumentoXML(cdsCliente, arquivoXML);
    // criar um documento html que ir� no corpo do e-mail
    Html := criarDocumentoHTML(cdsClienteNOME.AsString, cdsClienteEMAIL.AsString);
    if enviarEmail(cdsClienteEMAIL.AsString, Html, arquivoXML, self) then
      showMessage('O envio do e-mail foi efetuado com sucesso!')
    else
      showMessage('Ocorreu um erro ao enviar o e-mail.');
  end;
end;

procedure TfrmPrincipal.btnNovoCadastroClick(Sender: TObject);
begin
  // limpa o dataset e inclui um novo cadastro, o estado dos bot�es � alterado
  // no changeDataset
  if not cdsCliente.IsEmpty then
  begin
    cdsCliente.Delete;
  end;
  cdsCliente.Close;
  cdsCliente.Open;
  cdsCliente.Insert;

  // iniciar sempre no campo nome
  dbeNome.SetFocus;
end;

procedure TfrmPrincipal.cdsClienteNewRecord(DataSet: TDataSet);
begin
  // ser�o definidos alguns valores padr�o para facilicar para o usu�rio
  // o ideal seria colocar nas configura��es mas o sistema ficaria muito grande
  // e fugiria do prop�sito que � fazer um teste
  cdsClienteCIDADE.AsString := 'BELO HORIZONTE';
  cdsClienteESTADO.AsString := 'MG';
  cdsClientePAIS.AsString := 'BRASIL';
end;

procedure TfrmPrincipal.dbeCepExit(Sender: TObject);
var Json: TJsonObject;
begin
  // dispara a checagem e busca de CEP
  // verificar se est� editando ou se cancelou a opera��o
  if not (dtsCliente.State in [dsEdit, dsInsert]) then exit;
  if (sender = btnCancelarCadastro) then exit;

  // buscar o endere�o relacionado ao CEP
  Json := buscarCep(cdsClienteCEP.AsString);

  // aplicar os dados ao dataset
  if json = nil then
  begin
    showMessage('CEP n�o encontrado ou inexistente!');
  end
  else
  begin
    cdsClienteLOGRADOURO.AsString := JSON.Get('logradouro').JsonValue.Value;
    cdsClienteCIDADE.AsString     := UpperCase(JSON.Get('localidade').JsonValue.Value);
    cdsClienteBAIRRO.AsString     := JSON.Get('bairro').JsonValue.Value;
    cdsClienteESTADO.AsString     := JSON.Get('uf').JsonValue.Value;
    dbeNumero.SetFocus;
  end;

end;

procedure TfrmPrincipal.dbeCpfExit(Sender: TObject);
begin
  // verificar se o usu�rio est� cancelando ou saindo, neste caso ignorar o cpf
  if (sender = btnCancelarCadastro) or (sender = btnFechar) then
  begin
    exit;
  end;

  // verificar se o cpf foi informado corretamente
  if not validarCpf(cdsClienteCPF.AsString) then
  begin
    showMessage('N�mero de CPF inv�lido!');
    // o usu�rio � obrigado a informar um CPF certo
    dbeCpf.SetFocus;
  end;

end;

procedure TfrmPrincipal.dtsClienteStateChange(Sender: TObject);
begin
  // ativa/desativa os bot�es de comando de acordo com o status do dataset
  // bot�es gravar e cancelar ficam ativos quando o dataset em modo de
  // edi��o/inser��o e em modo de navega��o o bot�o novo fica ativo
  if cdsCliente.State in [dsEdit, dsInsert] then
  begin
    btnNovoCadastro.Enabled := false;
    btnGravarCadastro.Enabled := true;
    btnCancelarCadastro.Enabled := true;
  end
  else
  begin
    btnNovoCadastro.Enabled := true;
    btnGravarCadastro.Enabled := false;
    btnCancelarCadastro.Enabled := false;
  end;

end;

procedure TfrmPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // impedir que o usu�rio feche o cadastro se alguma informa��o ainda n�o foi
  // salva
  if cdsCliente.State in [dsEdit, dsInsert] then
  begin
    showMessage('Voc� deve salvar o registro o cancelar antes de sair.');
    Action := caNone;
  end;
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
var diretorio : string; // diret�rio atual da aplicacao
begin
  // preparar as configuracoes iniciais
  // caminho raiz para os arquivos
  diretorio := extractFilePath(application.ExeName);

  // definir os arquivos
  arquivoConfiguracao := diretorio + NOME_ARQUIVO_CONFIGURACAO;
  arquivoDados := diretorio + NOME_ARQUIVO_DADOS;
  arquivoXml := diretorio + NOME_ARQUIVO_XML;

  // verifica se j� existe um arquivo de dados gerado anteriormente e abre
  if fileExists(arquivoDados) then
    cdsCliente.LoadFromFile(arquivoDados);

  // Inicia o dataset que vai carregar os dados em mem�ria
  cdsCliente.Open;
end;

procedure TfrmPrincipal.FormKeyPress(Sender: TObject; var Key: Char);
begin
  // permitir que o usu�rio navegue entre os campos apertando enter
  if Key = #13 then
  begin
    Perform(Wm_NextDlgCtl,0,0);
  end;
end;

procedure TfrmPrincipal.FormShow(Sender: TObject);
var ini : tIniFile;
begin
  // vou verificar se a configura��o j� foi feita, se n�o vou for�ar o usu�rio
  // a fazer
  ini := tIniFile.Create(arquivoConfiguracao);
  if (ini.ReadString('CONFIGURACAO', 'edtUsuario', '')='') or
     (ini.ReadString('CONFIGURACAO', 'edtServidorSmtp', '')='') or
     (ini.ReadString('CONFIGURACAO', 'edtSenha', '')='') or
     (ini.ReadString('CONFIGURACAO', 'edtPorta', '')='') then
  begin
    // se a configuracao estiver imcompleta vou solicitar que o usu�rio fa�a
    frmConfiguracao.ShowModal;
    // chamo a fun��o recursivamente at� ele fazer a configuracao
    FormShow(sender);
  end;
end;

procedure TfrmPrincipal.mnuConfiguracoesClick(Sender: TObject);
begin
  // Carregar tela de configura��es
  frmConfiguracao.ShowModal;
end;

procedure TfrmPrincipal.mnuSairClick(Sender: TObject);
begin
  // tenta sair do sistema mas pode ser impedido pelo evento on close que ir�
  // checar se existe alguma altera��o pendente
  close;
end;

end.
