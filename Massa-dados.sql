-- Massa de dados sinteticos para o banco ck_autoshop.
-- Execute depois de criar o schema com ck_autoshop_mysql.sql.
-- Os identificadores sao fixos para facilitar consultas e demonstracoes.
-- Os cadastros abaixo sao ficticios e servem somente para teste.

USE ck_autoshop;

START TRANSACTION;

INSERT INTO cliente
    (id_cliente, nome, documento, contato, endereco, status)
VALUES
    (1, 'Locadora Horizonte (teste)', NULL, 'Compras - (11) 90000-0001',
     'Av. Exemplo, 100 - Sao Paulo/SP', 'ativo'),
    (2, 'Frotas Estrada Azul (teste)', NULL, 'Manutencao - (11) 90000-0002',
     'Rua Ficticia, 200 - Guarulhos/SP', 'ativo'),
    (3, 'Oficina Motor & Cia (teste)', NULL, 'Oficina - (11) 90000-0003',
     'Rua das Pecas, 300 - Osasco/SP', 'ativo'),
    (4, 'Seguradora Via Segura (teste)', NULL, 'Sinistros - (11) 90000-0004',
     'Av. Modelo, 400 - Santo Andre/SP', 'ativo'),
    (5, 'Frotista Caminho Livre (teste)', NULL, 'Frota - (11) 90000-0005',
     'Rua Simulada, 500 - Sao Bernardo do Campo/SP', 'inativo');

INSERT INTO veiculo
    (id_veiculo, cliente_id, placa, marca, modelo, ano_fabricacao, ano_modelo,
     chassi, quilometragem)
VALUES
    (1, 1, 'TST1A01', 'Fiat', 'Fiorino', 2022, 2023, NULL, 45800),
    (2, 1, 'TST1A02', 'Chevrolet', 'Onix', 2021, 2022, NULL, 63200),
    (3, 2, 'TST2B01', 'Volkswagen', 'Saveiro', 2023, 2023, NULL, 28700),
    (4, 3, 'TST3C01', 'Toyota', 'Corolla', 2020, 2021, NULL, 89100),
    (5, 4, 'TST4D01', 'Hyundai', 'HB20', 2024, 2025, NULL, 12400),
    (6, 5, 'TST5E01', 'Renault', 'Kangoo', 2019, 2020, NULL, 112500);

INSERT INTO vendedor
    (id_vendedor, nome, telefone, email, cargo, comissao, data_admissao, status)
VALUES
    (1, 'Alex Silva (teste)', '(11) 90000-0101', 'alex.teste@example.invalid',
     'Vendedor', 2.50, '2022-03-14', 'ativo'),
    (2, 'Beatriz Costa (teste)', '(11) 90000-0102', 'beatriz.teste@example.invalid',
     'Vendedora', 3.00, '2023-08-01', 'ativo'),
    (3, 'Caio Mendes (teste)', '(11) 90000-0103', 'caio.teste@example.invalid',
     'Orcamentista', 2.00, '2024-01-15', 'ativo');

INSERT INTO fornecedor
    (id_fornecedor, nome, documento, contato, endereco, segmento, subsegmento, status)
VALUES
    (1, 'Distribuidora Auto Norte (teste)', NULL, 'Vendas - (11) 90000-0201',
     'Endereco ficticio, 10 - Sao Paulo/SP', 'Automotivo', 'Filtros', 'ativo'),
    (2, 'Pecas Brasil Central (teste)', NULL, 'Comercial - (11) 90000-0202',
     'Endereco ficticio, 20 - Campinas/SP', 'Automotivo', 'Freios', 'ativo'),
    (3, 'Componentes Rota Sul (teste)', NULL, 'Pedidos - (11) 90000-0203',
     'Endereco ficticio, 30 - Curitiba/PR', 'Automotivo', 'Suspensao', 'ativo'),
    (4, 'Eletrica Motor Forte (teste)', NULL, 'Atendimento - (11) 90000-0204',
     'Endereco ficticio, 40 - Sao Paulo/SP', 'Automotivo', 'Eletrica', 'ativo'),
    (5, 'Autopecas Via Leste (teste)', NULL, 'Vendas - (11) 90000-0205',
     'Endereco ficticio, 50 - Guarulhos/SP', 'Automotivo', 'Iluminacao', 'inativo');

