WITH 
claim_rewards_events AS (
  SELECT 
    tx_id,
    MAX(ingestion_timestamp) AS ingestion_timestamp,
    MAX(CASE WHEN attribute_key='_contract_address' AND attribute_value='osmo1dzp8curq2wsnht5mw3eknqw9n6990rk2n095hu3r882dxp6zcvwsxwum7q' THEN TRUE ELSE FALSE END) AS is_target_contract,
    MAX(CASE WHEN attribute_key='action' AND attribute_value='claim_user_rewards' THEN TRUE ELSE FALSE END) AS is_claim_rewards,
    MAX(CASE WHEN attribute_key='recipient' THEN attribute_value END) AS recipient
  FROM `numia-data.osmosis.osmosis_message_event_attributes`
  WHERE event_type = 'wasm'
  GROUP BY tx_id
),
transfer_amounts AS (
  SELECT
    tx_id,
    MAX(ingestion_timestamp) AS ingestion_timestamp,
    SPLIT(MAX(CASE WHEN attribute_key='amount' THEN attribute_value END), ',') AS amount_array
  FROM `numia-data.osmosis.osmosis_message_event_attributes`
  WHERE event_type = 'transfer'
  GROUP BY tx_id
)
SELECT 
  c.tx_id,
  c.ingestion_timestamp,
  c.recipient,
  t.amount_array
FROM claim_rewards_events c
JOIN transfer_amounts t ON c.tx_id = t.tx_id
WHERE c.is_target_contract AND c.is_claim_rewards --AND recipient = 'osmo1ypnke0r4uk6u82w4gh73kc5tz0qsn0ahqqd9xh'
ORDER BY c.ingestion_timestamp DESC;