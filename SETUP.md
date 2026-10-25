# Setup Instructions

## Required Packages
```bash
sudo apt install tor torsocks proxychains4
```

## Configuration

### Tor
Start and verify Tor:
```bash
sudo systemctl enable --now tor
sudo systemctl status tor
```

### Proxychains
Edit `/etc/proxychains4.conf` - typically use `strict_chain` with `socks5 127.0.0.1 9050` (Tor's default SOCKS port)

Verify:
```bash
proxychains4 curl ifconfig.me
torsocks curl ifconfig.me
```

Both should show Tor exit IPs, different from your WAN IP.
