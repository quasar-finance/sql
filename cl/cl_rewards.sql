WITH sender_message_index AS (
    SELECT 
        tx_id,
        message_index,
        attribute_index AS sender_attribute_index
    FROM `numia-data.osmosis.osmosis_message_event_attributes`
    WHERE event_type IN ('total_collect_incentives', 'total_collect_spread_rewards')
        AND attribute_key = 'sender'
        AND attribute_value = 'osmo1zvyemtz9tuyhucq6vqfk556zzz62pznya6pch2ndqxtq7amlxkdq3zkl54'
)

, amount_data AS (
    SELECT 
        a.tx_id,
        a.message_index,
        a.event_type,
        MAX(a.ingestion_timestamp) AS ingestion_timestamp,
        ARRAY_AGG(a.attribute_value) AS amount_array
    FROM `numia-data.osmosis.osmosis_message_event_attributes` a
    JOIN sender_message_index s
    ON a.tx_id = s.tx_id 
        AND a.message_index = s.message_index
    WHERE a.event_type IN ('total_collect_incentives', 'total_collect_spread_rewards')
        AND a.attribute_key = 'tokens_out'
        AND a.ingestion_timestamp > TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 DAY) -- Added this line to filter by the last 24h
    GROUP BY a.tx_id, a.message_index, a.event_type
)

, unnest_amounts AS (
    SELECT 
        tx_id,
        event_type,
        ingestion_timestamp,
        amount
    FROM amount_data,
    UNNEST(SPLIT(ARRAY_TO_STRING(amount_array, ','))) AS amount
)

, incentives AS (
    SELECT 
        tx_id,
        ingestion_timestamp,
        ARRAY_AGG(DISTINCT amount ORDER BY amount ASC) AS amount_incentives
    FROM unnest_amounts
    WHERE event_type = 'total_collect_incentives'
    GROUP BY tx_id, ingestion_timestamp
)

, spread_rewards AS (
    SELECT 
        tx_id,
        ingestion_timestamp,
        ARRAY_AGG(DISTINCT amount ORDER BY amount ASC) AS amount_spread_rewards
    FROM unnest_amounts
    WHERE event_type = 'total_collect_spread_rewards'
    GROUP BY tx_id, ingestion_timestamp
)

SELECT 
    COALESCE(i.tx_id, sr.tx_id) AS tx_id,
    COALESCE(i.ingestion_timestamp, sr.ingestion_timestamp) AS ingestion_timestamp,
    i.amount_incentives,
    sr.amount_spread_rewards
FROM incentives i
FULL JOIN spread_rewards sr
ON i.tx_id = sr.tx_id AND i.ingestion_timestamp = sr.ingestion_timestamp
ORDER BY ingestion_timestamp DESC;