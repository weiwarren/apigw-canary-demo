#using curl
while true; do curl -i -s $INVOKE_URI/; sleep 1; done

#using k6
# k6 run --vus 10 --duration 10s ./test/k6.js
