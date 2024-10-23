# WELCOME, don't forget to leave a star to my project :) mr9868
# Make sure there is nothing complicated
clear;
rm -rf ewm-das;
pkill -f "ipfs";
pkill -f "covalent";
sudo rm -rf /usr/local/bin/ipfs;

# My Header function
function myHeader(){
echo -e "========================================"
echo -e  "=    EWM light-client auto installer   ="
echo -e "=          Created by : Mr9868         ="
echo -e "=   Github : https://github.io/Mr9868  ="
echo -e "========================================\n"
}

# Go install function
function installGo(){
wget -O go-latest.tar.gz https://go.dev/dl/go1.23.2.linux-amd64.tar.gz && 
sudo tar -C /usr/local -xzf go-latest.tar.gz && 
echo "" >> ~/.bashrc
echo 'export GOPATH=$HOME/go' >> ~/.bashrc
echo 'export GOROOT=/usr/local/go' >> ~/.bashrc
echo 'export GOBIN=$GOPATH/bin' >> ~/.bashrc
echo 'export PATH=$PATH:/usr/local/go/bin:$GOBIN' >> ~/.bashrc
source ~/.bashrc
}

myHeader;
read -p "Input your Private Keys : " pkey
read -p "Choose ipfs version (30/31) :" ipfsv
if [[ "$pkey" = "" ]]; then
    echo "Please put your Private key !"
    elif [[ "$ipfsv" = "" ]]; then
    echo "Please put your ipfs version !"
else

# Import private key to bashrc
echo 'pkey="'$pkey'"' >> ~/.bashrc

# Installing required package
sudo apt update -y && 
sudo apt upgrade -y && 
sudo apt install screen -y && 
git clone https://github.com/covalenthq/ewm-das && 
cd ewm-das && 
sudo bash install-trusted-setup.sh;

# Check if go is installed on machine or not
command -v go >/dev/null 2>&1 || { echo >&2 "Go is not found on this machine, Installing go ... "; sleep 5;installGo;}

# Check if installed go is not outdated
v=`go version | { read _ _ v _; echo ${v#go}; }`
IFS="." tokens=( ${v} );
version=${tokens[1]};
if (($version<23)); then echo "Your go version '"$version"' is outdated, Updating your go ...";sleep 5; installGo;
else echo "Your go version '"$version"' is updated, Next step ...";sleep 5;
fi
unset IFS;

# Installing required Go packages
go install honnef.co/go/tools/cmd/staticcheck@latest && 
make deps &&
make  && 
sudo bash install-trusted-setup.sh &&

# Installing ipfs kubo
bash -c "wget -O ipfs-latest.tar.gz https://dist.ipfs.tech/kubo/v0."$ipfsv".0/kubo_v0."$ipfsv".0_linux-amd64.tar.gz" &&
tar -xvzf ipfs-latest.tar.gz &&
sudo bash kubo/install.sh && 
source ~/.bashrc && 
screen -dmS ipfs bash -c "ipfs daemon --init;exec bash;" && 

# Installing covalent light-client node
sudo cp -r bin/light-client /usr/local/bin/light-client && 
screen -dmS covalent bash -c "sudo light-client --rpc-url wss://coordinator.das.test.covalentnetwork.org/v1/rpc --collect-url https://us-central1-covalent-network-team-sandbox.cloudfunctions.net/ewm-das-collector --private-key $pkey;exec bash"
rm -rf go-latest.tar.gz &&
rm -rf ipfs-latest.tar.gz

# Welldone ! 
clear;
myHeader;
echo "SETUP INSTALLED SUCCESSFULLY !"
echo "To view ipfs log execute 'screen -r ipfs'"
echo "To view node log execute 'screen -r covalent'"
go version
ipfs version
fi
