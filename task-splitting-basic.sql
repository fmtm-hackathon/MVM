WITH points AS (
  WITH intersected_polys AS (
    SELECT ST_Intersection(p.geom, a.geom) AS geom
    FROM islington_polygons p, islington_aoi a
    WHERE ST_Intersects(p.geom, a.geom)
    AND (tags->>'building' IS NOT NULL)
  )
  SELECT *, ST_Centroid(geom) AS centroid_geom
  FROM intersected_polys
),
clustered_polygons AS (
  SELECT ST_ClusterKMeans(geom, 19) OVER () AS cid, geom
  FROM points
),
enclosing_polygons AS (
  SELECT cid, ST_ConvexHull(ST_Collect(geom)) AS cluster_polygon
  FROM clustered_polygons
  GROUP BY cid
)

SELECT cid, cluster_polygon
FROM enclosing_polygons;