CREATE SCHEMA IF NOT EXISTS projeto_ecommerce;

CREATE TABLE projeto_ecommerce.empresa (
    id_empresa BIGINT GENERATED ALWAYS AS IDENTITY,
    nome_fantasia VARCHAR(150) NOT NULL,
    razao_social VARCHAR(200) NOT NULL,
    cnpj VARCHAR(18) NOT NULL UNIQUE,
    endereco_id BIGINT,

    CONSTRAINT empresa_pkey
        PRIMARY KEY (id_empresa)
);
CREATE TABLE projeto_ecommerce.cliente (
    id_cliente BIGINT GENERATED ALWAYS AS IDENTITY,
    nome_cliente VARCHAR(150) NOT NULL,
    email_cliente VARCHAR(150) NOT NULL,
    cpf_cliente VARCHAR(14) NOT NULL,
    telefone_cliente VARCHAR(20) NOT NULL,
    genero VARCHAR(30),
    data_cadastro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT cliente_pkey
        PRIMARY KEY (id_cliente),

    CONSTRAINT cliente_email_unique
        UNIQUE (email_cliente),

    CONSTRAINT cliente_cpf_unique
        UNIQUE (cpf_cliente)
);


CREATE TABLE projeto_ecommerce.endereco (
    id_endereco BIGINT GENERATED ALWAYS AS IDENTITY,
    uf CHAR(2) NOT NULL,
    cep VARCHAR(9) NOT NULL,
    rua VARCHAR(150) NOT NULL,
    numero VARCHAR(20) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    complemento VARCHAR(100),
    cliente_id BIGINT NOT NULL,
    pais VARCHAR(50) NOT NULL DEFAULT 'Brasil',
    bairro VARCHAR(100) NOT NULL,

    CONSTRAINT endereco_pkey
        PRIMARY KEY (id_endereco),

    CONSTRAINT endereco_cliente_fkey
        FOREIGN KEY (cliente_id)
        REFERENCES projeto_ecommerce.cliente(id_cliente)
);


ALTER TABLE projeto_ecommerce.empresa
ADD CONSTRAINT empresa_endereco_fkey
FOREIGN KEY (endereco_id)
REFERENCES projeto_ecommerce.endereco(id_endereco);


CREATE TABLE projeto_ecommerce.fornecedor (
    id_fornecedor BIGINT GENERATED ALWAYS AS IDENTITY,
    razao_social VARCHAR(200) NOT NULL,
    nome_fantasia VARCHAR(150) NOT NULL,
    cnpj VARCHAR(18) NOT NULL,
    inscricao_estadual VARCHAR(30) NOT NULL,
    status_fornecedor VARCHAR(30) NOT NULL,
    cep_fornecedor VARCHAR(9) NOT NULL,
    uf_fornecedor CHAR(2) NOT NULL,
    cidade_fornecedor VARCHAR(100) NOT NULL,
    email_fornecedor VARCHAR(150) NOT NULL,
    telefone_fornecedor VARCHAR(20) NOT NULL,

    CONSTRAINT fornecedor_pkey
        PRIMARY KEY (id_fornecedor),

    CONSTRAINT fornecedor_cnpj_unique
        UNIQUE (cnpj),

    CONSTRAINT fornecedor_status_check
        CHECK (
            status_fornecedor IN (
                'ATIVO',
                'INATIVO',
                'BLOQUEADO'
            )
        )
);


CREATE TABLE projeto_ecommerce.marca (
    id_marca BIGINT GENERATED ALWAYS AS IDENTITY,
    nome_marca VARCHAR(100) NOT NULL,
    fornecedor_id BIGINT NOT NULL,

    CONSTRAINT marca_pkey
        PRIMARY KEY (id_marca),

    CONSTRAINT marca_fornecedor_fkey
        FOREIGN KEY (fornecedor_id)
        REFERENCES projeto_ecommerce.fornecedor(id_fornecedor),

    CONSTRAINT marca_fornecedor_unique
        UNIQUE (nome_marca, fornecedor_id)
);


