#!/usr/bin/env bash

echo "Starting AXLCoin Core start!!"
cd ../Core/Geth-1.8.11/build/bin/
./geth console --syncmode "fast"
# screen -dmS geth console Core/Geth-1.8.11/build/bin/geth --verbosity 3
