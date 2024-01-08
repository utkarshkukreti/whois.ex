default: tld.csv

tld.json:
	curl -s -L https://github.com/weppos/whois/raw/main/data/tld.json > tld.json

tld.csv: tld.json
	cat tld.json | jq -r 'to_entries | .[] | select(.value.host) | .key + "," + .value.host' > tld.csv

clean:
	rm -f tld.json tld.csv
