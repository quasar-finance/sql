WITH extracted_data AS (
  SELECT
    block_height,
    tx_id,
    REGEXP_EXTRACT(attribute_value, r'unbond_id: "([^"]+)"') AS unbond_id,
    REGEXP_EXTRACT(attribute_value, r'amount: Some\(Uint128\((\d+)\)\)') AS share_amount,
    REGEXP_EXTRACT(attribute_value, r'owner: Addr\("([^"]+)"\)') AS owner_addr,
    CAST(ingestion_timestamp AS STRING) AS ingestion_timestamp
  FROM
    `numia-data.quasar.quasar_message_event_attributes`
  WHERE
    event_type = 'wasm'
    AND attribute_key = 'callback-info'
    AND attribute_value LIKE '%UnbondResponse%'
    AND attribute_value LIKE '%unbond_id: "1540"%'
)
SELECT
  unbond_id,
  STRING_AGG(share_amount, ', ') AS share_amounts,
  STRING_AGG(owner_addr, ', ') AS owner_addrs,
  STRING_AGG(ingestion_timestamp, ', ') AS ingestion_timestamps,
  STRING_AGG(CAST(block_height AS STRING), ', ') AS block_heights,
  STRING_AGG(tx_id, ', ') AS tx_ids
FROM
  extracted_data
GROUP BY
  unbond_id
ORDER BY
  unbond_id ASC;