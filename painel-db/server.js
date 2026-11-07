import express from 'express';
import mysql from 'mysql2/promise';
import { createCipheriv, createDecipheriv, createHash, randomBytes } from 'node:crypto';
import { fileURLToPath } from 'node:url';

const app = express();
const ttl = 30 * 60 * 1000;
const port = Number(process.env.PORT || 3000);
const sessionSecret = process.env.SESSION_SECRET || (!process.env.VERCEL ? randomBytes(32).toString('hex') : '');
const sessionKey = sessionSecret ? createHash('sha256').update(sessionSecret).digest() : null;
const configuredHost = (process.env.MYSQL_HOST || 'gondola.proxy.rlwy.net').trim().toLowerCase();
const configuredPort = Number(process.env.MYSQL_PORT || 23641);
app.disable('x-powered-by');
app.set('trust proxy', 1);
app.use((req, res, next) => {
  res.set({ 'Cache-Control': 'no-store', 'X-Content-Type-Options': 'nosniff',
    'Content-Security-Policy': "default-src 'self'; script-src 'self'; style-src 'self'; frame-ancestors 'none'; base-uri 'none'; form-action 'self'" });
  if (req.method !== 'GET' && req.headers.origin) {
    try {
      if (new URL(req.headers.origin).host !== req.headers.host) {
        return res.status(403).json({ error: 'Origem não permitida.' });
      }
    } catch {
      return res.status(403).json({ error: 'Origem não permitida.' });
    }
  }
  next();
});
app.use(express.json({ limit: '2mb' }));
app.use(express.static(fileURLToPath(new URL('./public', import.meta.url))));

function cookieValue(req, name) {
  return req.headers.cookie?.split(';').map(value => value.trim())
    .find(value => value.startsWith(`${name}=`))?.slice(name.length + 1);
}

function sealSession(session) {
  if (!sessionKey) throw new Error('Configure SESSION_SECRET nas variáveis de ambiente da Vercel.');
  const iv = randomBytes(12);
  const cipher = createCipheriv('aes-256-gcm', sessionKey, iv);
  const ciphertext = Buffer.concat([cipher.update(JSON.stringify(session)), cipher.final()]);
  return `${iv.toString('hex')}.${cipher.getAuthTag().toString('hex')}.${ciphertext.toString('hex')}`;
}

function openSession(req) {
  if (!sessionKey) throw new Error('Configure SESSION_SECRET nas variáveis de ambiente da Vercel.');
  const value = cookieValue(req, 'session');
  if (!value) return null;
  try {
    const [ivHex, tagHex, ciphertextHex] = value.split('.');
    if (!ivHex || !tagHex || !ciphertextHex) return null;
    const decipher = createDecipheriv('aes-256-gcm', sessionKey, Buffer.from(ivHex, 'hex'));
    decipher.setAuthTag(Buffer.from(tagHex, 'hex'));
    const plaintext = Buffer.concat([
      decipher.update(Buffer.from(ciphertextHex, 'hex')),
      decipher.final()
    ]).toString();
    const session = JSON.parse(plaintext);
    if (typeof session.expires !== 'number' || session.expires < Date.now()) return null;
    return session;
  } catch {
    return null;
  }
}

function setSessionCookie(res, session) {
  res.cookie('session', sealSession(session), {
    httpOnly: true,
    sameSite: 'strict',
    secure: Boolean(process.env.VERCEL),
    maxAge: ttl,
    path: '/'
  });
}

function mysqlOptions(session) {
  const options = {
    host: session.host,
    port: session.port,
    user: session.user,
    password: session.password,
    connectTimeout: 15000,
    multipleStatements: true,
    supportBigNumbers: true,
    bigNumberStrings: true,
    dateStrings: true
  };
  if (session.database) options.database = session.database;
  if (session.ssl) options.ssl = { rejectUnauthorized: true };
  return options;
}

