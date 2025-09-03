### Install on `host` (Ububtu / Arch):

#### Step 1: Install StrongSwan (IPSec):
On Linux Mint:
```
sudo apt update
sudo apt install strongswan strongswan-swanctl strongswan-pki
```

On Arch Linux:
```
sudo pacman -Su
sudo pacman -S strongswan
```

#### Step 2: Create an empty `strongswan.conf` file (to run `pki` command):
```
sudo touch /etc/strongswan.conf
```

#### Step 3: Generate certificates (using `pki`):
```
./generate-certs-server.sh
```

And copy all to swanctl:
```
sudo cp generated-certs/cacerts/ca.cert.pem /etc/swanctl/x509ca/
sudo cp generated-certs/certs/server.cert.pem /etc/swanctl/x509/
sudo cp generated-certs/private/server.key.pem /etc/swanctl/private
```

#### Step 5: Enable IP forwarding and NAT on the server:
Allow IP forwarding on the server by uncommenting a line in `/etc/sysctl.conf`:
```
sudo sed -i 's/^#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sudo sysctl -p
```

#### Step 6: Setup NAT for VPN traffic on the server:
```
# Replace `wlo1` with your internet-facing interface
sudo iptables -t nat -A POSTROUTING -s 10.10.10.0/24 -o wlo1 -j MASQUERADE
sudo iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -s 10.10.10.0/24 -j ACCEPT
```

To persist the iptables rules:
```
sudo apt install iptables-persistent
sudo netfilter-persistent save
```

#### Step 7: Copy config file to `/etc/swanctl/conf.d/`
```
sudo cp examples/host-to-host/server-left.conf /etc/swanctl/conf.d/host-to-host.conf
```

#### Step 8: Load configs and start as service:
```
sudo systemctl enable --now strongswan-starter.service
sudo swanctl --load-all
```