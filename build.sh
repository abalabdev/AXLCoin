#!/bin/bash

sudo chmod 0777 -R Core
cd Core/Geth-1.8.11
make clean
make all

