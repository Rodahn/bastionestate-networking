#!/bin/bash
# WAN Perspective Testing Script

DOMAIN="kara.lan.bastionestate.com"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RESULTS_DIR="../results/$TIMESTAMP"
mkdir -p "$RESULTS_DIR"

echo "=== WAN Perspective Testing ==="
echo "Domain: $DOMAIN"
echo "Results: $RESULTS_DIR"
echo ""

# Function to test
test_direct() {
    echo "[DIRECT - NAT Reflection]" 
    curl -v --connect-timeout 10 "https://$DOMAIN/" 2>&1 | tee "$RESULTS_DIR/direct.txt"
    echo -e "\n---\n" >> "$RESULTS_DIR/summary.txt"
    echo "Direct test completed" >> "$RESULTS_DIR/summary.txt"
}

test_tor() {
    echo "[TOR - torsocks]"
    if command -v torsocks >/dev/null 2>&1; then
        torsocks curl -v --connect-timeout 30 "https://$DOMAIN/" 2>&1 | tee "$RESULTS_DIR/tor_torsocks.txt"
    else
        echo "torsocks not installed" | tee "$RESULTS_DIR/tor_torsocks.txt"
    fi
    echo -e "\n---\n" >> "$RESULTS_DIR/summary.txt"
}

test_proxychains() {
    echo "[PROXYCHAINS]"
    if command -v proxychains4 >/dev/null 2>&1; then
        proxychains4 curl -v --connect-timeout 30 "https://$DOMAIN/" 2>&1 | tee "$RESULTS_DIR/tor_proxychains.txt"
    else
        echo "proxychains4 not installed" | tee "$RESULTS_DIR/tor_proxychains.txt"
    fi
    echo -e "\n---\n" >> "$RESULTS_DIR/summary.txt"
}

# Run tests
test_direct
test_tor
test_proxychains

echo "=== Testing Complete ==="
echo "Results saved to: $RESULTS_DIR"
