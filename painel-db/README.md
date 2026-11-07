# Painel de banco — CK Autoshop

Aplicação Node.js para explorar bancos MySQL no Railway: lista bancos e tabelas, mostra registros paginados e permite importar scripts SQL.

## Como iniciar no Windows

Instale o Node.js 22 ou superior (versão LTS) e abra um novo terminal. Na pasta deste projeto:

```powershell
cd painel-db
npm install
npm run check
npm start
```

Abra **http://localhost:3000**. Informe o host, a porta, o usuário e a senha mostrados nos dados de conexão do seu provedor MySQL. Para o Railway deste projeto, os valores padrão são `gondola.proxy.rlwy.net:23641`. Deixe **Banco inicial** vazio para listar os bancos aos quais o usuário tem acesso; depois escolha um no menu **Bancos de dados**. Também é possível informar um banco inicial diretamente.

O login usa as próprias credenciais MySQL e suas permissões. Não há cadastro separado. A lista mostra apenas os bancos visíveis para esse usuário; para criar `ck_autoshop`, ele precisa ter permissão `CREATE`. A sessão expira em 30 minutos. No Railway local, as credenciais ficam em um cookie criptografado e a conexão MySQL é aberta por requisição.

## Uso

- Escolha um banco de dados para listar suas tabelas. Selecione uma tabela para ver até 100 registros por página e expanda sua estrutura.
- Use Atualizar para recarregar a lista de bancos e tabelas.
- Para criar as tabelas, conecte-se sem banco inicial, abra **Executar script SQL**, carregue `CK Autoshop-script.sql`, marque a confirmação e execute. Depois selecione `ck_autoshop` no menu de bancos.
- Para inserir os dados de exemplo, abra `Massa-dados.sql` somente depois que as tabelas existirem e execute-o com `ck_autoshop` selecionado.

O script de estrutura cria e seleciona `ck_autoshop`. Se uma execução anterior terminou com erro, atualize a lista e confira se o banco/tabelas apareceram antes de executar novamente: comandos anteriores a um erro podem já ter sido aplicados. O script de dados também não deve ser executado mais de uma vez sem limpar os dados existentes.

TLS fica desabilitado por padrão para compatibilidade com o proxy MySQL do Railway. Ative a opção somente se o provedor oferecer TLS. Sem TLS, usuário, senha e dados não são criptografados no trajeto entre o computador e o banco; prefira uma conexão privada/confiável e não use redes públicas. O painel escuta apenas em `127.0.0.1` para uso local. Para disponibilizá-lo na internet será necessário adaptar a implantação com HTTPS e controles de acesso apropriados.

## Publicar na Vercel

1. Envie o repositório ao GitHub e importe-o na Vercel.
2. Em **Root Directory**, escolha `painel-db`. A Vercel usa o `index.js` como função Node e o `server.js` como aplicação Express.
3. Em **Settings → Environment Variables**, defina:
   - `SESSION_SECRET`: segredo aleatório com pelo menos 32 bytes. Gere localmente com `node -e "console.log(require('node:crypto').randomBytes(32).toString('hex'))"`. Não o publique nem o compartilhe.
   - `MYSQL_HOST`: host público TCP do MySQL no Railway.
   - `MYSQL_PORT`: porta pública TCP do Railway.
4. No Railway, habilite acesso público TCP no serviço MySQL. Use o host e a porta públicos mostrados em **Networking**; não use os endereços privados do Railway a partir da Vercel.
5. Faça o deploy. A tela preencherá host e porta pelas variáveis; entre com o usuário e a senha MySQL.

Por segurança, a execução de scripts SQL fica desabilitada na Vercel por padrão. Para habilitá-la, adicione `ENABLE_SQL_SCRIPTS=true` nas variáveis de ambiente e faça novo deploy. Scripts executam comandos arbitrários com as permissões do usuário MySQL conectado; use um usuário dedicado com apenas as permissões necessárias, nunca `root` ou uma conta administrativa ampla. A importação não é uma barreira contra comandos maliciosos: é uma ferramenta administrativa intencional.

As consultas internas não concatenam valores fornecidos pelo usuário; nomes de bancos e tabelas são escapados como identificadores, e a paginação é convertida em inteiros limitados. O endpoint de execução de scripts é diferente: ele recebe SQL livre intencionalmente e só deve ser habilitado para usuários autorizados.

As credenciais e a sessão são transportadas em cookie `HttpOnly`, `Secure` e criptografado com `SESSION_SECRET`; não ficam em armazenamento persistente no servidor. Alterar `SESSION_SECRET` encerra sessões existentes. Configure acesso ao banco com TLS sempre que o Railway/provedor suportar TLS compatível.

## Verificação

`npm run check` verifica a sintaxe do servidor e do JavaScript do navegador. A conexão real precisa ser validada com suas credenciais MySQL.
