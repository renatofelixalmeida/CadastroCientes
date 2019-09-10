unit untFuncoes;

interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.StdCtrls, Vcl.DBCtrls,
  Vcl.Mask, Vcl.ExtCtrls, Data.DB, Datasnap.DBClient, Data.DBXJSON,
  DBXJSONReflect,  idHTTP, IdSSLOpenSSL, JSON, XMLIntf, XMLDoc, IdSMTP,
  IdMessage, IdText, IdAttachmentFile, IdExplicitTLSClientServerBase, inifiles;

  function validarCpf(pcpf : string) : boolean; // valida um n�mero de cpf
  procedure criarDocumentoXML(dataSet : tDataSet; arquivo : String); // Cria documento XML
  function buscarCEP(CEP:string): TJSONObject; // recebe um objeto JSON do CEP
  function criarDocumentoHTML(nomeCliente, emailCliente: string): string; // cria o documento html
  function enviarEmail(html, anexo : string; self :tComponent) : boolean; // Envia o email
implementation

uses untPrincipal;

function validarCpf(pcpf : string) : boolean; // valida um n�mero de cpf
var i, t, d, l : integer;
begin
  // fun��o interessante e muito simples para valida��o de CPF utilizando
  // dois loops aninhados para calcular os dois DVs do cpf
  // inicializacao
  result := false;
  i := 0;

  // primeira valida��o verificar se o n�mero tem 11 caracteres
  if length(pcpf) <> 11 then exit;

  // o cpf contem dois digitos verificadores posicionados no final e s�o
  // validados pelo modulo 11
  // ser�o utilizados dois loops alinhados sendo um para indicar qual
  // o digito sendo verificado e o outro para aplicar o m�dulo 11
  // a soma � obtida a partir de um multiplicador aplicado a cada
  // caracter do cep come�ando em 10 na primeira itera��o e em 11 na segunda
  // sempre da esquerda para a direita. O resultado do DV para cada itera��o
  // � obtido subtraindo o m�dulo da soma de 11. Caso o resultado seja 10
  // o DV ir� valer zero (basta aplicar o m�dulo 10 no resultado)
  // n�o existe a checagem de n�meros repetidos
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

  // criar o documento xml que ser� anexado ao e-mail, conter� a seguinte estrutura
  // Raiz
  //  Nome, Identidade, CPF, Telefone, E-mail
  //  Endere�o
  //    Cep, Logradouro, N�mero, Complemento, Bairro, Cidade, Estado, Pa�s
  // o documento ser� salvo no caminho informado em arquivo e os dados vir�o do
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
  // fun��o criado por julio abrantes obtida em
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
  // Envia um e-mail com os par�metros passados
  // As configura��es da conta de e-mail s�o registradas nas constantes
  // A senha de acesso a conta tamb�m est� na costante apenas para teste
  // n�o deve ser usado em modo de prote��o
  // para utilizar o GMAIL para enviar e-mails � necess�rio alterar as
  // configura��es de seguran�a permitindo aplicativos de terceiros n�o
  // seguros. Caso contr�rio n�o ser� poss�vel enviar o e-mail.
  // Para saber se as suas configura��es est�o corretas no caso do Gmail
  // basta tentar enviar um e-mail. Se o gmail bloquear o envio informando
  // erro de autentica��o, basta ir na caixa de entrar, abrir o e-mail de
  // aviso do gmail e dar a permiss�o
  IdSSLIOHandlerSocket: TIdSSLIOHandlerSocketOpenSSL;
  IdSMTP: TIdSMTP;
  IdMessage: TIdMessage;
  IdText: TIdText;
  ini : tIniFile;
begin
  // inicializa��o
  result := true;
  IdSSLIOHandlerSocket := TIdSSLIOHandlerSocketOpenSSL.Create(Self);
  IdSMTP := TIdSMTP.Create(Self);
  IdMessage := TIdMessage.Create(Self);
  ini := tIniFile.Create(arquivoConfiguracao);
  try
    // Configura��o do protocolo SSL (TIdSSLIOHandlerSocketOpenSSL)
    IdSSLIOHandlerSocket.SSLOptions.Method := sslvSSLv23;
    IdSSLIOHandlerSocket.SSLOptions.Mode := sslmClient;

    // Configura��o do servidor SMTP (TIdSMTP)
    IdSMTP.IOHandler := IdSSLIOHandlerSocket;
    if ini.ReadBool('CONFIGURACAO', 'chkSSL', false) then
      IdSMTP.UseTLS := utUseImplicitTLS;

    IdSMTP.AuthType := satDefault;
    IdSMTP.Port := strToInt(ini.ReadString('CONFIGURACAO', 'edtPorta', ''));
    IdSMTP.Host := ini.ReadString('CONFIGURACAO', 'edtServidorSmtp', '');
    IdSMTP.Username := ini.ReadString('CONFIGURACAO', 'edtUsuario', '');
    IdSMTP.Password := ini.ReadString('CONFIGURACAO', 'edtSenha', '');

    // Configura��o da mensagem (TIdMessage)
    IdMessage.From.Address := ini.ReadString('CONFIGURACAO', 'edtUsuario', '');
    IdMessage.From.Name := 'Cadastro de Cliente';
    IdMessage.ReplyTo.EMailAddresses := IdMessage.From.Address;
    IdMessage.Recipients.Add.Text := ini.ReadString('CONFIGURACAO', 'edtUsuario', '');
    IdMessage.Subject := 'Cadastro de cliente';
    IdMessage.Encoding := meMIME;

    // Configura��o do corpo do email (TIdText)
    IdText := TIdText.Create(IdMessage.MessageParts);
    IdText.Body.Add(html);
    IdText.ContentType := 'text/html;; charset=iso-8859-1';

    // Adiciona o anexo da mensagem se existir (TIdAttachmentFile)
    if FileExists(Anexo) then
      TIdAttachmentFile.Create(IdMessage.MessageParts, Anexo);

    // Conex�o e autentica��o
    try
      IdSMTP.Connect;
      IdSMTP.Authenticate;
    except
      on E:Exception do
      begin
        MessageDlg('Erro na conex�o ou autentica��o: ' +
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
    // libera��o da DLL
    UnLoadOpenSSLLibrary;
    // libera��o dos objetos da mem�ria
    FreeAndNil(IdMessage);
    FreeAndNil(IdSSLIOHandlerSocket);
    FreeAndNil(IdSMTP);
    FreeAndNil(ini);
  end;
end;

end.
