WITH 
filtered_events AS (
  SELECT 
    tx_id,
    MAX(ingestion_timestamp) AS ingestion_timestamp,
    MAX(CASE WHEN attribute_key='_contract_address' AND attribute_value='osmo1dzp8curq2wsnht5mw3eknqw9n6990rk2n095hu3r882dxp6zcvwsxwum7q' THEN TRUE ELSE FALSE END) AS is_target_contract,
    MAX(CASE WHEN attribute_key='action' AND attribute_value='withdraw' THEN TRUE ELSE FALSE END) AS is_withdraw,
    MAX(CASE WHEN attribute_key='token0_amount' THEN CAST(attribute_value AS BIGNUMERIC) ELSE 0 END) AS token0_amount,
    MAX(CASE WHEN attribute_key='token1_amount' THEN CAST(attribute_value AS BIGNUMERIC) ELSE 0 END) AS token1_amount,
    MAX(CASE WHEN attribute_key='liquidity_amount' THEN CAST(attribute_value AS BIGNUMERIC) ELSE 0 END) AS liquidity_amount,
    MAX(CASE WHEN attribute_key='share_amount' THEN CAST(attribute_value AS BIGNUMERIC) ELSE 0 END) AS share_amount
  FROM `numia-data.osmosis.osmosis_message_event_attributes`
  WHERE event_type = 'wasm'
  GROUP BY tx_id
),
sender_info AS (
  SELECT
    tx_id,
    MAX(ingestion_timestamp) AS ingestion_timestamp,
    MAX(CASE WHEN attribute_key='sender' THEN attribute_value END) AS sender
  FROM `numia-data.osmosis.osmosis_message_event_attributes`
  WHERE event_type = 'message'
  GROUP BY tx_id
)
SELECT 
  f.tx_id,
  f.ingestion_timestamp,
  s.sender,
  f.token0_amount,
  f.token1_amount,
  --f.liquidity_amount,
  --f.share_amount
FROM filtered_events f
JOIN sender_info s ON f.tx_id = s.tx_id
WHERE f.is_target_contract AND f.is_withdraw --AND sender = 'osmo1u77d2m73l38xxs863ku353sfn3lmzukkcln2jj'
ORDER BY f.ingestion_timestamp DESC;