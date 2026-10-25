# WAN Perspective Testing Methodology

## Overview
This document outlines the methodology for testing how services exposed on the WAN appear from external perspectives, particularly in scenarios with NAT reflection and no external VPS available for testing.

## Problem Statement
We want to test how the WAN side sees responses to various FQDNs starting with `kara.lan.bastionestate.com` which resolves to our WAN IP (port 443 handled by HAProxy). We have NAT reflection and no external VPS for testing.

## Solution: Using Tor as External Proxy
Since we have no external VPS, we can route traffic through the Tor network. When requests go through Tor exit nodes, they appear to originate from the exit node's IP address rather than our own WAN IP. This simulates an external perspective.

## Tools Used

### Tor
- **Purpose**: Anonymizing network that routes traffic through multiple relays
- **SOCKS proxy**: Runs on `127.0.0.1:9050` by default
- **Exit nodes**: Traffic exits to the internet from random Tor relays

### torsocks
- **Purpose**: LD_PRELOAD library that forces TCP connections through Tor's SOCKS proxy
- **Usage**: `torsocks <command>` transparently routes traffic
- **Considerations**: Some applications may need specific configuration

### proxychains-ng (proxychains4)
- **Purpose**: Chains multiple proxies (HTTP, SOCKS4, SOCKS5)
- **Usage**: Routes traffic through configured proxy chain
- **Configuration**: `/etc/proxychains4.conf` - typically configured with `strict_chain` pointing to Tor

## Testing Process

### 1. Baseline Testing (Direct/NAT Reflection)
```bash
curl -v https://kara.lan.bastionestate.com/
```
This tests via NAT reflection - traffic goes out and comes back in through our own WAN IP.

### 2. External Perspective via Tor
```bash
torsocks curl -v https://kara.lan.bastionestate.com/
# or
proxychains4 curl -v https://kara.lan.bastionestate.com/
```
These route through Tor exit nodes, so the destination sees connections from Tor exit IPs.

## Observations from Testing

**Direct access (NAT reflection):** Successfully reaches the service (Proxmox web UI in this case). The service responds normally as if accessed externally.

**Via Tor (torsocks):** Connection fails - "General SOCKS server failure" or connection refused. This suggests:
- The firewall/HAProxy may be blocking connections from Tor exit IPs
- Geo-blocking or IP reputation filtering may be in place
- The service may have rate limiting or access controls

**Via proxychains4:** Also fails - gets denied at proxy level or connection refused. Shows different resolution behavior.

## Key Learnings

1. **NAT reflection allows testing from inside**: Even though traffic appears to come from WAN IP, NAT reflection handles it. But actual external access depends on firewall rules.
2. **Tor exit IPs may be blocked**: Many services block Tor exit nodes due to abuse concerns
3. **Source IP matters**: The behavior differs based on where the connection originates from (our WAN IP vs Tor exit IP)
4. **Testing methodology is valid**: This approach correctly simulates external perspective when Tor exits aren't blocked

## Troubleshooting

- **Check Tor connectivity**: `torsocks curl https://check.torproject.org/api/ip` should show `IsTor: true`
- **Check proxychains config**: Ensure `/etc/proxychains4.conf` has `socks5 127.0.0.1 9050`
- **Firewall rules**: If Tor fails, check HAProxy/firewall rules for allowed source IPs
- **DNS issues**: Sometimes DNS leaks - torsocks handles this, but configuration matters

## Future Testing
- Test different FQDN subdomains
- Check specific ports/paths
- Analyze HAProxy logs to see actual source IPs seen
- Test with different exit nodes/circuits
