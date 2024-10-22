clear;
rm -rf ewm-das;
echo "========================================"
echo "=    EWM light-client auto installer   ="
echo "=          Created by : Mr9868         ="
echo "=   Github : https://github.io/Mr9868  ="
echo "========================================\n"
read -p "Put your Private Keys" pkey
if [$pkey = ""]; then
    echo "Please put your Private key !"
else
apt update -y && apt upgrade -y && apt install screen -y
git clone https://github.com/covalenthq/ewm-das
cd ewm-das
wget -O go-latest.tar.gz https://go.dev/dl/go1.23.2.linux-amd64.tar.gz && sudo tar -C /usr/local -xzf go-latest.tar.gz 
echo "" >> ~/.bashrc
echo 'export GOPATH=$HOME/go' >> ~/.bashrc
echo 'export GOROOT=/usr/local/go' >> ~/.bashrc
echo 'export GOBIN=$GOPATH/bin' >> ~/.bashrc
echo 'export PATH=$PATH:/usr/local/go/bin:$GOBIN' >> ~/.bashrc
source ~/.bashrc
go install honnef.co/go/tools/cmd/staticcheck@latest && make deps && make  && sudo bash install-trusted-setup.sh
wget https://dist.ipfs.tech/kubo/v0.30.0/kubo_v0.30.0_linux-amd64.tar.gz && tar -xvzf kubo_v0.30.0_linux-amd64.tar.gz && sudo bash kubo/install.sh && screen -S ipfs -dm bash -c "ipfs daemon --init"  && screen -S covalent -dm bash -c "./bin/light-client --rpc-url wss://coordinator.das.test.covalentnetwork.org/v1/rpc --collect-url https://us-central1-covalent-network-team-sandbox.cloudfunctions.net/ewm-das-collector --private-key $pkey"
echo "SETUP INSTALLED SUCCESSFULLY !"
echo "To view ipfs log execute screen -r ipfs"
echo "To view node log execute screen -r covalent"
fi
