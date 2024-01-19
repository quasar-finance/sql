WITH combined_rows AS (
  SELECT
    block_height,
    tx_id,
    attribute_key,
    attribute_value,
    MAX(ingestion_timestamp) OVER (PARTITION BY tx_id, attribute_key) AS latest_ingestion_timestamp
  FROM
    `numia-data.quasar.quasar_event_attributes`
  WHERE
    event_type = 'wasm'
    AND block_height > 1000000
),

grouped_data AS (
  SELECT
    block_height,
    tx_id,
    ARRAY_AGG(STRUCT(attribute_key, attribute_value)) AS attributes,
    MAX(latest_ingestion_timestamp) AS latest_ingestion_timestamp
  FROM
    combined_rows
  WHERE
    tx_id IN (
      SELECT tx_id
      FROM combined_rows
      WHERE (attribute_key = 'action' AND attribute_value = 'update_user_index')
        AND tx_id IN (
          SELECT tx_id 
          FROM combined_rows 
          WHERE attribute_key = '_contract_address' AND attribute_value = 'quasar18a2u6az6dzw528rptepfg6n49ak6hdzkf8ewf0n5r0nwju7gtdgqamr7qu'
        )
    )
  GROUP BY
    block_height,
    tx_id
),

flattened_data AS (
  SELECT
    block_height,
    tx_id,
    attr.attribute_value AS user,
    (
      SELECT attribute_value 
      FROM UNNEST(attributes) attr
      WHERE attr.attribute_key = 'vault_token_balance'
      LIMIT 1
    ) AS vault_token_balance,
    latest_ingestion_timestamp
  FROM
    grouped_data,
    UNNEST(attributes) attr
  WHERE
    attr.attribute_key = 'user'
),

distinct_flattened_data AS (
  SELECT DISTINCT
    block_height,
    user,
    vault_token_balance,
    latest_ingestion_timestamp
  FROM
    flattened_data
)

SELECT
  user,
  ARRAY_AGG(
    STRUCT(block_height, vault_token_balance, latest_ingestion_timestamp) 
    ORDER BY block_height ASC
  ) AS user_transactions
FROM
  distinct_flattened_data
GROUP BY
  user
ORDER BY
  user ASC;