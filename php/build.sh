#!/bin/bash

cd "${0%/*}"
gen_dir=$PWD/gen
mkdir -p "$gen_dir"

(cd ../proto && protoc -I . --php_out "$gen_dir" *.proto)
