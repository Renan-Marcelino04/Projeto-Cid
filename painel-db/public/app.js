const $ = id => document.getElementById(id);
let tables = [], databases = [], currentDatabase = '', currentTable = '', page = 0;
async function api(path, body) {
  const response = await fetch(`/api/${path}`, body === undefined ? {} : { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });
  const data = await response.json();
  if (response.status === 401 && path !== 'login') showLogin();
  if (!response.ok) {
    const error = new Error(data.error || 'Falha na operação.');
    error.database = data.database;
    throw error;
  }
  return data;
}
function showLogin() { $('workspace').hidden = true; $('login-screen').hidden = false; $('records').replaceChildren(); currentDatabase = ''; }
function message(text, error = false) { $('status').textContent = text; $('status').className = error ? 'error' : ''; }
function grid(rows, fields) {
  const wrapper = document.createElement('div'); wrapper.className = 'grid-container';
  const table = document.createElement('table'), head = document.createElement('thead'), tr = document.createElement('tr');
  for (const field of fields) { const th = document.createElement('th'); th.textContent = field; tr.append(th); }
  head.append(tr); table.append(head);
  const body = document.createElement('tbody');
  for (const row of rows) { const line = document.createElement('tr'); for (const field of fields) { const cell = document.createElement('td'); const value = row[field]; cell.textContent = value === null ? 'NULL' : typeof value === 'object' ? JSON.stringify(value) : String(value ?? ''); if (value === null) cell.className = 'null'; line.append(cell); } body.append(line); }
  table.append(body); wrapper.append(table);
  if (!rows.length) { const empty = document.createElement('p'); empty.className = 'empty'; empty.textContent = 'Nenhum registro encontrado.'; wrapper.append(empty); }
  return wrapper;
}
function renderTables() {
  $('tables').replaceChildren();
  for (const table of tables.filter(t => t.name.toLowerCase().includes($('search').value.toLowerCase()))) {
    const button = document.createElement('button'); button.textContent = `▦  ${table.name}`; button.className = table.name === currentTable ? 'selected' : ''; button.onclick = () => loadTable(table.name, 0); $('tables').append(button);
  }
}
async function refresh() {
  databases = await api('databases');
  const select = $('database-select');
  select.replaceChildren(new Option('— Selecione um banco —', ''));
  for (const database of databases) select.add(new Option(database, database));
  if (currentDatabase && !databases.includes(currentDatabase)) select.add(new Option(currentDatabase, currentDatabase));
  select.value = currentDatabase;
  tables = currentDatabase ? await api('tables') : [];
  renderTables();
  if (!currentDatabase) {
    $('table-title').textContent = 'Selecione um banco de dados';
    $('table-description').textContent = 'Os bancos disponíveis para seu usuário aparecem no menu à esquerda.';
    $('records').replaceChildren();
    $('columns').replaceChildren();
  }
}
async function loadTable(name, targetPage) {
  try {
    message('Carregando registros…');
    const data = await api(`table?name=${encodeURIComponent(name)}&page=${targetPage}`);
    currentTable = name; page = data.page; renderTables();
    $('table-title').textContent = name; $('table-description').textContent = `${data.rows.length} registros nesta página · até 100 por página`;
    $('records').replaceChildren(grid(data.rows, data.fields));
    $('columns').replaceChildren(grid(data.columns, ['Field', 'Type', 'Null', 'Key', 'Default', 'Extra']));
    $('page-label').textContent = ` ${page + 1} `; $('previous').disabled = page === 0; $('next').disabled = data.rows.length < 100;
    message('Tabela carregada.');
  } catch (e) { message(e.message, true); }
}
$('login-form').onsubmit = async event => {
  event.preventDefault(); $('connect').disabled = true; $('connect').textContent = 'Conectando…'; $('login-error').textContent = '';
  try {
    const formData = new FormData(event.target);
    const credentials = Object.fromEntries(formData);
    credentials.ssl = formData.has('ssl');
    const data = await api('login', credentials);
    event.target.elements.password.value = ''; $('identity').textContent = `${data.user} @ ${data.host}:${data.port}`;
    currentDatabase = data.database;
    $('login-screen').hidden = true; $('workspace').hidden = false;
    currentTable = ''; $('table-title').textContent = 'Escolha uma tabela'; $('columns').replaceChildren(); $('search').value = '';
    $('editor').value = ''; $('results').replaceChildren(); $('confirm-write').checked = false;
    await refresh();
    message(currentDatabase ? `${tables.length} tabelas disponíveis em ${currentDatabase}.` : `${databases.length} bancos disponíveis.`);
  } catch (e) { $('login-error').textContent = e.message; message(e.message, true); }
  finally { $('connect').disabled = false; $('connect').textContent = 'Conectar ao banco →'; }
};
$('database-select').onchange = async event => {
  const database = event.target.value;
  if (!database) { event.target.value = currentDatabase; return; }
  try {
    const data = await api('database', { database });
    currentDatabase = data.database; currentTable = '';
    $('table-title').textContent = 'Escolha uma tabela'; $('records').replaceChildren(); $('columns').replaceChildren();
    await refresh(); message(`${tables.length} tabelas disponíveis em ${currentDatabase}.`);
  } catch (e) { event.target.value = currentDatabase; message(e.message, true); }
};
$('logout').onclick = async () => { try { await api('logout', {}); showLogin(); } catch (e) { message(e.message, true); } };
$('refresh').onclick = () => refresh().then(() => message('Lista atualizada.')).catch(e => message(e.message, true));
$('search').oninput = renderTables;
$('previous').onclick = () => loadTable(currentTable, page - 1);
$('next').onclick = () => loadTable(currentTable, page + 1);
fetch('/api/config')
  .then(response => {
    if (!response.ok) throw new Error('Não foi possível carregar as configurações.');
    return response.json();
  })
  .then(config => {
    $('login-form').elements.host.value = config.host;
    $('login-form').elements.port.value = config.port;
    if (!config.scriptsEnabled) $('sql-tab').hidden = true;
  })
  .catch(error => message(error.message, true));
