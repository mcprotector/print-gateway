#!/bin/bash
queue="$1"
pdf="$2"

host="${CUPS_HOST:-localhost}"
port="${CUPS_PORT:-631}"

uri="ipp://$host:$port/printers/$queue"
uri_len=$(printf "%s" "$uri" | wc -c)

{
  printf '\x01\x01'              # IPP version 1.1
  printf '\x00\x02'              # Print-Job
  printf '\x00\x00\x00\x01'      # Request ID

  printf '\x01'                  # operation-attributes-tag

  # attributes-charset
  printf '\x47'
  printf '\x00\x12attributes-charset'
  printf '\x00\x05utf-8'

  # attributes-natural-language
  printf '\x48'
  printf '\x00\x1Battributes-natural-language'
  printf '\x00\x05en-us'

  # printer-uri
  printf '\x45'
  printf '\x00\x0Bprinter-uri'
  printf "\\x00\\x$(printf '%02x' "$uri_len")"
  printf '%s' "$uri"

  # document-format
  printf '\x49'
  printf '\x00\x0Fdocument-format'
  printf '\x00\x0Fapplication/pdf'

  printf '\x03'                  # end-of-attributes-tag
} > /tmp/header.bin

cat /tmp/header.bin "$pdf" > /tmp/job.bin

response=$(curl -s -X POST "http://$host:$port/printers/$queue" \
  -H "Content-Type: application/ipp" \
  --data-binary @/tmp/job.bin \
  -w "%{http_code}" \
  -o /tmp/cups_response.bin)

http_code="$response"

if [[ "$http_code" == 2* ]]; then
  exit 0
else
  echo "CUPS error (HTTP $http_code):" >&2
  strings /tmp/cups_response.bin >&2
  exit 1
fi
