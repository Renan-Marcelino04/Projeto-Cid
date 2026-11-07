Banco de dados da CK Autoshop
-- Requer MySQL 8.0.16+ (para que as restricoes CHECK sejam aplicadas).
-- Modelo baseado no Levantamento e no README; Ordem de Compra nao foi incluida.

CREATE DATABASE IF NOT EXISTS ck_autoshop
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE ck_autoshop;

CREATE TABLE cliente (
    id_cliente BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome VARCHAR(180) NOT NULL,
    documento VARCHAR(20) NULL,
    contato VARCHAR(180) NULL,
    endereco VARCHAR(500) NULL,
    status VARCHAR(20) NOT NULL,
    PRIMARY KEY (id_cliente),
    UNIQUE KEY uk_cliente_documento (documento)
) ENGINE = InnoDB;

CREATE TABLE veiculo (
    id_veiculo BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    cliente_id BIGINT UNSIGNED NOT NULL,
    placa VARCHAR(10) NOT NULL,
    marca VARCHAR(100) NOT NULL,
    modelo VARCHAR(120) NOT NULL,
    ano_fabricacao SMALLINT UNSIGNED NULL,
    ano_modelo SMALLINT UNSIGNED NULL,
    chassi VARCHAR(30) NULL,
    quilometragem INT UNSIGNED NULL,
    PRIMARY KEY (id_veiculo),
    UNIQUE KEY uk_veiculo_placa (placa),
    UNIQUE KEY uk_veiculo_chassi (chassi),
    UNIQUE KEY uk_veiculo_cliente (id_veiculo, cliente_id),
    CONSTRAINT fk_veiculo_cliente
        FOREIGN KEY (cliente_id) REFERENCES cliente (id_cliente)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_veiculo_anos
        CHECK (
            (ano_fabricacao IS NULL OR ano_modelo IS NULL)
            OR ano_modelo >= ano_fabricacao
        )
) ENGINE = InnoDB;

CREATE TABLE vendedor (
    id_vendedor BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome VARCHAR(180) NOT NULL,
    telefone VARCHAR(30) NULL,
    email VARCHAR(254) NULL,
    cargo VARCHAR(100) NULL,
    comissao DECIMAL(8, 2) NULL,
    data_admissao DATE NULL,
    status VARCHAR(20) NOT NULL,
    PRIMARY KEY (id_vendedor),
    UNIQUE KEY uk_vendedor_email (email),
    CONSTRAINT chk_vendedor_comissao
        CHECK (comissao IS NULL OR comissao >= 0)
) ENGINE = InnoDB;

CREATE TABLE fornecedor (
    id_fornecedor BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome VARCHAR(180) NOT NULL,
    documento VARCHAR(20) NULL,
    contato VARCHAR(180) NULL,
    endereco VARCHAR(500) NULL,
    segmento VARCHAR(100) NULL,
    subsegmento VARCHAR(100) NULL,
    status VARCHAR(20) NOT NULL,
    PRIMARY KEY (id_fornecedor),
    UNIQUE KEY uk_fornecedor_documento (documento)
) ENGINE = InnoDB;

CREATE TABLE peca (
    id_peca BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    codigo VARCHAR(60) NOT NULL,
    sku VARCHAR(80) NULL,
    descricao VARCHAR(255) NOT NULL,
    aplicacao TEXT NULL,
    marca VARCHAR(100) NULL,
    ncm VARCHAR(10) NULL,
    unidade_medida VARCHAR(20) NOT NULL,
    localizacao_estoque VARCHAR(120) NULL,
    quantidade_estoque DECIMAL(12, 3) NOT NULL DEFAULT 0,
    valor_custo DECIMAL(13, 2) NOT NULL DEFAULT 0,
    valor_venda DECIMAL(13, 2) NOT NULL DEFAULT 0,
    categoria VARCHAR(100) NULL,
    status VARCHAR(20) NOT NULL,
    PRIMARY KEY (id_peca),
    UNIQUE KEY uk_peca_codigo (codigo),
    UNIQUE KEY uk_peca_sku (sku),
    CONSTRAINT chk_peca_quantidade_estoque CHECK (quantidade_estoque >= 0),
    CONSTRAINT chk_peca_valor_custo CHECK (valor_custo >= 0),
    CONSTRAINT chk_peca_valor_venda CHECK (valor_venda >= 0)
) ENGINE = InnoDB;

