#!/usr/bin/bash
solc --standard-json --pretty-json  config.json > output.json
python output_formatter.py