CREATE TABLE projeto_ecommerce.produto (
    id_produto BIGINT GENERATED ALWAYS AS IDENTITY,
    marca_id BIGINT NOT NULL,
    categoria VARCHAR(100) NOT NULL,
    nome_produto VARCHAR(200) NOT NULL,
    peso_kg NUMERIC(10,3) NOT NULL,
    altura_cm NUMERIC(10,2) NOT NULL,
    largura_cm NUMERIC(10,2) NOT NULL,
    comprimento_cm NUMERIC(10,2) NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    data_cadastro_erp DATE NOT NULL DEFAULT CURRENT_DATE,

    CONSTRAINT produto_pkey
        PRIMARY KEY (id_produto),

    CONSTRAINT produto_marca_fkey
        FOREIGN KEY (marca_id)
        REFERENCES projeto_ecommerce.marca(id_marca),

    CONSTRAINT produto_peso_check
        CHECK (peso_kg >= 0),

    CONSTRAINT produto_altura_check
        CHECK (altura_cm > 0),

    CONSTRAINT produto_largura_check
        CHECK (largura_cm > 0),

    CONSTRAINT produto_comprimento_check
        CHECK (comprimento_cm > 0)
);


CREATE TABLE projeto_ecommerce.sku (
    id_sku BIGINT GENERATED ALWAYS AS IDENTITY,
    sku_pai VARCHAR(50) NOT NULL,
    sku_filho VARCHAR(50) NOT NULL,
    tamanho VARCHAR(30) NOT NULL,
    cor VARCHAR(50) NOT NULL,
    ultima_atualizacao_em DATE NOT NULL DEFAULT CURRENT_DATE,
    produto_id BIGINT NOT NULL,
    ncm VARCHAR(20) NOT NULL,
    genero VARCHAR(30) NOT NULL,

    CONSTRAINT sku_pkey
        PRIMARY KEY (id_sku),

    CONSTRAINT sku_filho_unique
        UNIQUE (sku_filho),

    CONSTRAINT sku_produto_fkey
        FOREIGN KEY (produto_id)
        REFERENCES projeto_ecommerce.produto(id_produto),

    CONSTRAINT sku_variacao_unique
        UNIQUE (produto_id, tamanho, cor)
);


CREATE TABLE projeto_ecommerce.marketplace (
    id_marketplace BIGINT GENERATED ALWAYS AS IDENTITY,
    nome_marketplace VARCHAR(100) NOT NULL,
    status_marketplace VARCHAR(30) NOT NULL,

    CONSTRAINT marketplace_pkey
        PRIMARY KEY (id_marketplace),

    CONSTRAINT marketplace_nome_unique
        UNIQUE (nome_marketplace),

    CONSTRAINT marketplace_status_check
        CHECK (
            status_marketplace IN (
                'ATIVO',
                'INATIVO'
            )
        )
);