for (const name of ['browse', 'sql']) $(name + '-tab').onclick = () => {
  for (const section of ['browse', 'sql']) {
    $(section).hidden = section !== name;
    $(`${section}-tab`).classList.toggle('active', section === name);
  }
};
$('file').onchange = async event => {
  const file = event.target.files[0];
  if (!file) return;
  if (file.size > 1500000) {
    message('O arquivo deve ter até 1,5 MB.', true);
    event.target.value = '';
    return;
  }
  $('editor').value = await file.text();
  $('confirm-write').checked = false;
  message(`Arquivo ${file.name} carregado. Revise antes de executar.`);
};
$('editor').oninput = () => { $('confirm-write').checked = false; };
$('run').onclick = async () => {
  if (!$('confirm-write').checked) return message('Marque a confirmação antes de executar o script.', true);
  if (!$('editor').value.trim()) return message('Abra um arquivo .sql ou cole um script SQL.', true);
  $('run').disabled = true;
  $('results').replaceChildren();
  message('Executando script…');
  try {
    const data = await api('query', { sql: $('editor').value });
    currentDatabase = data.database;
    data.results.forEach((result, index) => {
      const title = document.createElement('h3');
      title.textContent = `Resultado ${index + 1}`;
      $('results').append(title);
      if (result.rows) {
        const note = document.createElement('p');
        note.textContent = `${result.total} linhas recebidas${result.total > 1000 ? ' · exibindo as primeiras 1.000' : ''}`;
        $('results').append(note, grid(result.rows, result.fields));
      } else {
        const note = document.createElement('p');
        note.textContent = `${result.affectedRows} linhas afetadas. ${result.info || ''}`;
        $('results').append(note);
      }
    });
    await refresh();
    message(`Script concluído em ${data.elapsed} ms. Banco atual: ${currentDatabase || 'nenhum'}.`);
  } catch (error) {
    if (typeof error.database === 'string') currentDatabase = error.database;
    let detail = '';
    try { await refresh(); } catch (refreshError) { detail = ` Não foi possível atualizar a lista: ${refreshError.message}`; }
    message(`${error.message}${detail} Alguns comandos anteriores ao erro podem já ter sido aplicados.`, true);
  } finally {
    $('run').disabled = false;
    $('confirm-write').checked = false;
  }
};
