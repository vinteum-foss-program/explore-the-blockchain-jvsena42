# Create a 1-of-4 P2SH multisig address from the public keys in the four inputs of this tx:
#   `37d966a263350fe747f1c606b159987545844a493dd38d84b070027a895c4517`

TXID="37d966a263350fe747f1c606b159987545844a493dd38d84b070027a895c4517"

# Extract the raw transaction
RAW_TX=$(bitcoin-cli getrawtransaction "$TXID")

# Decode the raw transaction
DECODED_TX=$(bitcoin-cli decoderawtransaction "$RAW_TX")

# Extract public keys from txinwitness
PUBKEY1=$(echo "$DECODED_TX" | jq -r '.vin[0].txinwitness[1]')
PUBKEY2=$(echo "$DECODED_TX" | jq -r '.vin[1].txinwitness[1]')
PUBKEY3=$(echo "$DECODED_TX" | jq -r '.vin[2].txinwitness[1]')
PUBKEY4=$(echo "$DECODED_TX" | jq -r '.vin[3].txinwitness[1]')

# Create the 1-of-4 multisig address
RESULT=$(bitcoin-cli createmultisig 1 "[\"$PUBKEY1\", \"$PUBKEY2\", \"$PUBKEY3\", \"$PUBKEY4\"]")

# Extract the address from the result
ADDRESS=$(echo "$RESULT" | jq -r '.address')

echo "$ADDRESS"