CREATE TABLE projeto_ecommerce.estoque (
    id_estoque BIGINT GENERATED ALWAYS AS IDENTITY,
    empresa_id BIGINT NOT NULL,
    sku_id BIGINT NOT NULL,
    id_produto_erp BIGINT NOT NULL,
    descricao_produto_erp VARCHAR(200) NOT NULL,
    categoria_erp VARCHAR(100) NOT NULL,
    custo_unitario NUMERIC(12,2) NOT NULL,
    custo_medio NUMERIC(12,2) NOT NULL,
    preco_venda_sugerido NUMERIC(12,2) NOT NULL,
    estoque_fisico INTEGER NOT NULL DEFAULT 0,
    estoque_reservado INTEGER NOT NULL DEFAULT 0,
    estoque_minimo INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT estoque_pkey
        PRIMARY KEY (id_estoque),

    CONSTRAINT estoque_empresa_fkey
        FOREIGN KEY (empresa_id)
        REFERENCES projeto_ecommerce.empresa(id_empresa),

    CONSTRAINT estoque_sku_fkey
        FOREIGN KEY (sku_id)
        REFERENCES projeto_ecommerce.sku(id_sku),

    CONSTRAINT estoque_custo_unitario_check
        CHECK (custo_unitario >= 0),

    CONSTRAINT estoque_custo_medio_check
        CHECK (custo_medio >= 0),

    CONSTRAINT estoque_preco_check
        CHECK (preco_venda_sugerido >= 0),

    CONSTRAINT estoque_fisico_check
        CHECK (estoque_fisico >= 0),

    CONSTRAINT estoque_reservado_check
        CHECK (estoque_reservado >= 0),

    CONSTRAINT estoque_minimo_check
        CHECK (estoque_minimo >= 0),

    CONSTRAINT estoque_reserva_check
        CHECK (estoque_reservado <= estoque_fisico),

    CONSTRAINT estoque_empresa_sku_unique
        UNIQUE (empresa_id, sku_id)
);


CREATE TABLE projeto_ecommerce.anuncio (
    id_anuncio BIGINT GENERATED ALWAYS AS IDENTITY,
    status_anuncio VARCHAR(30) NOT NULL,
    data_publicacao DATE NOT NULL,
    estoque_marketplace INTEGER NOT NULL DEFAULT 0,
    data_ultima_atualizacao DATE NOT NULL DEFAULT CURRENT_DATE,
    sku_id BIGINT NOT NULL,
    marketplace_id BIGINT NOT NULL,
    empresa_id BIGINT NOT NULL,
    titulo_anuncio VARCHAR(250) NOT NULL,
    descricao_anuncio TEXT NOT NULL,
    tipo_anuncio VARCHAR(50) NOT NULL,
    visitas_totais BIGINT NOT NULL DEFAULT 0,
    vendas_anuncio BIGINT NOT NULL DEFAULT 0,
    reputacao INTEGER NOT NULL,
    categoria_anuncio VARCHAR(100) NOT NULL,

    CONSTRAINT anuncio_pkey
        PRIMARY KEY (id_anuncio),

    CONSTRAINT anuncio_sku_fkey
        FOREIGN KEY (sku_id)
        REFERENCES projeto_ecommerce.sku(id_sku),

    CONSTRAINT anuncio_marketplace_fkey
        FOREIGN KEY (marketplace_id)
        REFERENCES projeto_ecommerce.marketplace(id_marketplace),

    CONSTRAINT anuncio_empresa_fkey
        FOREIGN KEY (empresa_id)
        REFERENCES projeto_ecommerce.empresa(id_empresa),

    CONSTRAINT anuncio_estoque_check
        CHECK (estoque_marketplace >= 0),

    CONSTRAINT anuncio_visitas_check
        CHECK (visitas_totais >= 0),

    CONSTRAINT anuncio_vendas_check
        CHECK (vendas_anuncio >= 0),

    CONSTRAINT anuncio_reputacao_check
        CHECK (reputacao BETWEEN 0 AND 5),

    CONSTRAINT anuncio_sku_marketplace_empresa_unique
        UNIQUE (sku_id, marketplace_id, empresa_id)
);


CREATE TABLE projeto_ecommerce.imposto_regra (
    id_imposto_regra BIGINT GENERATED ALWAYS AS IDENTITY,
    estado_origem CHAR(2) NOT NULL,
    estado_destino CHAR(2) NOT NULL,
    icms NUMERIC(5,2) NOT NULL,
    pis NUMERIC(5,2) NOT NULL,
    cofins NUMERIC(5,2) NOT NULL,

    CONSTRAINT imposto_regra_pkey
        PRIMARY KEY (id_imposto_regra),

    CONSTRAINT imposto_icms_check
        CHECK (icms >= 0 AND icms <= 100),

    CONSTRAINT imposto_pis_check
        CHECK (pis >= 0 AND pis <= 100),

    CONSTRAINT imposto_cofins_check
        CHECK (cofins >= 0 AND cofins <= 100),

    CONSTRAINT imposto_origem_destino_unique
        UNIQUE (estado_origem, estado_destino)
);


