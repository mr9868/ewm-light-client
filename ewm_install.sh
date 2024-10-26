# WELCOME, don't forget to leave a star to my project :) mr9868


# Make sure there is nothing complicated
sudo rm -rf ewm-das;
sudo pkill -f "covalent";
goLts="1.23.2"
ipfsLts="0.31.0"

# My Header function
function myHeader(){
clear;
echo -e "============================================================"
echo -e "=              EWM light-client auto installer             ="
echo -e "=                    Created by : Mr9868                   ="
echo -e "=             Github : https://github.io/Mr9868            ="
echo -e "============================================================\n"
}

# Go install function
function installGo(){
bash -c "wget -O go-latest.tar.gz https://go.dev/dl/go"$goLts".linux-amd64.tar.gz" &&
sudo tar -C /usr/local -xzf go-latest.tar.gz && 
echo "" >> ~/.bashrc
echo 'export GOPATH=$HOME/go' >> ~/.bashrc
echo 'export GOROOT=/usr/local/go' >> ~/.bashrc
echo 'export GOBIN=$GOPATH/bin' >> ~/.bashrc
echo 'export PATH=$PATH:/usr/local/go/bin:$GOBIN' >> ~/.bashrc
source ~/.bashrc
}

# Installing IPFS function
function installIpfs(){
bash -c "wget -O ipfs-latest.tar.gz https://dist.ipfs.tech/kubo/v"$ipfsLts"/kubo_v"$ipfsLts"_linux-amd64.tar.gz" &&
tar -xvzf ipfs-latest.tar.gz &&
sudo bash kubo/install.sh && 
source ~/.bashrc 
}

# Check if installed go is not outdated
function checkGo(){
command -v go >/dev/null 2>&1 || { echo >&2 "Go is not found on this machine, Installing go ... "; sleep 5;installGo;}
v=`go version | { read _ _ v _; echo ${v#go}; }`
IFS="." tokens=( ${v} );
version=${tokens[1]};
if (($version<23)); then 
echo "Your go version '"$version"' is outdated, Updating your go ...";sleep 5; installGo;
else 
echo "Your go version '"$version"' is up to date, Next step ...";sleep 5;
fi
unset IFS;
unset tokens;
unset v;
unset version;
}

# Check if installed go is not outdated
function checkIpfs(){
command -v ipfs >/dev/null 2>&1 || { echo >&2 "IPFS is not found on this machine, Installing IPFS ... "; sleep 5;installIpfs;}
v=`ipfs version | { read _ _ v _; echo ${v#go}; }`
IFS="." tokens=( ${v} );
version=${tokens[1]};
if (($version<$ipfsLts)); then 
echo "Your IPFS version '"$version"' is outdated, Updating your IPFS ...";sleep 5; installIpfs;
else 
echo "Your IPFS version '"$version"' is up to date, Next step ...";sleep 5;
fi
unset IFS;
unset tokens;
unset v;
unset version;
}

# Entrypoint Private Key input function
function entryPointPK(){
# Check if PK meet requirement 
read -p "How many light-node do you want to run  : " loop
until [[ $loop =~ ^[0-9]+$ ]]
do
myHeader;
echo "Error: Please input in number !";
read -p "How many light-node do you want to run  : " loop
done
for i in $(seq 1 $loop);
do
myHeader;
read -p "How many light-node do you want to run  : " $loop
read -p "Input your client "$i" hexadecimal Private Keys ( without 0x ) : " pkey$i
until [[ "$pkey$i" =~ ^[0-9a-fA-F]{64}$ ]]
do
  myHeader;
  read -p "How many light-node do you want to run  : " $loop
  echo "Error: PRIVATE_KEY is not a valid 64-character hexadecimal number."
  echo
  read -p "Input your client "$i" hexadecimal Private Keys ( without 0x ) : " pkey$i
done
done
unset $i
}

myHeader;
entryPointPK;
myHeader;
echo
echo "==================== INSTALLATION START ===================="
echo

# Installing required package
sudo apt install screen -y && 
sudo apt install git -y &&
sudo apt install wget -y &&
git clone https://github.com/covalenthq/ewm-das && 
cd ewm-das && 
sudo bash install-trusted-setup.sh &&

# Check if go and ipfs is installed on machine or not
checkGo &&
checkIpfs &&

# Installing required Go packages
go install honnef.co/go/tools/cmd/staticcheck@latest && 
make deps &&
make  && 
sudo bash install-trusted-setup.sh &&

# Running ipfs daemon
checkIpfs &&
screen -dmS ipfs bash -c "ipfs daemon --init;exec bash;" && 

# Installing covalent light-client node
sudo cp -r bin/light-client /usr/local/bin/light-client && 
screen -dmS covalent bash -c "sudo light-client --rpc-url wss://coordinator.das.test.covalentnetwork.org/v1/rpc --collect-url https://us-central1-covalent-network-team-sandbox.cloudfunctions.net/ewm-das-collector --private-key $pkey;exec bash"
rm -rf go-latest.tar.gz &&
rm -rf ipfs-latest.tar.gz

# Welldone ! 
myHeader;
echo "To view ipfs log execute 'screen -r ipfs'"
echo "To view node log execute 'screen -r covalent'"
echo
echo "================== INSTALLED DEPENDENCIES =================="
echo
go version
ipfs version
echo
echo "=================== INSTALLATION SUCCESS ==================="
echo