CREATE TABLE cotacao (
    id_cotacao BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    cliente_id BIGINT UNSIGNED NOT NULL,
    veiculo_id BIGINT UNSIGNED NULL,
    vendedor_id BIGINT UNSIGNED NOT NULL,
    data_cotacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    desconto DECIMAL(13, 2) NOT NULL DEFAULT 0,
    frete DECIMAL(13, 2) NOT NULL DEFAULT 0,
    imposto DECIMAL(13, 2) NOT NULL DEFAULT 0,
    observacao TEXT NULL,
    status ENUM('pendente', 'enviada', 'aprovada', 'reprovada', 'cancelada')
        NOT NULL DEFAULT 'pendente',
    PRIMARY KEY (id_cotacao),
    UNIQUE KEY uk_cotacao_origem_pedido (id_cotacao, cliente_id, vendedor_id),
    KEY idx_cotacao_cliente_data (cliente_id, data_cotacao),
    KEY idx_cotacao_status_data (status, data_cotacao),
    CONSTRAINT fk_cotacao_cliente
        FOREIGN KEY (cliente_id) REFERENCES cliente (id_cliente)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_cotacao_veiculo_cliente
        FOREIGN KEY (veiculo_id, cliente_id)
        REFERENCES veiculo (id_veiculo, cliente_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_cotacao_vendedor
        FOREIGN KEY (vendedor_id) REFERENCES vendedor (id_vendedor)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_cotacao_valores
        CHECK (desconto >= 0 AND frete >= 0 AND imposto >= 0)
) ENGINE = InnoDB;

CREATE TABLE item_cotacao (
    id_item_cotacao BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    cotacao_id BIGINT UNSIGNED NOT NULL,
    peca_id BIGINT UNSIGNED NOT NULL,
    fornecedor_id BIGINT UNSIGNED NOT NULL,
    quantidade DECIMAL(12, 3) NOT NULL,
    custo DECIMAL(13, 2) NOT NULL,
    valor_venda DECIMAL(13, 2) NOT NULL,
    PRIMARY KEY (id_item_cotacao),
    KEY idx_item_cotacao_cotacao (cotacao_id),
    KEY idx_item_cotacao_peca (peca_id),
    KEY idx_item_cotacao_fornecedor (fornecedor_id),
    CONSTRAINT fk_item_cotacao_cotacao
        FOREIGN KEY (cotacao_id) REFERENCES cotacao (id_cotacao)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_item_cotacao_peca
        FOREIGN KEY (peca_id) REFERENCES peca (id_peca)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_item_cotacao_fornecedor
        FOREIGN KEY (fornecedor_id) REFERENCES fornecedor (id_fornecedor)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_item_cotacao_valores
        CHECK (quantidade > 0 AND custo >= 0 AND valor_venda >= 0)
) ENGINE = InnoDB;

CREATE TABLE pedido (
    id_pedido BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    cotacao_id BIGINT UNSIGNED NOT NULL,
    cliente_id BIGINT UNSIGNED NOT NULL,
    veiculo_id BIGINT UNSIGNED NULL,
    vendedor_id BIGINT UNSIGNED NOT NULL,
    data_autorizacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(40) NOT NULL,
    status_expedicao VARCHAR(40) NOT NULL,
    endereco_entrega VARCHAR(500) NULL,
    valor_frete DECIMAL(13, 2) NOT NULL DEFAULT 0,
    observacao TEXT NULL,
    PRIMARY KEY (id_pedido),
    UNIQUE KEY uk_pedido_cotacao (cotacao_id),
    KEY idx_pedido_cliente_data (cliente_id, data_autorizacao),
    KEY idx_pedido_status_data (status, data_autorizacao),
    CONSTRAINT fk_pedido_cotacao_origem
        FOREIGN KEY (cotacao_id, cliente_id, vendedor_id)
        REFERENCES cotacao (id_cotacao, cliente_id, vendedor_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_pedido_veiculo_cliente
        FOREIGN KEY (veiculo_id, cliente_id)
        REFERENCES veiculo (id_veiculo, cliente_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_pedido_valor_frete CHECK (valor_frete >= 0)
) ENGINE = InnoDB;

CREATE TABLE item_pedido (
    id_item_pedido BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    pedido_id BIGINT UNSIGNED NOT NULL,
    peca_id BIGINT UNSIGNED NOT NULL,
    fornecedor_id BIGINT UNSIGNED NULL,
    quantidade DECIMAL(12, 3) NOT NULL,
    valor_custo DECIMAL(13, 2) NOT NULL,
    valor_venda DECIMAL(13, 2) NOT NULL,
    valor_extra DECIMAL(13, 2) NOT NULL DEFAULT 0,
    status VARCHAR(40) NOT NULL,
    data_prevista_entrega DATE NULL,
    data_recebimento DATE NULL,
    situacao_compra_recebimento VARCHAR(40) NULL,
    PRIMARY KEY (id_item_pedido),
    KEY idx_item_pedido_pedido (pedido_id),
    KEY idx_item_pedido_peca (peca_id),
    KEY idx_item_pedido_fornecedor_entrega (fornecedor_id, data_prevista_entrega),
    CONSTRAINT fk_item_pedido_pedido
        FOREIGN KEY (pedido_id) REFERENCES pedido (id_pedido)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_item_pedido_peca
        FOREIGN KEY (peca_id) REFERENCES peca (id_peca)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_item_pedido_fornecedor
        FOREIGN KEY (fornecedor_id) REFERENCES fornecedor (id_fornecedor)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_item_pedido_valores
        CHECK (
            quantidade > 0
            AND valor_custo >= 0
            AND valor_venda >= 0
            AND valor_extra >= 0
        )
) ENGINE = InnoDB;

CREATE TABLE movimento_estoque (
    id_movimento BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    peca_id BIGINT UNSIGNED NOT NULL,
    item_pedido_id BIGINT UNSIGNED NULL,
    tipo_movimentacao ENUM('entrada', 'saida') NOT NULL,
    quantidade DECIMAL(12, 3) NOT NULL,
    data_cadastro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    motivo VARCHAR(180) NOT NULL,
    observacao TEXT NULL,
    PRIMARY KEY (id_movimento),
    KEY idx_movimento_peca_data (peca_id, data_cadastro),
    KEY idx_movimento_item_pedido (item_pedido_id),
    CONSTRAINT fk_movimento_peca
        FOREIGN KEY (peca_id) REFERENCES peca (id_peca)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_movimento_item_pedido
        FOREIGN KEY (item_pedido_id) REFERENCES item_pedido (id_item_pedido)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_movimento_quantidade CHECK (quantidade > 0)
) ENGINE = InnoDB;

CREATE TABLE nota_fiscal (
    id_nota_fiscal BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    pedido_id BIGINT UNSIGNED NOT NULL,
    numero VARCHAR(30) NOT NULL,
    serie VARCHAR(10) NOT NULL,
    data_emissao DATE NOT NULL,
    data_operacao DATE NULL,
    valor_nota DECIMAL(13, 2) NOT NULL,
    valor_frete DECIMAL(13, 2) NOT NULL DEFAULT 0,
    tipo VARCHAR(30) NOT NULL,
    situacao VARCHAR(40) NOT NULL,
    chave_acesso CHAR(44) NULL,
    desconto DECIMAL(13, 2) NOT NULL DEFAULT 0,
    valor_liquido DECIMAL(13, 2) NULL,
    data_vencimento DATE NULL,
    data_pagamento DATE NULL,
    PRIMARY KEY (id_nota_fiscal),
    UNIQUE KEY uk_nota_fiscal_numero_serie (numero, serie),
    UNIQUE KEY uk_nota_fiscal_chave (chave_acesso),
    KEY idx_nota_fiscal_pedido (pedido_id),
    KEY idx_nota_fiscal_financeiro (situacao, data_vencimento),
    CONSTRAINT fk_nota_fiscal_pedido
        FOREIGN KEY (pedido_id) REFERENCES pedido (id_pedido)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_nota_fiscal_valores
        CHECK (
            valor_nota >= 0
            AND valor_frete >= 0
            AND desconto >= 0
            AND (valor_liquido IS NULL OR valor_liquido >= 0)
        )
) ENGINE = InnoDB;

CREATE TABLE frete (
    id_frete BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    pedido_id BIGINT UNSIGNED NOT NULL,
    placa VARCHAR(10) NULL,
    transportadora VARCHAR(180) NULL,
    endereco_entrega VARCHAR(500) NULL,
    prazo_entrega DATE NULL,
    data_entrega DATE NULL,
    municipio_entrega VARCHAR(120) NULL,
    contato_nome VARCHAR(180) NULL,
    contato_telefone VARCHAR(30) NULL,
    status VARCHAR(40) NOT NULL,
    PRIMARY KEY (id_frete),
    KEY idx_frete_pedido (pedido_id),
    KEY idx_frete_prazo_status (prazo_entrega, status),
    CONSTRAINT fk_frete_pedido
        FOREIGN KEY (pedido_id) REFERENCES pedido (id_pedido)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

CREATE TABLE devolucao_garantia (
    id_devolucao BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    pedido_id BIGINT UNSIGNED NOT NULL,
    tipo VARCHAR(40) NOT NULL,
    status VARCHAR(40) NOT NULL,
    motivo VARCHAR(180) NOT NULL,
    descricao TEXT NULL,
    observacoes TEXT NULL,
    data DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_devolucao),
    KEY idx_devolucao_pedido_data (pedido_id, data),
    KEY idx_devolucao_status_data (status, data),
    CONSTRAINT fk_devolucao_pedido
        FOREIGN KEY (pedido_id) REFERENCES pedido (id_pedido)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;
