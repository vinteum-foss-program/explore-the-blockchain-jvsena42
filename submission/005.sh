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
  
  if [[ -z "$pubkey" || "$pubkey" == "null" ]]; then
    echo "Error: Could not extract public key for input $input_txid" >&2
    exit 1
  fi
  
  PUBLIC_KEYS+=("$pubkey")
done

if [ "${#PUBLIC_KEYS[@]}" -ne 4 ]; then
  echo "Error: Expected 4 public keys, but found ${#PUBLIC_KEYS[@]}" >&2
  exit 1
fi

MULTISIG=$(bitcoin-cli createmultisig 1 "[\"${PUBLIC_KEYS[0]}\",\"${PUBLIC_KEYS[1]}\",\"${PUBLIC_KEYS[2]}\",\"${PUBLIC_KEYS[3]}\"]")

# Output just the address
echo "$MULTISIG" | jq -r '.address'
