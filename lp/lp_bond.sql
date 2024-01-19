WITH combined_rows AS (
  SELECT
    block_height,
    tx_id,
    event_type,
    event_source,
    attribute_key,
    attribute_value,
    ingestion_timestamp,
    ROW_NUMBER() OVER (PARTITION BY tx_id, attribute_key ORDER BY ingestion_timestamp) AS row_num
  FROM
    `numia-data.quasar.quasar_event_attributes`
  WHERE
    event_type = 'wasm' OR event_type = 'coin_spent'
  ORDER BY
    block_height ASC
),

filtered_tx_ids AS (
  SELECT DISTINCT
    tx_id
  FROM
    combined_rows
  WHERE
    attribute_key = 'bond_id'
    AND EXISTS (
      SELECT 1
      FROM combined_rows c
      WHERE c.tx_id = combined_rows.tx_id
      AND c.attribute_key = 'spender'
      AND c.attribute_value = 'quasar1p577t98ggzlucph3wwehmtmhqr75fda0964r4h'
    )
),

valid_tx_ids AS (
  SELECT DISTINCT
    tx_id
  FROM
    combined_rows
  WHERE
    tx_id NOT IN (
      SELECT tx_id
      FROM combined_rows
      WHERE attribute_key = 'action' AND attribute_value = 'start_unbond'
    )
),

filtered_combined_rows AS (
  SELECT *
  FROM combined_rows
  WHERE attribute_key IN ('spender', 'amount', 'bond_id', 'deposit')
),

key_value_pairs AS (
  SELECT
    fcr.block_height,
    fcr.tx_id,
    STRING_AGG(DISTINCT fcr.event_type) AS event_types,
    STRING_AGG(DISTINCT fcr.event_source) AS event_sources,
    fcr.attribute_key,
    fcr.attribute_value,
    MAX(fcr.ingestion_timestamp) AS latest_ingestion_timestamp
  FROM
    filtered_combined_rows fcr
  JOIN
    filtered_tx_ids ft
  ON
    fcr.tx_id = ft.tx_id
  JOIN
    valid_tx_ids vt
  ON
    fcr.tx_id = vt.tx_id
  GROUP BY
    fcr.block_height,
    fcr.tx_id,
    fcr.attribute_key,
    fcr.attribute_value
)

SELECT
  block_height,
  tx_id,
  ARRAY_AGG(STRUCT(attribute_key, attribute_value)) AS attribute_pairs,
  MAX(latest_ingestion_timestamp) AS latest_ingestion_timestamp
FROM
  key_value_pairs
GROUP BY
  block_height,
  tx_id
ORDER BY
  block_height ASC;