# Which tx in block 257,343 spends the coinbase output of block 256,128?

#Block heights
BLOCK_HEIGHT_1=256128
BLOCK_HEIGHT_2=257343

#Block hashes
BLOCK_HASH_1=$(bitcoin-cli getblockhash $BLOCK_HEIGHT_1)
BLOCK_HASH_2=$(bitcoin-cli getblockhash $BLOCK_HEIGHT_2)

#Coinbase TX Id of block 256128
COINBASE_TX_ID=$(bitcoin-cli getblock $BLOCK_HASH_1 | jq -r '.tx[0]')

#Get all transactions of block 257343
TRANSACTION_LIST=$(bitcoin-cli getblock $BLOCK_HASH_2 | jq -r '.tx[]')

#find the transaction that spends the coinbase transaction
for TX_ID in $TRANSACTION_LIST; do
  RAW_TX=$(bitcoin-cli getrawtransaction $TX_ID 1)
  
  #get the inputs tx id and check if it matches with COINBASE_TX_ID
  if echo "$RAW_TX" | jq -r '.vin[].txid' | grep -q "$COINBASE_TX_ID"; then
    echo "$TX_ID"
    exit 0
  fi
done

# If no transaction is found
echo "Couldn't find in block $BLOCK_HEIGHT_2 a transaction that spends the coinbase output of block $BLOCK_HEIGHT_1."
exit 1
