### Install on `client` (Ububtu / Arch):

#### Step 1: Install StrongSwan (IPSec):
On Arch Linux:
```
sudo apt update
sudo apt install strongswan strongswan-swanctl
```

On Arch Linux:
```
sudo pacman -Su
sudo pacman -S strongswan
```

#### Step 2: Create an empty `strongswan.conf` file:
```
sudo touch /etc/strongswan.conf
```

#### Step 3: Place CA cert:
```
sudo cp generated-certs/cacert/ca.cert.pem /etc/swanctl/cacerts/
```

#### Step 4: Copy config file to `/etc/swanctl/conf.d/`
```
sudo cp examples/host-to-host/client-right.conf /etc/swanctl/conf.d/host-to-host.conf
```

#### Step 5: Load configs and start as service:
```
sudo systemctl enable --now strongswan-starter.service
sudo swanctl --load-all
```

#### Step 6: Connect to VPN:
```
sudo swanctl --initiate --child net
sudo swanctl --list-sas
```