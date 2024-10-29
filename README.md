# Simple-ASN-from-Domain-or-SubDomain
This is a simple bash script to help automate get more enriched data from the domains and subdomains of a scope helping in bug bounty and other web applcation related security testing. It takes in the input of the subdomain or domain and then gives the ASN Number, ASN Range, ASN Name related to the domain or subdomain.

# How to use
```
wget 'https://github.com/Hijack-Everything/Simple-ASN-from-Domain-or-SubDomain/blob/main/find_asn.sh'
chmod +x find_asn.sh
./find_asn.sh -h example.target.com
```

# Output
For now the output is given in terminal as well as supports the functionality to write it into a .txt or .json file format.
```
#Terminal output
./find_asn.sh -h example.target.com

#Json file output
./find_asn.sh -h example.target.com -oj output.json

#Txt file output
./find_asn.sh -h example.target.com -ot output.txt
```

Example Output:
```
The IP for example.target.com is: 0.0.0.0
ASN: 000
AS Name: ABC CORP, AXS
Route: 0.0.0.0/00

```

# Using it with multiple tools
We can easily use the output with multiple tools thats the reason for the easy output in terminal so that we can pipe the output into multiple different needed tools. My favourite is to use it with [TLSX by ProjectDiscovery](https://github.com/projectdiscovery/tlsx) . This helps me get the Subject Alternative Name of the IPs in the range of the company's ASN. We can use it in the following way:
```
#The grep will return us the line with the Route, the cut will help us get exactly the range and pass it onto tlsx
./find_asn.sh app.apple.com | grep "Route:" | cut -d " " -f 2 | ./tlsx -san
```
