# Covalent light-client installer 
WELCOME, and don't forget to leave a star to my project :) 
## Why you must install from the source ?
It's so efficient, and easy if you facing any error from the ipfs daemon, because the process is running separately, you can just restart it without restarting the main node. And you can run multiple client in ONE server 🤫
## EWM light-client setup auto installer
```
wget https://raw.githubusercontent.com/mr9868/ewm-light-client/refs/heads/main/ewm_install.sh && chmod 777 ewm_install.sh && ./ewm_install.sh && rm ewm_install.sh
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
sudo light-client --rpc-url wss://coordinator.das.test.covalentnetwork.org/v1/rpc --collect-url https://us-central1-covalent-network-team-sandbox.cloudfunctions.net/ewm-das-collector --private-key $pkey
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
then close again the screen by pressing ctrl + a +d

## EWM light-client setup manual intalling from source 
Warning : don't do this if you already following step above ( Auto Installation )

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
apt install screen -y && screen -dmS ipfs bash -c "ipfs daemon --init;exec bash"
```
Close the screen by pressing ctrl+a+d

Then execute this command :
' Dont forget to change YOUR_PRIVATEKEY to your private key '
```
screen -S covalent2
```
```
sudo ./bin/light-client --rpc-url wss://coordinator.das.test.covalentnetwork.org/v1/rpc --collect-url https://us-central1-covalent-network-team-sandbox.cloudfunctions.net/ewm-das-collector --private-key YOUR_PRIVATEKEY
```
