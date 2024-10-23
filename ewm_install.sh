# WELCOME, don't forget to leave a star to my project :) mr9868
# Make sure there is nothing complicated
rm -rf ewm-das;
pkill -f "ipfs";
pkill -f "covalent";
sudo rm -rf /usr/local/bin/ipfs;

# My Header function
function myHeader(){
clear;
echo -e "========================================"
echo -e  "=    EWM light-client auto installer   ="
echo -e "=          Created by : Mr9868         ="
echo -e "=   Github : https://github.io/Mr9868  ="
echo -e "========================================\n"
}

# Entrypoint Private Key input function
function entryPointPK(){
if [ -z "$pkey" ]; then
  echo "Error: PRIVATE_KEY environment variable is not set."
  exit 1
fi

# Check if PRIVATE_KEY is a valid 64-character hexadecimal number
if ! [[ "$pkey" =~ ^[0-9a-fA-F]{64}$ ]]; then
  echo "Error: PRIVATE_KEY is not a valid 64-character hexadecimal number."
  echo "Please input PRIVATE_KEY without '0x' !"
  exit 1
fi
}

function entryPointIPFS(){
until [[ $ipfsv =~ ^[+]?[0-9]{2}+$ ]]
do
    echo "Oops! User input was not 2 characters and/or not a positive integer!"; 
    exit 1
done

# Check if ipfs version is smaller than requirement
if (($ipfsv<30)); then
    echo "Error: IPFS version is not set.";
    echo "Select to latest version ...";sleep 5;
    ipfsv="30"
fi

# Check if user set null for ipfs version
ipfslts="31"
if [[ "$ipfsv" = "" ]]; then
    echo "Error: IPFS version is not set.";
    echo "Select to latest version ...";sleep 5;
    ipfsv="30"
fi
# Check if user set greater than latest version for ipfs version
if (($ipfsv>$ipfslts)); then
    echo "Error: You are set the IPFS version greater than the latest version.";
    echo "Select to latest version ..."; sleep 5; ipfsv=$ipfslts;
fi

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
read -p "Input your hexadecimal Private Keys : " pkey
entryPointPK;
read -p "Choose ipfs version (29/30/31) :" ipfsv
entryPointIPFS;
# Import private key to bashrc
echo 'pkey="'$pkey'"' >> ~/.bashrc

# Installing required package
# sudo apt update -y && 
# sudo apt upgrade -y && 
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
if (($version<23)); then 
echo "Your go version '"$version"' is outdated, Updating your go ...";sleep 5; installGo;
else 
echo "Your go version '"$version"' is up to date, Next step ...";sleep 5;
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
myHeader;
echo "SETUP INSTALLED SUCCESSFULLY !"
echo "To view ipfs log execute 'screen -r ipfs'"
echo "To view node log execute 'screen -r covalent'"
go version
ipfs version
