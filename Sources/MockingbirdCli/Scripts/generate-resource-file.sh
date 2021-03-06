#!/bin/bash

# Swift <5.3 does not support embedding arbitrary resources into the package, so this is a
# workaround that generates a Swift file containing the encoded data.

set -e

if [[ $# -ne 3 ]]; then
  echo "Usage: generate-resource-file.sh <resource_file> <output_file> <resource_name>"
  exit 1
fi

readonly resourceFile=$1
readonly outputFile=$2
readonly resourceName=$3
readonly outputFileName=$(basename "$outputFile")
readonly resourceFileName=$(basename "$resourceFile")
readonly encodedResource=$(base64 -i "$resourceFile")

cat <<EOF > "${outputFile}"
//
//  $outputFileName
//  Mockingbird
//
//  Generated by generate-resource-file.sh.
//  DO NOT EDIT
//

import Foundation

private let encodedData = #"$encodedResource"#
let $resourceName = Resource(encodedData: encodedData, fileName: "$resourceFileName")

EOF

echo "Generated encoded resource file"
echo "  Resource file: $resourceFile"
echo "  Output file: $outputFile"
echo "  Resource name: $resourceName"