INSERT INTO peca
    (id_peca, codigo, sku, descricao, aplicacao, marca, ncm, unidade_medida,
     localizacao_estoque, quantidade_estoque, valor_custo, valor_venda, categoria, status)
VALUES
    (1, 'TEST-BAT-001', 'SKU-TEST-BAT-001', 'Bateria automotiva 60 Ah (teste)',
     'Veiculos leves', 'Marca Ficticia', '85071090', 'UN', 'A-01-01', 8, 320.00, 449.90, 'Eletrica', 'ativo'),
    (2, 'TEST-FIL-001', 'SKU-TEST-FIL-001', 'Filtro de oleo (teste)',
     'Motores 1.0 a 2.0', 'Marca Ficticia', '84212300', 'UN', 'A-01-02', 16, 22.00, 39.90, 'Filtros', 'ativo'),
    (3, 'TEST-FRE-001', 'SKU-TEST-FRE-001', 'Disco de freio dianteiro (teste)',
     'Veiculos leves selecionados', 'Marca Ficticia', '87083090', 'UN', 'B-02-01', 2, 185.00, 279.90, 'Freios', 'ativo'),
    (4, 'TEST-SUS-001', 'SKU-TEST-SUS-001', 'Amortecedor dianteiro (teste)',
     'Veiculos leves selecionados', 'Marca Ficticia', '87088000', 'UN', 'B-02-02', 6, 240.00, 359.90, 'Suspensao', 'ativo'),
    (5, 'TEST-ILU-001', 'SKU-TEST-ILU-001', 'Farol dianteiro (teste)',
     'Veiculos leves selecionados', 'Marca Ficticia', '85122011', 'UN', 'C-03-01', 2, 410.00, 599.90, 'Iluminacao', 'ativo'),
    (6, 'TEST-EMB-001', 'SKU-TEST-EMB-001', 'Embreagem completa (teste)',
     'Veiculos leves selecionados', 'Marca Ficticia', '87089300', 'UN', 'C-03-02', 0, 520.00, 749.90, 'Transmissao', 'ativo'),
    (7, 'TEST-COR-001', 'SKU-TEST-COR-001', 'Correia dentada (teste)',
     'Motores 1.0 a 2.0', 'Marca Ficticia', '40103500', 'UN', 'D-04-01', 0, 78.00, 129.90, 'Motor', 'ativo'),
    (8, 'TEST-RET-001', 'SKU-TEST-RET-001', 'Retrovisor externo (teste)',
     'Veiculos leves selecionados', 'Marca Ficticia', '70091000', 'UN', 'D-04-02', 0, 135.00, 219.90, 'Carroceria', 'ativo'),
    (9, 'TEST-PAS-001', 'SKU-TEST-PAS-001', 'Pastilha de freio dianteira (teste)',
     'Veiculos leves selecionados', 'Marca Ficticia', '87083019', 'JG', 'B-02-03', 0, 95.00, 159.90, 'Freios', 'ativo'),
    (10, 'TEST-ALT-001', 'SKU-TEST-ALT-001', 'Alternador automotivo (teste)',
     'Veiculos leves selecionados', 'Marca Ficticia', '85115010', 'UN', 'A-01-03', 0, 390.00, 569.90, 'Eletrica', 'inativo');

INSERT INTO cotacao
    (id_cotacao, cliente_id, veiculo_id, vendedor_id, data_cotacao,
     desconto, frete, imposto, observacao, status)
