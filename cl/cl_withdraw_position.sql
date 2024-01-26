select
  cl.tx_id,
  cl.block_timestamp,
  cl.sender,
  cl.pool_id,
  cl.position_id,
  cast(cl.amount_asset_1 as numeric)/1000000 as osmo_amount,
  cast(cl.amount_asset_1 as numeric)/1000000*p.price_in_usdc as osmo_amount_usd,
  cast(cl.amount_asset_2 as numeric)/1000000000000000000 as dai_amount,
  cast(upper_tick as numeric) as upper_tick,
  cast(lower_tick as numeric) as lower_tick,
  cast(upper_tick as numeric) - cast(lower_tick as numeric) as liquidity_range,
  'removed_liquidity'
from `numia-data.osmosis.osmosis_withdraw_position` cl
inner join `numia-data.osmosis.osmosis_osmo_price` p on date_trunc(p.time_minutes, minute) = date_trunc(cl.block_timestamp, minute)
where cl.pool_id = '1314'
order by cl.block_timestamp desc