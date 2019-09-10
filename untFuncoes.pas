unit untFuncoes;

interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.StdCtrls, Vcl.DBCtrls,
  Vcl.Mask, Vcl.ExtCtrls, Data.DB, Datasnap.DBClient, Data.DBXJSON,
  DBXJSONReflect,  idHTTP, IdSSLOpenSSL, JSON, XMLIntf, XMLDoc, IdSMTP,
  IdMessage, IdText, IdAttachmentFile, IdExplicitTLSClientServerBase, inifiles;

  function validarCpf(pcpf : string) : boolean; // valida um número de cpf
  procedure criarDocumentoXML(dataSet : tDataSet; arquivo : String); // Cria documento XML
  function buscarCEP(CEP:string): TJSONObject; // recebe um objeto JSON do CEP
  function criarDocumentoHTML(nomeCliente, emailCliente: string): string; // cria o documento html
  function enviarEmail(html, anexo : string; self :tComponent) : boolean; // Envia o email
implementation

uses untPrincipal;

function validarCpf(pcpf : string) : boolean; // valida um número de cpf
var i, t, d, l : integer;
begin
  // função interessante e muito simples para validação de CPF utilizando
  // dois loops aninhados para calcular os dois DVs do cpf
  // inicializacao
  result := false;
  i := 0;

  // primeira validação verificar se o número tem 11 caracteres
  if length(pcpf) <> 11 then exit;

  // o cpf contem dois digitos verificadores posicionados no final e são
  // validados pelo modulo 11
  // serão utilizados dois loops alinhados sendo um para indicar qual
  // o digito sendo verificado e o outro para aplicar o módulo 11
  // a soma é obtida a partir de um multiplicador aplicado a cada
  // caracter do cep começando em 10 na primeira iteração e em 11 na segunda
  // sempre da esquerda para a direita. O resultado do DV para cada iteração
  // é obtido subtraindo o módulo da soma de 11. Caso o resultado seja 10
  // o DV irá valer zero (basta aplicar o módulo 10 no resultado)
  // não existe a checagem de números repetidos
  l := 0;
  while (l<2) do
  begin
      t := 0;
      i := 1;
      while (i<10+l) do
      begin
          d := strToInt(pcpf[i]);
          t := t + (11 + l - i) * d;
          inc(i);
      end;
      t := (11 - t mod 11) mod 10;
      if strToInt(pcpf[i]) <> t then exit; // cpf incorreto
      inc(l);
  end;
  result := true;
end;

procedure criarDocumentoXML(dataSet : tDataSet; arquivo : String); // Cria documento XML
var XMLDocument: TXMLDocument;
    NodeTabela, NodeRegistro, NodeEndereco: IXMLNode;
begin

  // criar o documento xml que será anexado ao e-mail, conterá a seguinte estrutura
  // Raiz
  //  Nome, Identidade, CPF, Telefone, E-mail
  //  Endereço
  //    Cep, Logradouro, Número, Complemento, Bairro, Cidade, Estado, País
  // o documento será salvo no caminho informado em arquivo e os dados virão do
  // dataset
  XMLDocument := TXMLDocument.Create(nil);
  try
    XMLDocument.Active := True;
    NodeTabela := XMLDocument.AddChild('Cadastro');

    NodeRegistro := NodeTabela.AddChild('Cliente');

    NodeRegistro.ChildValues['Nome'] := dataSet.FieldByName('NOME').AsString;
    NodeRegistro.ChildValues['Identidade'] := dataSet.FieldByName('IDENTIDADE').AsString;
    NodeRegistro.ChildValues['CPF'] := dataSet.FieldByName('CPF').AsString;
    NodeRegistro.ChildValues['Telefone'] := dataSet.FieldByName('TELEFONE').AsString;
    NodeRegistro.ChildValues['Email'] := dataSet.FieldByName('EMAIL').AsString;

    NodeEndereco := NodeRegistro.AddChild('Endereco');
    NodeEndereco.ChildValues['Cep'] := dataSet.FieldByName('CEP').AsString;
    NodeEndereco.ChildValues['Logradouro'] := dataSet.FieldByName('LOGRADOURO').AsString;
    NodeEndereco.ChildValues['Numero'] := dataSet.FieldByName('NUMERO').AsString;
    NodeEndereco.ChildValues['Complemento'] := dataSet.FieldByName('COMPLEMENTO').AsString;
    NodeEndereco.ChildValues['Bairro'] := dataSet.FieldByName('BAIRRO').AsString;
    NodeEndereco.ChildValues['Cidade'] := dataSet.FieldByName('CIDADE').AsString;
    NodeEndereco.ChildValues['Estado'] := dataSet.FieldByName('ESTADO').AsString;
    NodeEndereco.ChildValues['Pais'] := dataSet.FieldByName('PAIS').AsString;
    XMLDocument.SaveToFile(arquivo);
  finally
    XMLDocument.Free;
  end;

end;

function buscarCEP(CEP:string): TJSONObject; // recebe um objeto JSON do CEP
var
   HTTP: TIdHTTP;
   IDSSLHandler : TIdSSLIOHandlerSocketOpenSSL;
   Response: TStringStream;
   LJsonObj: TJSONObject;
