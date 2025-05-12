#!/bin/bash

# Define the URL and headers
url="https://airquality.cpcb.gov.in/aqi_dashboard/aqi_all_Parameters"
user_agent="Mozilla/5.0 (X11; Linux x86_64; rv:133.0) Gecko/20100101 Firefox/133.0"
accept="text/plain, */*; q=0.01"
accept_language="en-US,en;q=0.5"
accept_encoding="gzip, deflate, br, zstd"
content_type="application/x-www-form-urlencoded; charset=UTF-8"
access_token="eyJ0aW1lIjoxNzM1OTI2ODk3OTg3LCJ0aW1lWm9uZU9mZnNldCI6LTMzMH0="
origin="https://airquality.cpcb.gov.in"
referer="https://airquality.cpcb.gov.in/AQI_India/"
cookie='ccr_public="QtpaGEb4T6ODMwl5RU8KwcV1naX9JheF9euMGEURLoV0r8FmCXkEwDNP6wbglHfIc07Qj7lm/ubrhdDWmV5ulDH9Nb2GCmAyTvPqckZXmWCP5GC0gZQeAg5o9UViaLwV6EbyoAkyl3rFtyntXOsceo/Gy/rj8fFOGgdIbcmMIN1YUcq3AjQBzhF/FjWvX1bIlFkIqsrnNszNfFQe2zCGDohVR98WH0L3H2QNNRbcX7oMWb36bOphoAQUkeqiP8UYCiYxDF2sm22D6+S1wdTXxXbqbPGeNrEIdSGLFnM6iXt3LteLhHsrl15mu4flqgyv"'
data='eyJzdGF0aW9uX2lkIjoic2l0ZV81ODA4IiwiZGF0ZSI6IjIwMjUtMDEtMDNUMjE6MDA6MDBaIn0='

# Make the POST request, decode the base64 response and extract the AQI value
response=$(curl "$url" \
  -X POST \
  -H "User-Agent: $user_agent" \
  -H "Accept: $accept" \
  -H "Accept-Language: $accept_language" \
  -H "Accept-Encoding: $accept_encoding" \
  -H "Content-Type: $content_type" \
  -H "accessToken: $access_token" \
  -H "Origin: $origin" \
  -H "Referer: $referer" \
  -H "Cookie: $cookie" \
  -H "Sec-Fetch-Dest: empty" \
  -H "Sec-Fetch-Mode: cors" \
  -H "Sec-Fetch-Site: same-origin" \
  -H "DNT: 1" \
  -H "Sec-GPC: 1" \
  -H "Priority: u=0" \
  -H "TE: trailers" \
  --data-raw "$data" -s)

echo "$response" | base64 -d | jq ".aqi.value"

