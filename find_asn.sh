#!/bin/bash

# Check if required tools are installed
for cmd in curl dig jq; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: $cmd is not installed. Please install it and try again."
        exit 1
    fi
done

# Initialize variables
domain=""
output_text=""
output_json=""

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h) 
            domain="$2"
            shift 2
            ;;
        -ot) 
            output_text="$2"
            shift 2
            ;;
        -oj) 
            output_json="$2"
            shift 2
            ;;
        *)
            echo "Usage: $0 -h <domain> [-ot <text_file>] [-oj <json_file>]"
            exit 1
            ;;
    esac
done

# Check if domain is provided
if [ -z "$domain" ]; then
    echo "Error: Domain not specified. Use -h to provide a domain."
    exit 1
fi

# Get the IP address for the domain
ip=$(dig +short "$domain")
echo "The IP for $domain is: $ip"

# Get IP details using RIPE's API
ip_details=$(curl -s "https://stat.ripe.net/data/prefix-overview/data.json?resource=$ip&sourceapp=nitefood-asn")

# Check if the IP is announced
if jq -r '.data.announced' <<<"$ip_details" | grep -q "true"; then
    # If announced, get ASN and AS name
    found_asn=$(jq -r '.data.asns[0].asn' <<<"$ip_details")
    found_asname=$(jq -r '.data.asns[0].holder' <<<"$ip_details")

    # Look up the country this ASN is located in
    country=$(curl -s -m5 "https://stat.ripe.net/data/rir-stats-country/data.json?resource=AS${found_asn}" | jq -r '.data.located_resources[0].location')
    
    # Add country information if available
    if [[ "$country" != "null" ]]; then
        found_asname="${found_asname}, ${country}"
    fi

    # Get the route from the IP details
    found_route=$(jq -r '.data.resource' <<<"$ip_details")
else
    # If not announced, perform a reverse lookup for the ASN
    rev=$(echo "$domain" | cut -d '/' -f 1 | awk -F'.' '{printf "%s.%s.%s.%s", $4, $3, $2, $1}')
    output=$(host -t TXT "$rev.origin.asn.cymru.com" | awk -F'"' 'NR==1{print $2}' | sed 's/\ *|\ */|/g')
    
    # Extract ASN from the reverse lookup
    found_asn=$(echo "$output" | awk -F'[|]' 'NR==1{print $1}' | cut -d ' ' -f 1)
    found_asname=$(echo "$output" | awk -F'[|]' 'NR==1{print $3}')
    found_route="N/A"
fi

# Prepare output
output_text_content="ASN: $found_asn\nAS Name: $found_asname\nRoute: $found_route"
output_json_content="{\"ASN\": \"$found_asn\", \"AS_Name\": \"$found_asname\", \"Route\": \"$found_route\"}"

# Print results
echo -e "$output_text_content"

# Write to text file if specified
if [ -n "$output_text" ]; then
    echo -e "$output_text_content" > "$output_text"
    echo "Output written to $output_text"
fi

# Write to JSON file if specified
if [ -n "$output_json" ]; then
    echo "$output_json_content" > "$output_json"
    echo "Output written to $output_json"
fi
