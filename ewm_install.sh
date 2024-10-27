# WELCOME, don't forget to leave a star to my project :) mr9868


# Make sure there is nothing complicated
cd;
sudo rm -rf ewm-das;
sudo pkill -f "covalent" &&
sudo pkill -f "ipfs" &&
goLts="1.23.2" &&
ipfsLts="31"

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
rm -rf go-latest.tar.gz;
}

# Installing IPFS function
function installIpfs(){
bash -c "wget -O ipfs-latest.tar.gz https://dist.ipfs.tech/kubo/v0."$ipfsLts".0/kubo_v0."$ipfsLts".0_linux-amd64.tar.gz" &&
rm -rf kubo &&
tar -xvzf ipfs-latest.tar.gz &&
sudo rm -rf /usr/local/bin/ipfs &&
sudo pkill -f "ipfs" &&
sudo bash kubo/install.sh && 
source ~/.bashrc 
rm -rf ipfs-latest.tar.gz;
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
}

# Check if installed go is not outdated
function checkIpfs(){
command -v ipfs >/dev/null 2>&1 || { echo >&2 "IPFS is not found on this machine, Installing IPFS ... ";sleep 5;installIpfs;}
v=`ipfs version | { read _ _ v _; echo ${v#gipfs}; }`
IFS="." tokens=( ${v} );
version=${tokens[1]};
if (($version<$ipfsLts)); then 
echo "Your IPFS version '"$version"' is outdated, Updating your IPFS ...";sleep 5; installIpfs;
else 
echo "Your IPFS version '"$version"' is up to date, Next step ...";sleep 5;
fi
unset IFS;
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
echo "How many light-node do you want to run  : "$loop""
read -p "Input your client "$i" hexadecimal Private Keys ( without 0x ) : " pkey
varInputPkey="pkey$i=$pkey"
eval $varInputPkey
varPkey="echo \$pkey$i"
#echo 'export pkey'$i'='$(eval $varPkey)'' >> ~/.bashrc
until [[ "$pkey" =~ ^[0-9a-fA-F]{64}$ ]]
do
  myHeader;
  echo "Error: PRIVATE_KEY is not a valid 64-character hexadecimal number."
  echo "How many light-node do you want to run  : "$loop""
  read -p "Input your client "$i" hexadecimal Private Keys ( without 0x ) : " pkey
  varInputPkey="pkey$i=$pkey"
  eval $varInputPkey
  varPkey="echo \$pkey$i"
done
done
}

# Entrypoint for telegram monitor question
function entryPointTg(){
read -p "Do you want to add telegram monitor ? (y/n)  : " tgQn
if [[ "$tgQn" =~ ^([yY][eE][sS]|[yY])$ ]];
then
read -p "Please provide your bot API Key from @botFather : " tgApiQn
read -p "Please provide your telegram ID's from @getidsbot : " tgIdQn
tgMsg;
screen -dmS ewmLog bash -c "chmod 777 tgMsg.sh; bash tgMsg.sh;exec bash"
# echo "tgId:"$tgIdQn"" >> ~/.bashrc
# echo "tgApi:"$tgApiQn"" >> ~/.bashrc
else
echo "Next step ..."
fi
}

function tgMsg(){
echo "
# Send tg message
function tgMsg(){
# Set the API token and chat ID
API_TOKEN=$tgApiQn   
CHAT_ID=$tgIdQn
MESSAGE=\$(eval 'cat ipfs.log');   
curl -s -X POST https://api.telegram.org/bot\$API_TOKEN/sendMessage -d chat_id=\$CHAT_ID -d text='\$MESSAGE'

while sleep 10;
do
for i in \$(seq 1 $loop);
do       
varLog='cat covalent"$i".log | grep -c verified=true'

# Set the message text                     
MESSAGE='Account "$i": \$(eval \$varLog) block verified'; 
# Use the curl command to send the message       
curl -s -X POST https://api.telegram.org/bot\$API_TOKEN/sendMessage -d chat_id=\$CHAT_ID -d text='\$MESSAGE'
done
done
}
tgMsg
" > tgMsg.sh
}


# Run light-client node
function runLightClient(){
for i in $(seq 1 $loop);
do
varPkeyLc=$(eval "echo \$pkey$i")
screen -dmS covalent$i bash -c "sudo light-client --rpc-url wss://coordinator.das.test.covalentnetwork.org/v1/rpc --collect-url https://us-central1-covalent-network-team-sandbox.cloudfunctions.net/ewm-das-collector --private-key "$varPkeyLc" > covalent"$i".log;exec bash"
done
}

# Covalent log
function covalentLog(){
for i in $(seq 1 $loop);
do
echo "To view node log execute 'screen -r covalent"$i"'"
done
unset i
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
checkGo &&
checkIpfs &&
git clone https://github.com/covalenthq/ewm-das && 
cd ewm-das && 
sudo bash install-trusted-setup.sh &&

# Installing required Go packages
go install honnef.co/go/tools/cmd/staticcheck@latest && 
make deps &&
make  && 
sudo bash install-trusted-setup.sh &&

# Running ipfs daemon
screen -dmS ipfs bash -c "ipfs daemon --init > ipfs.log;exec bash;" && 

# Installing covalent light-client node
sudo cp -r bin/light-client /usr/local/bin/light-client && 
runLightClient &&

# Welldone ! 
myHeader;
echo "To view ipfs log execute 'screen -r ipfs'"
covalentLog;
echo
echo "================== INSTALLED DEPENDENCIES =================="
echo
go version
ipfs version
echo
echo "=================== INSTALLATION SUCCESS ==================="
echo
entryPointTg;
unset $loop;
