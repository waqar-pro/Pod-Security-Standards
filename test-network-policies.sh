#!/bin/bash
echo "=== Network Policy Test Suite ==="

DEV_WEB_IP=$(kubectl get pod web-app -n development -o jsonpath='{.status.podIP}')
PROD_WEB_IP=$(kubectl get pod web-app -n production -o jsonpath='{.status.podIP}')
DEV_DB_IP=$(kubectl get pod database -n development -o jsonpath='{.status.podIP}')
PROD_DB_IP=$(kubectl get pod database -n production -o jsonpath='{.status.podIP}')

echo "Dev Web: $DEV_WEB_IP | Prod Web: $PROD_WEB_IP"
echo "Dev DB:  $DEV_DB_IP  | Prod DB:  $PROD_DB_IP"
echo

test_connection() {
    local source_pod=$1 source_ns=$2 target_ip=$3 target_port=$4 expected=$5 description=$6
    echo -n "Testing: $description ... "
    if [ "$target_port" = "80" ]; then
        kubectl exec -it $source_pod -n $source_ns -- timeout 5 wget -qO- http://$target_ip >/dev/null 2>&1
    else
        kubectl exec -it $source_pod -n $source_ns -- timeout 5 nc -zv $target_ip $target_port >/dev/null 2>&1
    fi
    exit_code=$?
    if [ $exit_code -eq 0 ] && [ "$expected" = "ALLOW" ]; then echo "✓ PASS (Allowed)"
    elif [ $exit_code -ne 0 ] && [ "$expected" = "DENY" ]; then echo "✓ PASS (Blocked)"
    elif [ $exit_code -eq 0 ] && [ "$expected" = "DENY" ]; then echo "✗ FAIL (Should be blocked)"
    else echo "✗ FAIL (Should be allowed)"; fi
}

test_connection "test-client" "development" "$DEV_WEB_IP"  "80"   "ALLOW" "Client → Dev Web"
test_connection "web-app"     "development" "$DEV_DB_IP"   "3306" "ALLOW" "Dev Web → Dev DB"
test_connection "web-app"     "development" "$PROD_DB_IP"  "3306" "ALLOW" "Dev Web → Prod DB"
test_connection "test-client" "development" "$PROD_WEB_IP" "80"   "DENY"  "Client → Prod Web"
test_connection "test-client" "development" "$DEV_DB_IP"   "3306" "DENY"  "Client → Dev DB"
test_connection "test-client" "production"  "$PROD_WEB_IP" "80"   "DENY"  "Prod Client → Prod Web"

echo
echo "=== Test Suite Complete ==="

