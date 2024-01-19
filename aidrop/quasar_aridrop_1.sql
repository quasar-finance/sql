SELECT
  JSON_EXTRACT_SCALAR(message, '$.sender') AS sender_address,
  COUNT(tx_id) AS count
FROM
  `lf-data.qsr_questnet_04.tx_messages`
WHERE
  message_type = '/cosmwasm.wasm.v1.MsgExecuteContract'
  AND JSON_EXTRACT_SCALAR(message, '$.contract') = 'quasar1xt4ahzz2x8hpkc0tk6ekte9x6crw4w6u0r67cyt3kz9syh24pd7slqr7s5'
GROUP BY
  sender_address
HAVING
  count >= 1
ORDER BY
  count DESC