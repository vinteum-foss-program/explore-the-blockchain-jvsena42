# How many new outputs were created by block 123,456?

BLOCK_HASH=$(bitcoin-cli getblockhash 123456)
TXIDS=$(bitcoin-cli getblock $BLOCK_HASH | jq -r '.tx[]')

TOTAL_OUTPUTS=0

for TXID in $TXIDS; do
  RAW_TX=$(bitcoin-cli getrawtransaction $TXID)
  OUTPUT_COUNT=$(bitcoin-cli decoderawtransaction $RAW_TX | jq '.vout | length')
  TOTAL_OUTPUTS=$((TOTAL_OUTPUTS + OUTPUT_COUNT))
done

echo $TOTAL_OUTPUTS