const attempts = new Map();
app.post('/api/login', async (req, res) => {
  const ip = req.ip;
  const recent = (attempts.get(ip) || []).filter(time => Date.now() - time < 60000);
  if (recent.length >= 10) return res.status(429).json({ error: 'Aguarde um minuto para tentar novamente.' });
  attempts.set(ip, [...recent, Date.now()]);
  const { host, port: requestedPort, user, password, database = '', ssl = false } = req.body;
  const dbPort = Number(requestedPort);
  if (typeof host !== 'string' || !host.trim() || host.length > 253 ||
      !Number.isInteger(dbPort) || dbPort < 1 || dbPort > 65535 ||
      typeof user !== 'string' || !user.trim() || user.length > 128 ||
      typeof password !== 'string' || !password || password.length > 1024 ||
      typeof database !== 'string' || database.length > 64 || typeof ssl !== 'boolean') {
    return res.status(400).json({ error: 'Informe host, porta, usuário e senha válidos.' });
  }
  if (process.env.VERCEL && (host.trim().toLowerCase() !== configuredHost || dbPort !== configuredPort)) {
    return res.status(400).json({ error: `Use o host ${configuredHost} e a porta ${configuredPort} configurados para este painel.` });
  }
  if (!sessionKey) return res.status(500).json({ error: 'Configure SESSION_SECRET nas variáveis de ambiente da Vercel.' });

  const session = {
    host: host.trim(),
    port: dbPort,
    user: user.trim(),
    password,
    database: database.trim(),
    ssl,
    expires: Date.now() + ttl
  };
  let connection;
  try {
    connection = await mysql.createConnection(mysqlOptions(session));
    await connection.ping();
    await connection.end();
    connection = null;
    setSessionCookie(res, session);
    res.json({ user: session.user, database: session.database, host: session.host, port: session.port });
  } catch (error) {
    if (connection) {
      await connection.end().catch(closeError => console.error('MySQL connection close failed:', closeError));
    }
    const status = error.code === 'ER_ACCESS_DENIED_ERROR' ? 401 : 502;
    const details = {
      HANDSHAKE_SSL_ERROR: 'Falha ao negociar TLS/SSL. Confira a opção TLS do formulário.',
      CERT_HAS_EXPIRED: 'O certificado TLS expirou. Confira a configuração TLS do provedor.',
      DEPTH_ZERO_SELF_SIGNED_CERT: 'O provedor apresentou um certificado TLS não confiável.',
      SELF_SIGNED_CERT_IN_CHAIN: 'O provedor apresentou um certificado TLS não confiável.',
      ENOTFOUND: 'Host não encontrado. Confira o endereço do servidor.',
      ECONNREFUSED: 'Conexão recusada. Confira host, porta e acesso público do banco.',
      ETIMEDOUT: 'Tempo de conexão esgotado. Confira a rede, host e porta.',
      ER_BAD_DB_ERROR: 'Banco não encontrado ou sem acesso. Deixe o banco inicial vazio e tente novamente.'
    };
    const detail = details[error.code] || error.message || 'verifique as credenciais e a rede';
    res.status(status).json({ error: `Não foi possível conectar${error.code ? ` (${error.code})` : ''}: ${detail}` });
  }
});

app.post('/api/logout', (req, res) => {
  res.clearCookie('session', { httpOnly: true, sameSite: 'strict', secure: Boolean(process.env.VERCEL), path: '/' });
  res.json({ ok: true });
});

app.get('/api/config', (req, res) => {
  res.json({
    host: configuredHost,
    port: configuredPort,
    scriptsEnabled: !process.env.VERCEL || process.env.ENABLE_SQL_SCRIPTS === 'true'
  });
});

app.use('/api', async (req, res, next) => {
  let session;
  try {
    session = openSession(req);
  } catch (error) {
    return next(error);
  }
  if (!session) return res.status(401).json({ error: 'Sessão encerrada. Entre novamente.' });

  try {
    req.session = session;
    req.db = await mysql.createConnection(mysqlOptions(session));
    res.on('finish', () => {
      req.db.end().catch(error => console.error('MySQL connection close failed:', error));
    });
    next();
  } catch (error) {
    next(error);
  }
});

