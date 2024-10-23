## Why you must install from the source ?
It's so efficient, and easy if you facing any error from the ipfs daemon, because the process is running separately, you can just restart it without restarting the main node. And you can run multiple client in ONE server 🤫
## EWM light-client setup auto installer
```
git clone https://github.com/mr9868/ewm-light-client
cd ewm-light-client 
chmod 777 ewm_install.sh
./ewm_install.sh
```
To check the main node logs :
```
screen -r covalent
```
To check the ipfs daemon logs :
```
screen -r ipfs
```
if you want to run multiple node, just start a screen and execute this :
```
sudo light-client --rpc-url wss://coordinator.das.test.covalentnetwork.org/v1/rpc --collect-url https://us-central1-covalent-network-team-sandbox.cloudfunctions.net/ewm-das-collector --private-key YOUR_PRIVATEKEY
```

if you facing any error on the ipfs daemon you can just :
``` 
screen -r ipfs
```
then ctrl + c to stop,
then restart again :
```
ipfs daemon --init
```

## EWM light-client setup manual intalling from source

Clone the repository :
```
git clone https://github.com/covalenthq/ewm-das
cd ewm-das
```
Install Go :
```
wget -O go-latest.tar.gz https://go.dev/dl/go1.23.2.linux-amd64.tar.gz && sudo tar -C /usr/local -xzf go-latest.tar.gz
```
Setup Go :
```
echo "" >> ~/.bashrc
echo 'export GOPATH=$HOME/go' >> ~/.bashrc
echo 'export GOROOT=/usr/local/go' >> ~/.bashrc
echo 'export GOBIN=$GOPATH/bin' >> ~/.bashrc
echo 'export PATH=$PATH:/usr/local/go/bin:$GOBIN' >> ~/.bashrc

source ~/.bashrc
```
Installing  setup :
```
go install honnef.co/go/tools/cmd/staticcheck@latest && make deps && make  && sudo bash install-trusted-setup.sh
```
install ipfs :
```
wget https://dist.ipfs.tech/kubo/v0.30.0/kubo_v0.30.0_linux-amd64.tar.gz && tar -xvzf kubo_v0.30.0_linux-amd64.tar.gz
&& sudo bash kubo/install.sh
```
make a screen and starting ipfs daemon :
```
apt install screen -y && screen -S ipfs && ipfs daemon --init
```
Close the screen by pressing ctrl+a+d

Then execute this command :
```
screen -S covalent && ./bin/light-client --rpc-url wss://coordinator.das.test.covalentnetwork.org/v1/rpc --collect-url https://us-central1-covalent-network-team-sandbox.cloudfunctions.net/ewm-das-collector --private-key YOUR_PRIVATEKEY
```
