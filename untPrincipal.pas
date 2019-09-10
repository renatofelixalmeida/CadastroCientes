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
  // tenta sair do sistema mas pode ser impedido pelo evento on close que irá
  // checar se existe alguma alteração pendente
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

  // vou fazer uma validação basica levando em consideração que
  // os campos são obrigatórios tem atribuindo a tag "1" ao compomente.
  // O processo será simples, o sistema ira varrer todos os compomentes
  // da classe tDbEdit e verificará se o campo está nulo, ao encontrar
  // ele irá adicionar como mensagem de erro na string MSG o título do campo
  // informado no HINT do compomente, além de setar o foco para o primeiro
  // campo que deverá ser preenchido
  // ao final do processo se a variável MSG não estiver vazia ele exibirá
  // para o cliente a mensagem e não realizará o cadastro.

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
    showMessage('Existem algumas pendências no cadastro:' + Mensagem);
  end
  else
  begin
    cdsCliente.Post;
    cdsCliente.SaveToFile(arquivoDados);
    // criar o documento xml, os campos relativos ao endereço ficarão
    // dentro de uma subchave endereço
    criarDocumentoXML(cdsCliente, arquivoXML);
    // criar um documento html que irá no corpo do e-mail
    Html := criarDocumentoHTML(cdsClienteNOME.AsString, cdsClienteEMAIL.AsString);
    if enviarEmail(cdsClienteEMAIL.AsString, Html, arquivoXML, self) then
      showMessage('O envio do e-mail foi efetuado com sucesso!')
    else
      showMessage('Ocorreu um erro ao enviar o e-mail.');
  end;
end;

procedure TfrmPrincipal.btnNovoCadastroClick(Sender: TObject);
begin
  // limpa o dataset e inclui um novo cadastro, o estado dos botões é alterado
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
  // serão definidos alguns valores padrão para facilicar para o usuário
  // o ideal seria colocar nas configurações mas o sistema ficaria muito grande
  // e fugiria do propósito que é fazer um teste
  cdsClienteCIDADE.AsString := 'BELO HORIZONTE';
  cdsClienteESTADO.AsString := 'MG';
  cdsClientePAIS.AsString := 'BRASIL';
end;

procedure TfrmPrincipal.dbeCepExit(Sender: TObject);
var Json: TJsonObject;
begin
  // dispara a checagem e busca de CEP
  // verificar se está editando ou se cancelou a operação
  if not (dtsCliente.State in [dsEdit, dsInsert]) then exit;
  if (sender = btnCancelarCadastro) then exit;

  // buscar o endereço relacionado ao CEP
  Json := buscarCep(cdsClienteCEP.AsString);

  // aplicar os dados ao dataset
  if json = nil then
  begin
    showMessage('CEP não encontrado ou inexistente!');
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
  // verificar se o usuário está cancelando ou saindo, neste caso ignorar o cpf
  if (sender = btnCancelarCadastro) or (sender = btnFechar) then
  begin
    exit;
  end;

  // verificar se o cpf foi informado corretamente
  if not validarCpf(cdsClienteCPF.AsString) then
  begin
    showMessage('Número de CPF inválido!');
    // o usuário é obrigado a informar um CPF certo
    dbeCpf.SetFocus;
  end;

end;

procedure TfrmPrincipal.dtsClienteStateChange(Sender: TObject);
begin
  // ativa/desativa os botões de comando de acordo com o status do dataset
  // botões gravar e cancelar ficam ativos quando o dataset em modo de
  // edição/inserção e em modo de navegação o botão novo fica ativo
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
  // impedir que o usuário feche o cadastro se alguma informação ainda não foi
  // salva
  if cdsCliente.State in [dsEdit, dsInsert] then
  begin
    showMessage('Você deve salvar o registro o cancelar antes de sair.');
    Action := caNone;
  end;
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
var diretorio : string; // diretório atual da aplicacao
begin
  // preparar as configuracoes iniciais
  // caminho raiz para os arquivos
  diretorio := extractFilePath(application.ExeName);

  // definir os arquivos
  arquivoConfiguracao := diretorio + NOME_ARQUIVO_CONFIGURACAO;
  arquivoDados := diretorio + NOME_ARQUIVO_DADOS;
  arquivoXml := diretorio + NOME_ARQUIVO_XML;

  // verifica se já existe um arquivo de dados gerado anteriormente e abre
  if fileExists(arquivoDados) then
    cdsCliente.LoadFromFile(arquivoDados);

  // Inicia o dataset que vai carregar os dados em memória
  cdsCliente.Open;
end;

procedure TfrmPrincipal.FormKeyPress(Sender: TObject; var Key: Char);
begin
  // permitir que o usuário navegue entre os campos apertando enter
  if Key = #13 then
  begin
    Perform(Wm_NextDlgCtl,0,0);
  end;
end;

procedure TfrmPrincipal.FormShow(Sender: TObject);
var ini : tIniFile;
begin
  // vou verificar se a configuração já foi feita, se não vou forçar o usuário
  // a fazer
  ini := tIniFile.Create(arquivoConfiguracao);
  if (ini.ReadString('CONFIGURACAO', 'edtUsuario', '')='') or
     (ini.ReadString('CONFIGURACAO', 'edtServidorSmtp', '')='') or
     (ini.ReadString('CONFIGURACAO', 'edtSenha', '')='') or
     (ini.ReadString('CONFIGURACAO', 'edtPorta', '')='') then
  begin
    // se a configuracao estiver imcompleta vou solicitar que o usuário faça
    frmConfiguracao.ShowModal;
    // chamo a função recursivamente até ele fazer a configuracao
    FormShow(sender);
  end;
end;

procedure TfrmPrincipal.mnuConfiguracoesClick(Sender: TObject);
begin
  // Carregar tela de configurações
  frmConfiguracao.ShowModal;
end;

procedure TfrmPrincipal.mnuSairClick(Sender: TObject);
begin
  // tenta sair do sistema mas pode ser impedido pelo evento on close que irá
  // checar se existe alguma alteração pendente
  close;
end;

end.
