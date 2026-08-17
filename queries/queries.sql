```sql
-- ============================================================
-- 1. QUAL O VALOR DO PATRIMÔNIO DA EMPRESA?
-- Considerando o valor do estoque pelo custo médio
-- ============================================================

SELECT
    e.nome_fantasia AS empresa,
    SUM(est.estoque_fisico * est.custo_medio) AS valor_patrimonio_estoque
FROM projeto_ecommerce.empresa e
JOIN projeto_ecommerce.estoque est
    ON est.empresa_id = e.id_empresa
GROUP BY
    e.id_empresa,
    e.nome_fantasia;


-- ============================================================
-- 2. QUANTO TENHO DE ESTOQUE DISPONÍVEL?
-- Estoque disponível = estoque físico - estoque reservado
-- ============================================================

SELECT
    SUM(estoque_fisico - estoque_reservado) AS estoque_disponivel
FROM projeto_ecommerce.estoque;


-- ============================================================
-- 3. QUAL O VOLUME DE VENDAS?
-- Considerando o valor líquido dos pedidos não cancelados
-- ============================================================

SELECT
    COUNT(*) AS quantidade_pedidos,
    SUM(valor_total_liquido) AS volume_total_vendas
FROM projeto_ecommerce.pedido
WHERE status_pedido <> 'CANCELADO';


-- ============================================================
-- 4. QUAL A PORCENTAGEM DE CANCELAMENTOS?
-- Pedidos cancelados / total de pedidos
-- ============================================================

SELECT
    COUNT(*) AS total_pedidos,
    COUNT(*) FILTER (
        WHERE status_pedido = 'CANCELADO'
    ) AS pedidos_cancelados,
    ROUND(
        COUNT(*) FILTER (
            WHERE status_pedido = 'CANCELADO'
        ) * 100.0 / COUNT(*),
        2
    ) AS percentual_cancelamentos
FROM projeto_ecommerce.pedido;


-- ============================================================
-- 5. QUAIS OS 10 PRINCIPAIS PRODUTOS?
-- Ranking por quantidade de unidades vendidas
-- ============================================================

SELECT
    p.id_produto,
    p.nome_produto,
    SUM(pi.quantidade) AS quantidade_vendida,
    SUM(pi.quantidade * pi.preco_unitario) AS faturamento
FROM projeto_ecommerce.pedido_item pi
JOIN projeto_ecommerce.anuncio a
    ON a.id_anuncio = pi.anuncio_id
JOIN projeto_ecommerce.sku s
    ON s.id_sku = a.sku_id
JOIN projeto_ecommerce.produto p
    ON p.id_produto = s.produto_id
JOIN projeto_ecommerce.pedido ped
    ON ped.id_pedido = pi.pedido_id
WHERE ped.status_pedido <> 'CANCELADO'
GROUP BY
    p.id_produto,
    p.nome_produto
ORDER BY
    quantidade_vendida DESC
LIMIT 10;
```