begin
  // função criado por julio abrantes obtida em
  // https://github.com/juniorabranches/CEPascal/blob/master/UMain.pas
  // executa a busca de CEP na API da via cep e retorna um objeto json
   try
      HTTP := TIdHTTP.Create;
      IDSSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create;
      HTTP.IOHandler := IDSSLHandler;
      Response := TStringStream.Create('');
      HTTP.Get('https://viacep.com.br/ws/' + CEP + '/json', Response);
      if (HTTP.ResponseCode = 200) and not(Utf8ToAnsi(Response.DataString) = '{'#$A'  "erro": true'#$A'}') then
         Result := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes( Utf8ToAnsi(Response.DataString)), 0) as TJSONObject;
   finally
      FreeAndNil(HTTP);
      FreeAndNil(IDSSLHandler);
      Response.Destroy;
   end;
end;
function criarDocumentoHTML(nomeCliente, emailCliente: string): string; // cria o documento html
begin
  result := '<HTML lang=pt_br>' + // simples documento HTML explicando o
            '<HEAD>' +            // cadastro
            '<META CHARSET="UTF-8">' +
            '</HEAD>' +
            '<BODY>' +
            '<H1>Cliente cadastrado</H1>' +
            '<P>O cliente <a href="mailto:' + emailCliente + '">' + nomeCliente + '</a> foi cadastrado em nosso sistema com sucesso</P>' +
            '<P>Anexo voc&eacute; encontrar&aacute; um documento XML com todas as informa&ccedil;&otilde;es do cadastro</P>' +
            '</BODY>' +
            '</HTML>';
end;

function enviarEmail(html, anexo : string; self :tComponent) : boolean; // Envia o email
var
  // Envia um e-mail com os parâmetros passados
  // As configurações da conta de e-mail são registradas nas constantes
  // A senha de acesso a conta também está na costante apenas para teste
  // não deve ser usado em modo de proteção
  // para utilizar o GMAIL para enviar e-mails é necessário alterar as
  // configurações de segurança permitindo aplicativos de terceiros não
  // seguros. Caso contrário não será possível enviar o e-mail.
  // Para saber se as suas configurações estão corretas no caso do Gmail
  // basta tentar enviar um e-mail. Se o gmail bloquear o envio informando
  // erro de autenticação, basta ir na caixa de entrar, abrir o e-mail de
  // aviso do gmail e dar a permissão
  IdSSLIOHandlerSocket: TIdSSLIOHandlerSocketOpenSSL;
  IdSMTP: TIdSMTP;
  IdMessage: TIdMessage;
  IdText: TIdText;
  ini : tIniFile;
begin
  // inicialização
  result := true;
  IdSSLIOHandlerSocket := TIdSSLIOHandlerSocketOpenSSL.Create(Self);
  IdSMTP := TIdSMTP.Create(Self);
  IdMessage := TIdMessage.Create(Self);
  ini := tIniFile.Create(arquivoConfiguracao);
  try
    // Configuração do protocolo SSL (TIdSSLIOHandlerSocketOpenSSL)
    IdSSLIOHandlerSocket.SSLOptions.Method := sslvSSLv23;
    IdSSLIOHandlerSocket.SSLOptions.Mode := sslmClient;

    // Configuração do servidor SMTP (TIdSMTP)
    IdSMTP.IOHandler := IdSSLIOHandlerSocket;
    if ini.ReadBool('CONFIGURACAO', 'chkSSL', false) then
      IdSMTP.UseTLS := utUseImplicitTLS;

    IdSMTP.AuthType := satDefault;
    IdSMTP.Port := strToInt(ini.ReadString('CONFIGURACAO', 'edtPorta', ''));
    IdSMTP.Host := ini.ReadString('CONFIGURACAO', 'edtServidorSmtp', '');
    IdSMTP.Username := ini.ReadString('CONFIGURACAO', 'edtUsuario', '');
    IdSMTP.Password := ini.ReadString('CONFIGURACAO', 'edtSenha', '');

    // Configuração da mensagem (TIdMessage)
    IdMessage.From.Address := ini.ReadString('CONFIGURACAO', 'edtUsuario', '');
    IdMessage.From.Name := 'Cadastro de Cliente';
    IdMessage.ReplyTo.EMailAddresses := IdMessage.From.Address;
    IdMessage.Recipients.Add.Text := ini.ReadString('CONFIGURACAO', 'edtUsuario', '');
    IdMessage.Subject := 'Cadastro de cliente';
    IdMessage.Encoding := meMIME;

    // Configuração do corpo do email (TIdText)
    IdText := TIdText.Create(IdMessage.MessageParts);
    IdText.Body.Add(html);
    IdText.ContentType := 'text/html;; charset=iso-8859-1';

    // Adiciona o anexo da mensagem se existir (TIdAttachmentFile)
    if FileExists(Anexo) then
      TIdAttachmentFile.Create(IdMessage.MessageParts, Anexo);

    // Conexão e autenticação
    try
      IdSMTP.Connect;
      IdSMTP.Authenticate;
    except
      on E:Exception do
      begin
        MessageDlg('Erro na conexão ou autenticação: ' +
          E.Message, mtWarning, [mbOK], 0);
        result := false;
        Exit;
      end;
    end;

    // Envio da mensagem
    try
      IdSMTP.Send(IdMessage);
      MessageDlg('Mensagem enviada com sucesso!', mtInformation, [mbOK], 0);
    except
      On E:Exception do
      begin
        MessageDlg('Erro ao enviar a mensagem: ' +
          E.Message, mtWarning, [mbOK], 0);
        result := false;
      end;
    end;
  finally
    // desconecta do servidor
    IdSMTP.Disconnect;
    // liberação da DLL
    UnLoadOpenSSLLibrary;
    // liberação dos objetos da memória
    FreeAndNil(IdMessage);
    FreeAndNil(IdSSLIOHandlerSocket);
    FreeAndNil(IdSMTP);
    FreeAndNil(ini);
  end;
end;

end.
