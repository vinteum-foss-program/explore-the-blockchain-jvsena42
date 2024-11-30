# Create a 1-of-4 P2SH multisig address from the public keys in the four inputs of this tx:
#   `37d966a263350fe747f1c606b159987545844a493dd38d84b070027a895c4517`

TXID="37d966a263350fe747f1c606b159987545844a493dd38d84b070027a895c4517"
RAW_TX=$(bitcoin-cli getrawtransaction "$TXID")
DECODED_TX=$(bitcoin-cli decoderawtransaction "$RAW_TX")

PUBLIC_KEYS=()
for vin in $(echo "$DECODED_TX" | jq -c '.vin[]'); do
  input_txid=$(echo "$vin" | jq -r '.txid')
  input_vout=$(echo "$vin" | jq -r '.vout')
  
  prev_tx=$(bitcoin-cli getrawtransaction "$input_txid" true)
  
  pubkey=$(echo "$prev_tx" | jq -r '.vin[0].txinwitness[1]')
  
  PUBLIC_KEYS+=("$pubkey")
done

if [ "${#PUBLIC_KEYS[@]}" -ne 4 ]; then
  echo "Error: Expected 4 public keys, but found ${#PUBLIC_KEYS[@]}"
  exit 1
fi

# Convert public keys to JSON array and create multisig
MULTISIG=$(bitcoin-cli createmultisig 1 "$(printf '%s\n' "${PUBLIC_KEYS[@]}" | jq -R . | jq -s .)")

# Output the P2SH address
echo "P2SH Address: $(echo "$MULTISIG" | jq -r '.address')"
#echo "Redeem Script: $(echo "$MULTISIG" | jq -r '.redeemScript')"
