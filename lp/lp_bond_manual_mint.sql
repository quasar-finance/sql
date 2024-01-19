WITH 
message_actions AS (
    SELECT DISTINCT G.tx_id 
    FROM `numia-data.quasar.quasar_event_attributes` AS G
    WHERE G.event_type = 'message' 
      AND G.attribute_key = 'action' 
      AND G.attribute_value = '/cosmwasm.wasm.v1.MsgMigrateContract'
      AND EXISTS (
        SELECT 1 
        FROM `numia-data.quasar.quasar_event_attributes` AS H
        WHERE H.tx_id = G.tx_id AND H.attribute_key = '_contract_address'
      )
      AND EXISTS (
        SELECT 1 
        FROM `numia-data.quasar.quasar_event_attributes` AS I
        WHERE I.tx_id = G.tx_id AND I.attribute_key = 'user'
      )
      AND EXISTS (
        SELECT 1 
        FROM `numia-data.quasar.quasar_event_attributes` AS J
        WHERE J.tx_id = G.tx_id AND J.attribute_key = 'vault_token_balance'
      )
)
SELECT A.tx_id
FROM message_actions AS A