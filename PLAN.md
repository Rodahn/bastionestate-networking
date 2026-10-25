# BastionEstate Networking - WAN Perspective Testing Plan

## Objective
Test how the WAN side of the world sees my responses to various FQDNs starting with `kara.lan.bastionestate.com` which resolves to my WAN IP (port 443 handled by HAProxy). I have NAT reflection and no external VPS for testing.

## Constraints
- No external VPS available
- Must test from "external WAN perspective" despite being behind NAT (NAT reflection in use)
- Need to see actual responses as seen from external networks
- gh logged in as Rodahn, repo name `bastionestate-networking`

## Approach
Use proxy chains/Tor relays to route traffic and observe what the external endpoint sees. Since NAT reflection is present, going out through Tor should present the request as coming from Tor exit node IPs (different from my WAN IP) allowing us to simulate external perspective.

### Tools to consider
- `torsocks` / `tor` - route through Tor network
- `proxychains-ng` - chain multiple proxies (SOCKS/HTTP)
- `curl`, `openssl s_client`, `nmap`, `httping` for testing
- `tcpdump`/`wireshark` (if needed) to inspect traffic
- `haproxy` logs analysis on the receiving side

### Testing methodology
1. **Setup**: Install/configure Tor and proxychains
2. **Baseline**: Test direct from local network (via NAT reflection) to see current behavior
3. **External simulation**: Route through Tor exits - requests will come from different IPs
4. **FQDN variations**: Test different subdomains/paths under `kara.lan.bastionestate.com*`
5. **Observe**: Record what HAProxy/server sees (source IPs, SNI, headers, response behavior)
6. **Analysis**: Compare direct vs proxied perspectives

## Infrastructure Setup
- [ ] Install Tor daemon
- [ ] Install proxychains-ng
- [ ] Configure Tor for circuit control if needed
- [ ] Verify Tor connectivity

## Test Plan
For each FQDN variation:
```bash
# Direct (NAT reflection)
curl -v https://kara.lan.bastionestate.com/...

# Via Tor
torsocks curl -v https://kara.lan.bastionestate.com/...

# Via proxychains
proxychains4 curl -v https://kara.lan.bastionestate.com/...
```

Track:
- Source IP as seen by HAProxy (check logs)
- TLS SNI
- HTTP response codes/headers
- Any differences in routing/behavior based on source IP

## Safety & Considerations
- Be mindful of Tor exit policies
- Some exits may be blocked
- Document exit nodes used
- Test incrementally

## Next Steps
1. Initialize git repo with this plan
2. Create remote repo
3. Set up Tor/proxychains
4. Create test scripts
5. Execute tests systematically
6. Document findings