app.get('/api/tables', async (req, res, next) => {
  try {
    if (!req.session.database) return res.status(400).json({ error: 'Selecione um banco de dados primeiro.' });
    const [rows] = await req.db.query('SHOW FULL TABLES');
    res.json(rows.map(row => ({ name: Object.values(row)[0], type: Object.values(row)[1] })));
  } catch (error) { next(error); }
});

app.get('/api/databases', async (req, res, next) => {
  try {
    const [rows] = await req.db.query('SHOW DATABASES');
    res.json(rows.map(row => Object.values(row)[0]));
  } catch (error) { next(error); }
});

app.post('/api/database', async (req, res, next) => {
  const database = req.body.database;
  if (typeof database !== 'string' || !database.trim() || database.length > 64) {
    return res.status(400).json({ error: 'Banco de dados inválido.' });
  }
  try {
    await req.db.query(`USE ${mysql.escapeId(database.trim())}`);
    req.session.database = database.trim();
    setSessionCookie(res, req.session);
    res.json({ database: req.session.database });
  } catch (error) { next(error); }
});

app.get('/api/table', async (req, res, next) => {
  try {
    const name = req.query.name;
    if (typeof name !== 'string' || !name.length || name.length > 64) return res.status(400).json({ error: 'Tabela inválida.' });
    const page = Math.max(0, Math.min(100000, Number.parseInt(req.query.page, 10) || 0));
    const identifier = mysql.escapeId(name);
    const [columns] = await req.db.query(`SHOW COLUMNS FROM ${identifier}`);
    const [rows, fields] = await req.db.execute(`SELECT * FROM ${identifier} LIMIT ? OFFSET ?`, [100, page * 100]);
    res.json({ columns, rows, fields: fields.map(field => field.name), page });
  } catch (error) { next(error); }
});

app.post('/api/query', async (req, res, next) => {
  if (process.env.VERCEL && process.env.ENABLE_SQL_SCRIPTS !== 'true') {
    return res.status(403).json({ error: 'Execução de scripts está desabilitada. Configure ENABLE_SQL_SCRIPTS=true na Vercel para habilitá-la.' });
  }
  const sql = req.body.sql;
  if (typeof sql !== 'string' || !sql.trim()) return res.status(400).json({ error: 'Digite ou carregue um script SQL.' });
  const start = Date.now();
  try {
    const [rows, fields] = await req.db.query({ sql, timeout: 30000 });
    const [currentDatabase] = await req.db.query('SELECT DATABASE() AS current_database');
    req.session.database = currentDatabase[0]?.current_database || '';
    setSessionCookie(res, req.session);
    const multi = Array.isArray(fields) && fields.some(field => Array.isArray(field) || field === undefined);
    const sets = multi ? rows : [rows];
    const metadata = multi ? fields : [fields];
    res.json({
      elapsed: Date.now() - start,
      database: req.session.database,
      results: sets.map((result, index) => Array.isArray(result)
        ? { rows: result.slice(0, 1000), total: result.length, fields: (metadata[index] || []).map(field => field.name) }
        : { affectedRows: result.affectedRows, insertId: result.insertId, info: result.info })
    });
  } catch (error) {
    try {
      const [currentDatabase] = await req.db.query('SELECT DATABASE() AS current_database');
      req.session.database = currentDatabase[0]?.current_database || '';
      setSessionCookie(res, req.session);
    } catch (stateError) {
      return next(stateError);
    }
    res.status(400).json({
      error: error.sqlMessage || error.message || 'Falha ao executar o script.',
      database: req.session.database
    });
  }
});

app.use((error, req, res, next) => {
  res.status(400).json({ error: error.sqlMessage || error.message || 'Falha na operação.' });
});

export default app;
