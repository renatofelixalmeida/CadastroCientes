# CadastroCientes
Projeto de teste para processo seletivo. Simples cadastro de clientes sem banco de dados com busca automática de CEP e envio por e-mail via XML

Sistema desenvolvido por Renato Félix de Almeida em 09/09/2019

# Requisitos:

* Utilizar a linguagem Delphi;

* Criar uma tela de cadastro de clientes, com os seguintes campos:
  Nome, Identidade, CPF, Telefone, Email, Endereço, Cep, Logradouro, Numero,
  Complemento, Bairro, Cidade, Estado, Pais
  
* Ao informar um Cep o sistema deve realizar a busca dos dados relacionados ao
  mesmo no seguinte endereço: https://viacep.com.br/;
  
* A forma de consumo da API do via Cep, deverá ser utiliza JSON;

* Ao termino do cadastro o usuário deverá enviar um email, contendo as
  informações cadastrais, onde deverá ser enviado um arquivo no formato XML;
  
* Os registros devem ficar salvo em memória, não será necessário criar um
  banco de dados para o armazenamento dos dados;
  
* Disponibilizar projeto no github;

# Requisitos atendidos:

* Ambiente utilizado:  Delphi 10.3 Community Edition;

* Tabela criada com todos os campos solicitados

* O CEP será pesquisado na base viacep.com.br através de uma solicitação get.

* Os dados serão retornados da Api viacep.com.br no formato JSon.

* Ao gravar o cadastro o sistema automaticamente irá enviar um e-mail para o
Email do cliente cadastrado.

* Os dados são armazenados em um ClientDataset em memória e também são persistidos
no disco.

* Disponibilizado em: https://github.com/renatofelixalmeida/CadastroCientes/

# Observações:

* Nâo foram utilizados recursos como threads ou mesmo o IdAntifreeze porque
O sistema é apenas um simples e rápido teste, mas a implantação destes recursos
impede o congelamento de tela ao buscar os dados do CEP e também ao
enviar o e-mail e deveria ser implementada em uma versão de produção.

* O ambiente de desenvolvimento utilizado foi o Delphi 10.3 Community Edition e
pode ser obtido gratuitamente mediante cadastro em:
http://altd.embarcadero.com/download/radstudio/10.3/radstudio_10_3_2_esd_96593b.exe

* São necessário arquivos de suporte openSSL para utilizar camada SSL. Estes
arquivos podem ser obtidos em: https://indy.fulgan.com/SSL/

* O pacote deve ser baixado para a versão específica da Indy e também do delphi.
Para a versão Delphi 10.3 community os arquivos podem ser baixados em:
https://indy.fulgan.com/SSL/openssl-1.0.2q-i386-win32.zip

* Os arquivos libeay32.dll e ssleay32.dll que estão no pacote openSSL devem ser 
colocados na pasta do executável, lembrando que por padrão o Delphi XE e superiores 
cria o arquivo na pasta debug dentro da subpasta WIN32 ou WIN64 na pasta do projeto.

* Ao iniciar o aplicativo pela primeira vez você será solicitado a informar
os dados do servidor de e-mail, além de nome de usuário, senha, porta e
SSL. Existe uma configuração padrão que já está funcionando, pasta clicar
em Gravar para confirmar.

* Se você tentar utilizar o servidor SMTP do Gmail é importante saber que:
O Gmail por padrão vem configurado para bloquear acesso ao servidor por 
aplicativos de terceiros. Quando você tentar enviar um e-mail, mesmo com
os dados corretos, será informado um erro de autenticação e o gmail 
apresentará uma mensagem na sua caixa de entrada informando a tentativa 
de acesso e lhe apresentará também uma opção para liberar o acesso a 
aplicativos de terceiros inseguros.