CREATE TABLE projeto_ecommerce.pagamento (
    id_pagamento BIGINT GENERATED ALWAYS AS IDENTITY,
    status_pagamento VARCHAR(30) NOT NULL,
    tipo_pagamento VARCHAR(50) NOT NULL,
    valor_pago NUMERIC(12,2) NOT NULL,
    aprovado_at TIMESTAMP,
    atualizado_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pagamento_pkey
        PRIMARY KEY (id_pagamento),

    CONSTRAINT pagamento_status_check
        CHECK (
            status_pagamento IN (
                'PENDENTE',
                'APROVADO',
                'RECUSADO',
                'ESTORNADO',
                'CANCELADO'
            )
        ),

    CONSTRAINT pagamento_valor_check
        CHECK (valor_pago >= 0)
);


CREATE TABLE projeto_ecommerce.pedido (
    id_pedido BIGINT GENERATED ALWAYS AS IDENTITY,
    id_pedido_marketplace VARCHAR(100),
    status_pedido VARCHAR(30) NOT NULL,
    origem_venda VARCHAR(50) NOT NULL,
    status_faturamento VARCHAR(30) NOT NULL,
    data_pedido DATE NOT NULL,
    data_aprovacao DATE,
    data_cancelamento DATE,
    valor_total_bruto NUMERIC(12,2) NOT NULL,
    valor_total_liquido NUMERIC(12,2) NOT NULL,
    moeda CHAR(3) NOT NULL DEFAULT 'BRL',
    cliente_id BIGINT NOT NULL,
    endereco_id BIGINT NOT NULL,
    marketplace_id BIGINT,
    imposto_regra_id BIGINT NOT NULL,
    lucro NUMERIC(12,2) NOT NULL,
    lucro_percentual NUMERIC(7,2) NOT NULL,
    frete NUMERIC(12,2) NOT NULL DEFAULT 0,
    rebate_mkt NUMERIC(12,2) NOT NULL DEFAULT 0,
    pagamento_id BIGINT NOT NULL,

    CONSTRAINT pedido_pkey
        PRIMARY KEY (id_pedido),

    CONSTRAINT pedido_cliente_fkey
        FOREIGN KEY (cliente_id)
        REFERENCES projeto_ecommerce.cliente(id_cliente),

    CONSTRAINT pedido_endereco_fkey
        FOREIGN KEY (endereco_id)
        REFERENCES projeto_ecommerce.endereco(id_endereco),

    CONSTRAINT pedido_marketplace_fkey
        FOREIGN KEY (marketplace_id)
        REFERENCES projeto_ecommerce.marketplace(id_marketplace),

    CONSTRAINT pedido_imposto_fkey
        FOREIGN KEY (imposto_regra_id)
        REFERENCES projeto_ecommerce.imposto_regra(id_imposto_regra),

    CONSTRAINT pedido_pagamento_fkey
        FOREIGN KEY (pagamento_id)
        REFERENCES projeto_ecommerce.pagamento(id_pagamento),

    CONSTRAINT pedido_valor_bruto_check
        CHECK (valor_total_bruto >= 0),

    CONSTRAINT pedido_valor_liquido_check
        CHECK (valor_total_liquido >= 0),

    CONSTRAINT pedido_frete_check
        CHECK (frete >= 0),

    CONSTRAINT pedido_rebate_check
        CHECK (rebate_mkt >= 0),

    CONSTRAINT pedido_lucro_percentual_check
        CHECK (lucro_percentual >= 0),

    CONSTRAINT pedido_status_check
        CHECK (
            status_pedido IN (
                'PENDENTE',
                'APROVADO',
                'FATURADO',
                'ENVIADO',
                'ENTREGUE',
                'CANCELADO'
            )
        ),

    CONSTRAINT pedido_faturamento_check
        CHECK (
            status_faturamento IN (
                'PENDENTE',
                'FATURADO',
                'CANCELADO'
            )
        ),

    CONSTRAINT pedido_datas_check
        CHECK (
            data_cancelamento IS NULL
            OR data_cancelamento >= data_pedido
        ),

    CONSTRAINT pedido_aprovacao_check
        CHECK (
            data_aprovacao IS NULL
            OR data_aprovacao >= data_pedido
        )
);


