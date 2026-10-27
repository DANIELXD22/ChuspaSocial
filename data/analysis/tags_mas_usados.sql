-- =========================================================
-- Consulta: tags mas usados por mes en ChuspaSocial
-- Issue #20
--
-- Relaciona las etiquetas de Moodle con las publicaciones
-- de ChuspaSocial mediante tag_instance.
--
-- Supuestos:
--   tag_instance.itemtype = 'local_chuspasocial_post'
--   tag_instance.component = 'local_chuspasocial'
--   local_chuspasocial_post.id identifica cada publicacion
--   local_chuspasocial_post.timecreated almacena su fecha
--
-- Portabilidad (PostgreSQL, MySQL y MariaDB):
--   No se usan funciones de fecha propias de un motor. El mes se
--   calcula a partir del timestamp Unix como un indice de mes:
--     mes_indice = FLOOR(p.timecreated / 2629800)
--   donde 2629800 es la duracion promedio de un mes en segundos
--   (365.25 dias / 12). El indice cuenta meses desde 1970.
--
--   Como obtener anio y mes a partir del indice (en la aplicacion):
--     anio = 1970 + FLOOR(mes_indice / 12)
--     mes  = (mes_indice % 12) + 1
--   Ejemplo: mes_indice 678 -> anio 2026, mes 7.
--   Nota: al ser meses promedio, el limite entre meses puede
--   desfasarse unos dias respecto al calendario.
--
-- Solo devuelve datos agregados; no expone datos personales.
-- =========================================================

SELECT
    FLOOR(p.timecreated / 2629800) AS mes_indice,
    t.id AS tagid,
    t.name AS tag,
    COUNT(*) AS total_usos
FROM tag_instance ti
INNER JOIN tag t
    ON t.id = ti.tagid
INNER JOIN local_chuspasocial_post p
    ON p.id = ti.itemid
WHERE
    ti.component = 'local_chuspasocial'
    AND ti.itemtype = 'local_chuspasocial_post'
GROUP BY
    FLOOR(p.timecreated / 2629800),
    t.id,
    t.name
ORDER BY
    FLOOR(p.timecreated / 2629800),
    total_usos DESC;

/*
=========================================
EJEMPLO DE RESULTADO (datos ficticios)
=========================================
mes_indice | tagid | tag        | total_usos
-----------------------------------------------
678        | 3     | literatura | 18
678        | 5     | novela     | 12
679        | 3     | literatura | 24
679        | 8     | ciencia    | 15
680        | 5     | novela     | 20
(678 = julio 2026, 679 = agosto 2026, 680 = septiembre 2026)
=========================================
*/