VALUES
    (1, 1, 1, 1, '2026-10-19 09:15:00', 20.00, 35.00, 0.00,
     'Cotacao aprovada; pedido faturado e entregue. Dados sinteticos.', 'aprovada'),
    (2, 2, 3, 2, '2026-11-01 10:30:00', 0.00, 48.00, 0.00,
     'Pedido em separacao; entrega prevista para novembro. Dados sinteticos.', 'aprovada'),
    (3, 3, 4, 3, '2026-11-05 14:00:00', 0.00, 25.00, 0.00,
     'Aguardando retorno do cliente. Dados sinteticos.', 'enviada'),
    (4, 4, 5, 1, '2026-10-28 11:20:00', 15.00, 30.00, 0.00,
     'Proposta nao aprovada pelo cliente. Dados sinteticos.', 'reprovada'),
    (5, 1, 2, 2, '2026-11-06 08:45:00', 0.00, 0.00, 0.00,
     'Solicitacao cancelada antes do envio. Dados sinteticos.', 'cancelada');

INSERT INTO item_cotacao
    (id_item_cotacao, cotacao_id, peca_id, fornecedor_id, quantidade, custo, valor_venda)
VALUES
    (1, 1, 1, 4, 2, 320.00, 449.90),
    (2, 1, 2, 1, 4, 22.00, 39.90),
    (3, 2, 3, 2, 2, 185.00, 279.90),
    (4, 2, 5, 5, 1, 410.00, 599.90),
    (5, 3, 6, 3, 1, 520.00, 749.90),
    (6, 3, 7, 1, 2, 78.00, 129.90),
    (7, 4, 8, 5, 1, 135.00, 219.90),
    (8, 5, 9, 2, 1, 95.00, 159.90);

INSERT INTO pedido
    (id_pedido, cotacao_id, cliente_id, veiculo_id, vendedor_id, data_autorizacao,
     status, status_expedicao, endereco_entrega, valor_frete, observacao)
VALUES
    (1, 1, 1, 1, 1, '2026-10-20 13:00:00', 'entregue', 'despachado',
     'Av. Exemplo, 100 - Sao Paulo/SP', 35.00, 'Pedido de demonstracao entregue.'),
    (2, 2, 2, 3, 2, '2026-11-02 09:00:00', 'em_andamento', 'em_separacao',
     'Rua Ficticia, 200 - Guarulhos/SP', 48.00, 'Pedido de demonstracao em andamento.');

INSERT INTO item_pedido
    (id_item_pedido, pedido_id, peca_id, fornecedor_id, quantidade, valor_custo,
     valor_venda, valor_extra, status, data_prevista_entrega, data_recebimento,
     situacao_compra_recebimento)
VALUES
    (1, 1, 1, 4, 2, 320.00, 449.90, 0.00, 'entregue', '2026-10-22', '2026-10-21', 'recebido_conferido'),
    (2, 1, 2, 1, 4, 22.00, 39.90, 0.00, 'entregue', '2026-10-22', '2026-10-22', 'recebido_conferido'),
    (3, 2, 3, 2, 2, 185.00, 279.90, 5.00, 'separacao', '2026-11-06', '2026-11-05', 'recebido_conferido'),
    (4, 2, 5, 5, 1, 410.00, 599.90, 0.00, 'aguardando_fornecedor', '2026-11-10', NULL, 'aguardando');

INSERT INTO movimento_estoque
    (id_movimento, peca_id, item_pedido_id, tipo_movimentacao, quantidade,
     data_cadastro, motivo, observacao)