CREATE TABLE projeto_ecommerce.pedido_item (
    id_pedido_item BIGINT GENERATED ALWAYS AS IDENTITY,
    quantidade INTEGER NOT NULL,
    preco_unitario NUMERIC(12,2) NOT NULL,
    pedido_id BIGINT NOT NULL,
    anuncio_id BIGINT NOT NULL,

    CONSTRAINT pedido_item_pkey
        PRIMARY KEY (id_pedido_item),

    CONSTRAINT pedido_item_pedido_fkey
        FOREIGN KEY (pedido_id)
        REFERENCES projeto_ecommerce.pedido(id_pedido),

    CONSTRAINT pedido_item_anuncio_fkey
        FOREIGN KEY (anuncio_id)
        REFERENCES projeto_ecommerce.anuncio(id_anuncio),

    CONSTRAINT pedido_item_quantidade_check
        CHECK (quantidade > 0),

    CONSTRAINT pedido_item_preco_check
        CHECK (preco_unitario >= 0),

    CONSTRAINT pedido_item_pedido_anuncio_unique
        UNIQUE (pedido_id, anuncio_id)
);


CREATE INDEX idx_endereco_cliente
ON projeto_ecommerce.endereco(cliente_id);

CREATE INDEX idx_marca_fornecedor
ON projeto_ecommerce.marca(fornecedor_id);

CREATE INDEX idx_produto_marca
ON projeto_ecommerce.produto(marca_id);

CREATE INDEX idx_sku_produto
ON projeto_ecommerce.sku(produto_id);

CREATE INDEX idx_estoque_empresa
ON projeto_ecommerce.estoque(empresa_id);

CREATE INDEX idx_estoque_sku
ON projeto_ecommerce.estoque(sku_id);

CREATE INDEX idx_anuncio_sku
ON projeto_ecommerce.anuncio(sku_id);

CREATE INDEX idx_anuncio_marketplace
ON projeto_ecommerce.anuncio(marketplace_id);

CREATE INDEX idx_anuncio_empresa
ON projeto_ecommerce.anuncio(empresa_id);

CREATE INDEX idx_pedido_cliente
ON projeto_ecommerce.pedido(cliente_id);

CREATE INDEX idx_pedido_endereco
ON projeto_ecommerce.pedido(endereco_id);

CREATE INDEX idx_pedido_marketplace
ON projeto_ecommerce.pedido(marketplace_id);

CREATE INDEX idx_pedido_data
ON projeto_ecommerce.pedido(data_pedido);

CREATE INDEX idx_pedido_status
ON projeto_ecommerce.pedido(status_pedido);

CREATE INDEX idx_pedido_pagamento
ON projeto_ecommerce.pedido(pagamento_id);

CREATE INDEX idx_pedido_item_pedido
ON projeto_ecommerce.pedido_item(pedido_id);

CREATE INDEX idx_pedido_item_anuncio
ON projeto_ecommerce.pedido_item(anuncio_id);


CREATE VIEW projeto_ecommerce.vw_estoque_disponivel AS
SELECT
    e.id_estoque,
    e.empresa_id,
    e.sku_id,
    e.estoque_fisico,
    e.estoque_reservado,
    e.estoque_fisico - e.estoque_reservado AS estoque_disponivel,
    e.estoque_minimo
FROM projeto_ecommerce.estoque e;
