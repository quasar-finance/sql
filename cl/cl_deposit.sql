WITH filtered_events AS (
  SELECT 
    tx_id,
    MAX(ingestion_timestamp) AS ingestion_timestamp,
    MAX(CASE WHEN attribute_key='receiver' THEN attribute_value END) AS sender,
    MAX(CASE WHEN attribute_key='_contract_address' AND attribute_value='osmo1dzp8curq2wsnht5mw3eknqw9n6990rk2n095hu3r882dxp6zcvwsxwum7q' THEN TRUE ELSE FALSE END) AS is_target_contract,
    MAX(CASE WHEN attribute_key='action' AND attribute_value='exact_deposit' THEN TRUE ELSE FALSE END) AS is_exact_deposit,
    MAX(CASE WHEN attribute_key='amount0' THEN CAST(attribute_value AS BIGNUMERIC) ELSE 0 END) AS amount0,
    MAX(CASE WHEN attribute_key='amount1' THEN CAST(attribute_value AS BIGNUMERIC) ELSE 0 END) AS amount1,
    MAX(CASE WHEN attribute_key='refund0_amount' THEN CAST(attribute_value AS BIGNUMERIC) ELSE 0 END) AS refund0_amount,
    MAX(CASE WHEN attribute_key='refund1_amount' THEN CAST(attribute_value AS BIGNUMERIC) ELSE 0 END) AS refund1_amount
  FROM `numia-data.osmosis.osmosis_message_event_attributes`
  WHERE event_type = 'wasm'
  GROUP BY tx_id
)

SELECT 
  tx_id,
  ingestion_timestamp,
  sender,
  IFNULL(amount0 - refund0_amount, 0) AS final_amount0,
  IFNULL(amount1 - refund1_amount, 0) AS final_amount1
FROM filtered_events
WHERE is_target_contract AND is_exact_deposit --AND sender = 'osmo1ypnke0r4uk6u82w4gh73kc5tz0qsn0ahqqd9xh'
ORDER BY ingestion_timestamp DESC;