VALUES
    (1, 1, 1, 'entrada', 10, '2026-10-21 10:00:00', 'Recebimento de fornecedor', 'Entrada conferida; dados sinteticos.'),
    (2, 1, 1, 'saida', 2, '2026-10-23 15:00:00', 'Atendimento de pedido', 'Saida vinculada ao pedido 1.'),
    (3, 2, 2, 'entrada', 20, '2026-10-22 09:00:00', 'Recebimento de fornecedor', 'Entrada conferida; dados sinteticos.'),
    (4, 2, 2, 'saida', 4, '2026-10-23 15:10:00', 'Atendimento de pedido', 'Saida vinculada ao pedido 1.'),
    (5, 3, 3, 'entrada', 4, '2026-11-05 11:30:00', 'Recebimento de fornecedor', 'Entrada conferida; dados sinteticos.'),
    (6, 3, 3, 'saida', 2, '2026-11-06 09:00:00', 'Atendimento de pedido', 'Saida vinculada ao pedido 2.'),
    (7, 5, 4, 'entrada', 3, '2026-11-06 10:00:00', 'Recebimento parcial', 'Recebimento conferido; dados sinteticos.'),
    (8, 5, 4, 'saida', 1, '2026-11-06 10:30:00', 'Atendimento de pedido', 'Saida parcial vinculada ao pedido 2.'),
    (9, 4, NULL, 'entrada', 6, '2026-10-01 08:00:00', 'Saldo inicial de estoque', 'Saldo de abertura sintetico.');

INSERT INTO nota_fiscal
    (id_nota_fiscal, pedido_id, numero, serie, data_emissao, data_operacao,
     valor_nota, valor_frete, tipo, situacao, chave_acesso, desconto,
     valor_liquido, data_vencimento, data_pagamento)
VALUES
    (1, 1, 'TESTE-0001', '1', '2026-10-23', '2026-10-23',
     1059.40, 35.00, 'saida', 'paga', NULL, 20.00, 1074.40, '2026-11-07', '2026-11-05'),
    (2, 2, 'TESTE-0002', '1', '2026-11-06', '2026-11-06',
     1159.70, 48.00, 'saida', 'a_vencer', NULL, 0.00, 1207.70, '2026-11-20', NULL);

INSERT INTO frete
    (id_frete, pedido_id, placa, transportadora, endereco_entrega, prazo_entrega,
     data_entrega, municipio_entrega, contato_nome, contato_telefone, status)
VALUES
    (1, 1, 'ABC1D23', 'Transportadora Exemplo (teste)',
     'Av. Exemplo, 100 - Sao Paulo/SP', '2026-10-25', '2026-10-24',
     'Sao Paulo/SP', 'Recebimento - contato ficticio', '(11) 90000-0301', 'entregue'),
    (2, 2, 'DEF4G56', 'Logistica Modelo (teste)',
     'Rua Ficticia, 200 - Guarulhos/SP', '2026-11-10', NULL,
     'Guarulhos/SP', 'Recebimento - contato ficticio', '(11) 90000-0302', 'em_transito');

INSERT INTO devolucao_garantia
    (id_devolucao, pedido_id, tipo, status, motivo, descricao, observacoes, data)
VALUES
    (1, 1, 'garantia', 'em_analise', 'Falha apos instalacao',
     'Ocorrencia de demonstracao vinculada a uma bateria do pedido.',
     'Aguardando avaliacao tecnica; registro sintetico.', '2026-10-29 10:15:00'),
    (2, 2, 'devolucao', 'aberta', 'Peca recebida com avaria',
     'Ocorrencia de demonstracao vinculada a um disco de freio do pedido.',
     'Aguardando conferencia da ocorrencia; registro sintetico.', '2026-11-06 12:00:00');

COMMIT;

-- Consultas de verificacao para demonstracao:
-- SELECT * FROM cotacao ORDER BY id_cotacao;
-- SELECT * FROM pedido ORDER BY id_pedido;
-- SELECT p.id_peca, p.codigo, p.quantidade_estoque,
--        SUM(CASE WHEN m.tipo_movimentacao = 'entrada' THEN m.quantidade
--                 ELSE -m.quantidade END) AS saldo_movimentacoes
-- FROM peca p
-- LEFT JOIN movimento_estoque m ON m.peca_id = p.id_peca
-- GROUP BY p.id_peca, p.codigo, p.quantidade_estoque
-- ORDER BY p.id_peca;
