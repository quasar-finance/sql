SELECT block_height, tx_id, event_type, attribute_key, attribute_value, ingestion_timestamp
FROM `numia-data.quasar.quasar_message_event_attributes` 
WHERE event_type = 'acknowledge_packet'
  AND attribute_key = 'packet_sequence'
  AND EXISTS (
      SELECT 1
      FROM `numia-data.quasar.quasar_message_event_attributes` AS sub
      WHERE sub.tx_id = tx_id
        AND sub.event_type = 'message'
        AND sub.attribute_key = 'action'
        AND sub.attribute_value = '/ibc.core.channel.v1.MsgAcknowledgement'
        AND EXISTS (
            SELECT 1
            FROM `numia-data.quasar.quasar_message_event_attributes` AS sub2
            WHERE sub2.tx_id = sub.tx_id
              AND sub2.attribute_key = 'packet_src_channel'
              AND sub2.attribute_value = 'channel-13'
        )
  )
  AND attribute_value = '8686'
ORDER BY ingestion_timestamp ASC