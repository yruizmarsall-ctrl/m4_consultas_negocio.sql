SELECT
    EXTRACT(YEAR FROM fecha_venta) AS anio,
    EXTRACT(MONTH FROM fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    AVG(cantidad * precio_unitario) AS ticket_promedio
FROM ventas
GROUP BY
    EXTRACT(YEAR FROM fecha_venta),
    EXTRACT(MONTH FROM fecha_venta)
ORDER BY anio, mes;

-- CONSULTA 2: RANKING DE PRODUCTOS (TOP 5)

SELECT
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC
LIMIT 5;


-- CONSULTA 3: CLIENTES RECURRENTES

SELECT
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY cantidad_pedidos DESC, total_gastado DESC;


-- CONSULTA 4: COMPARACIÓN CON EL PROMEDIO MENSUAL

WITH facturacion_mensual AS (
    SELECT
        EXTRACT(YEAR FROM fecha_venta) AS anio,
        EXTRACT(MONTH FROM fecha_venta) AS mes,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY
        EXTRACT(YEAR FROM fecha_venta),
        EXTRACT(MONTH FROM fecha_venta)
),
promedio_mensual AS (
    SELECT AVG(total_facturado) AS promedio_general
    FROM facturacion_mensual
)
SELECT
    fm.anio,
    fm.mes,
    fm.total_facturado,
    pm.promedio_general,
    CASE
        WHEN fm.total_facturado > pm.promedio_general
            THEN 'Por encima'
        WHEN fm.total_facturado < pm.promedio_general
            THEN 'Por debajo'
        ELSE 'Igual al promedio'
    END AS comparacion_con_promedio
FROM facturacion_mensual AS fm
CROSS JOIN promedio_mensual AS pm
ORDER BY fm.anio, fm.mes;

-- 1. La facturación total es 6.444,00.
-- 2. El producto 1 lidera la facturación con 3.600,00,
--    aproximadamente el 55,9% del total.
-- 3. Los cinco clientes realizaron dos pedidos cada uno.
-- 4. El cliente 1 registra el mayor gasto acumulado: 2.640,00.