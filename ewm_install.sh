# WELCOME, don't forget to leave a star to my project :) mr9868


# Make sure there is nothing complicated
goLts="1.23.2" &&
ipfsLts="31" &&
cfgDir=~/ewm-das/.mr9868/config;


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
bash -c "wget -O go-latest.tar.gz https://go.dev/dl/go${goLts}.linux-amd64.tar.gz" &&
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
bash -c "wget -O ipfs-latest.tar.gz https://dist.ipfs.tech/kubo/v0.${ipfsLts}.0/kubo_v0.${ipfsLts}.0_linux-amd64.tar.gz" &&
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
echo "Your go version '${version}' is outdated, Updating your go ...";sleep 5; installGo;
else 
echo "Your go version '${version}' is up to date, Next step ...";sleep 5;
fi
unset IFS;
}

# Check if installed go is not outdated
function checkIpfs(){
command -v ipfs >/dev/null 2>&1 || { echo >&2 "IPFS is not found on this machine, Installing IPFS ... ";sleep 5;installIpfs;}
v=`ipfs version | { read _ _ v _; echo ${v#gipfs}; }`
IFS="." tokens=( ${v} );
version=${tokens[1]};
if (($version<${ipfsLts})); then 
echo "Your IPFS version '${version}' is outdated, Updating your IPFS ...";sleep 5; installIpfs;
else 
echo "Your IPFS version '${version}' is up to date, Next step ...";sleep 5;
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
export iLoop=1
export jLoop=$loop
export kLoop=$loop
echo $iLoop > $cfgDir
echo $jLoop > $cfgDir
echo $kLoop > $cfgDir

if [[ "${dirFound}" =~ ^([yY][eE][sS]|[yY])$ ]];
then
export iLoop=$kLoop
export jLoop=$iLoop+$loop
export kLoop=$jLoop
sed -i -e "s/iLoop/${iLoop}/g" $cfgDir
sed -i -e "s/jLoop/${jLoop}/g" $cfgDir
sed -i -e "s/kLoop/${kLoop}/g" $cfgDir
else
export iLoop=1
export jLoop=$loop
export kLoop=$loop
echo $iLoop > $cfgDir
echo $jLoop > $cfgDir
echo $kLoop > $cfgDir
fi
for i in $(seq $iLoop $jLoop);
do
myHeader;
echo "How many light-node do you want to run  : ${loop}"
read -p "$(eval 'echo -e "Input your \033[1;33m client $i \033[0m hexadecimal Private Keys ( without 0x ) : "')" pkey
varInputPkey="pkey${i}=${pkey}"
eval $varInputPkey
varPkey=$(eval "echo \$pkey${i}")
#echo 'export pkey'$i'='$(eval $varPkey)'' >> ~/.bashrc
until [[ "${pkey}" =~ ^[0-9a-fA-F]{64}$ ]]
do
  myHeader;
  echo "How many light-node do you want to run  : ${loop}"
  echo "Error: PRIVATE_KEY is not a valid 64-character hexadecimal number."
  read -p "$(eval 'echo -e "Input your \033[1;33m client $i \033[0m hexadecimal Private Keys ( without 0x ) : "')" pkey
  varInputPkey="pkey${i}=${pkey}"
  eval $varInputPkey
  varPkey=$(eval "echo \$pkey${i}")
done
done
}

# Entrypoint for telegram monitor question
function entryPointTg(){
read -p "Do you want to add telegram monitor ? (y/n)  : " tgQn
if [[ "${tgQn}" =~ ^([yY][eE][sS]|[yY])$ ]];
then
read -p "Please provide your bot API Key from @botFather : " tgApiQn
read -p "Please provide your telegram ID's from @getidsbot : " tgIdQn
# echo "tgId:"$tgIdQn"" >> ~/.bashrc
# echo "tgApi:"$tgApiQn"" >> ~/.bashrc
else
echo "See yaa ..."
fi
}

function tgConf(){
echo "
# Send tg message
function tgMsg(){
# Set the API token and chat ID
API_TOKEN=\"${tgApiQn}\"
CHAT_ID=\"${tgIdQn}\"
MESSAGE=\$(eval \" echo 'Please wait ....'\"); 
curl -s -X POST https://api.telegram.org/bot\${API_TOKEN}/sendMessage -d chat_id=\${CHAT_ID} -d text=\"\${MESSAGE}\"
sleep 120;
for akun in \$(seq ${iLoop} ${jLoop});
do  
MESSAGE=\$(eval \" cat ipfs\${akun}.log | grep ready\"); 
curl -s -X POST https://api.telegram.org/bot\${API_TOKEN}/sendMessage -d chat_id=\${CHAT_ID} -d text=\"\${MESSAGE}\"
msgStart=\$(eval \" cat covalent\${akun}.log | awk '{print tolower(\\\$0)}' | grep -ow '\w*0x\w*'\")
accStart=\$(eval \" echo 'Address \${akun} : \\\`\${msgStart}\\\`'\")
curl -s -X POST https://api.telegram.org/bot\${API_TOKEN}/sendMessage -d chat_id=\${CHAT_ID} -d text=\"\${accStart}\" -d parse_mode='MarkdownV2'
done

while sleep 1800;
do
for i in \$(seq ${iLoop} ${jLoop});
do  
msgCount=\$(eval \" cat covalent\${i}.log | grep -c 'verified'\")
msgError=\$(eval \" cat covalent\${i}.log | grep -E 'FATAL|ERROR'\")
ipfsError=\$(eval \" cat ipfs\${i}.log | grep 'ERROR'\")
accMsg=\$(eval \"echo ' Account \${i} has \${msgCount} verified samples'\")  
curl -s -X POST https://api.telegram.org/bot\${API_TOKEN}/sendMessage -d chat_id=\${CHAT_ID} -d text=\"\${ipfsError}\"
curl -s -X POST https://api.telegram.org/bot\${API_TOKEN}/sendMessage -d chat_id=\${CHAT_ID} -d text=\"\${msgError}\"                
curl -s -X POST https://api.telegram.org/bot\${API_TOKEN}/sendMessage -d chat_id=\${CHAT_ID} -d text=\"\${accMsg}\"                
# Use the curl command to send the message       
done
done
}
tgMsg;
" > ~/ewm-das/.mr9868/tgConf${iLoop}.sh
}


# Run light-client node
function runLightClient(){
for i in $(seq ${iLoop} ${jLoop});
do
varPkey=$(eval "echo \$pkey${i}")
if [[ "${ipfsQn}" =~ ^([yY][eE][sS]|[yY])$ ]];
then
if [[ "${ipfsAutoQn}" =~ ^([yY][eE][sS]|[yY])$ ]];
then
screen -dmS covalent${i} -L -Logfile covalent${i}.log bash -c "sudo light-client --rpc-url wss://coordinator.das.test.covalentnetwork.org/v1/rpc --collect-url https://us-central1-covalent-network-team-sandbox.cloudfunctions.net/ewm-das-collector --ipfs-addr :${mainPort} --private-key ${varPkey} ;exec bash"
else
screen -dmS covalent${i} -L -Logfile covalent${i}.log bash -c "sudo light-client --rpc-url wss://coordinator.das.test.covalentnetwork.org/v1/rpc --collect-url https://us-central1-covalent-network-team-sandbox.cloudfunctions.net/ewm-das-collector --ipfs-addr :${mainPort} --private-key ${varPkey} ;exec bash"
fi
else
screen -dmS covalent${i} -L -Logfile covalent${i}.log bash -c "sudo light-client --rpc-url wss://coordinator.das.test.covalentnetwork.org/v1/rpc --collect-url https://us-central1-covalent-network-team-sandbox.cloudfunctions.net/ewm-das-collector --private-key ${varPkey} ;exec bash"
fi
done
}

# Covalent log
function covalentLog(){

if [[ "${ipfsAutoQn}" =~ ^([yY][eE][sS]|[yY])$ ]];
then
for i in $(seq ${iLoop} ${jLoop});
do
echo "To view node${i} log execute 'screen -r covalent${i}'"
echo "To view ipfs${i} log execute 'screen -r ipfs${i}'"
done
else
for i in $(seq ${iLoop} ${jLoop});
do
echo "To view node${i} log execute 'screen -r covalent${i}'"
done
echo "To view ipfs log execute 'screen -r ipfs'"
fi
}

function tgInit(){
if [[ "${tgQn}" =~ ^([yY][eE][sS]|[yY])$ ]];
then
tgConf;
screen -dmS ewmLog bash -c "chmod 777 ~/.mr9868/tgConf${iLoop}.sh;bash ~/.mr9868/tgConf${iLoop}.sh;exec bash"
else
echo "Telegram bot: Not configured, Next ..."
fi
}

function ipfsConf(){
if [[ "${ipfsAutoQn}" =~ ^([yY][eE][sS]|[yY])$ ]];
then
mainPort="500${i}"
secPort="400${i}"
trdPort="808${i}"
else
i=${iLoop}
fi
echo '
{
  "API": {
    "HTTPHeaders": {}
  },
  "Addresses": {
    "API": "/ip4/127.0.0.1/tcp/'${mainPort}'",
    "Announce": null,
    "AppendAnnounce": null,
    "Gateway": "/ip4/127.0.0.1/tcp/'${trdPort}'",
    "NoAnnounce": null,
    "Swarm": [
      "/ip4/0.0.0.0/tcp/'${secPort}'",
      "/ip6/::/tcp/'${secPort}'",
      "/ip4/0.0.0.0/udp/'${secPort}'/webrtc-direct",
      "/ip4/0.0.0.0/udp/'${secPort}'/quic-v1",
      "/ip4/0.0.0.0/udp/'${secPort}'/quic-v1/webtransport",
      "/ip6/::/udp/'${secPort}'/webrtc-direct",
      "/ip6/::/udp/'${secPort}'/quic-v1",
      "/ip6/::/udp/'${secPort}'/quic-v1/webtransport"
    ]
  },
  "AutoNAT": {},
  "Bootstrap": [
    "/dnsaddr/bootstrap.libp2p.io/p2p/QmNnooDu7bfjPFoTZYxMNLWUQJyrVwtbZg5gBMjTezGAJN",
    "/dnsaddr/bootstrap.libp2p.io/p2p/QmQCU2EcMqAqQPR2i9bChDtGNJchTbq5TbXJJ16u19uLTa",
    "/dnsaddr/bootstrap.libp2p.io/p2p/QmbLHAnMoJPWSCR5Zhtx6BHJX9KiKNN6tpvbUcqanj75Nb",
    "/dnsaddr/bootstrap.libp2p.io/p2p/QmcZf59bWwK5XFi76CZX8cbJ4BhTzzA3gU1ZjYZcYW3dwt",
    "/ip4/104.131.131.82/tcp/4001/p2p/QmaCpDMGvV2BGHeYERUEnRQAwe3N8SzbUtfsmvsqQLuvuJ",
    "/ip4/104.131.131.82/udp/4001/quic-v1/p2p/QmaCpDMGvV2BGHeYERUEnRQAwe3N8SzbUtfsmvsqQLuvuJ"
  ],
  "DNS": {
    "Resolvers": {}
  },
  "Datastore": {
    "BloomFilterSize": 0,
    "GCPeriod": "1h",
    "HashOnRead": false,
    "Spec": {
      "mounts": [
        {
          "child": {
            "path": "blocks",
            "shardFunc": "/repo/flatfs/shard/v1/next-to-last/2",
            "sync": true,
            "type": "flatfs"
          },
          "mountpoint": "/blocks",
          "prefix": "flatfs.datastore",
          "type": "measure"
        },
        {
          "child": {
            "compression": "none",
            "path": "datastore",
            "type": "levelds"
          },
          "mountpoint": "/",
          "prefix": "leveldb.datastore",
          "type": "measure"
        }
      ],
      "type": "mount"
    },
    "StorageGCWatermark": 90,
    "StorageMax": "10GB"
  },
  "Discovery": {
    "MDNS": {
      "Enabled": true
    }
  },
  "Experimental": {
    "FilestoreEnabled": false,
    "Libp2pStreamMounting": false,
    "OptimisticProvide": false,
    "OptimisticProvideJobsPoolSize": 0,
    "P2pHttpProxy": false,
    "StrategicProviding": false,
    "UrlstoreEnabled": false
  },
  "Gateway": {
    "DeserializedResponses": null,
    "DisableHTMLErrors": null,
    "ExposeRoutingAPI": null,
    "HTTPHeaders": {},
    "NoDNSLink": false,
    "NoFetch": false,
    "PublicGateways": null,
    "RootRedirect": ""
  },
  "Identity": {
    "PeerID": "12D3KooWQHfx6z8tYf35wPpidxEnom4cczkg55fUBU2wpFRwxdek",
    "PrivKey": "CAESQNbZWjzcfuv2euUlx2c8o+XoxAlHhaG+jEI7FvzsiLGC1wJnsaxmbVj2ieVryhlrzKAaoXF4iU+D9ry52cKBSZU="
  },
  "Import": {
    "CidVersion": null,
    "HashFunction": null,
    "UnixFSChunker": null,
    "UnixFSRawLeaves": null
  },
  "Internal": {},
  "Ipns": {
    "RecordLifetime": "",
    "RepublishPeriod": "",
    "ResolveCacheSize": 128
  },
  "Migration": {
    "DownloadSources": [],
    "Keep": ""
  },
  "Mounts": {
    "FuseAllowOther": false,
    "IPFS": "/ipfs",
    "IPNS": "/ipns"
  },
  "Peering": {
    "Peers": null
  },
  "Pinning": {
    "RemoteServices": {}
  },
  "Plugins": {
    "Plugins": null
  },
  "Provider": {
    "Strategy": ""
  },
  "Pubsub": {
    "DisableSigning": false,
    "Router": ""
  },
  "Reprovider": {},
  "Routing": {
    "Methods": null,
    "Routers": null
  },
  "Swarm": {
    "AddrFilters": null,
    "ConnMgr": {},
    "DisableBandwidthMetrics": false,
    "DisableNatPortMap": false,
    "RelayClient": {},
    "RelayService": {},
    "ResourceMgr": {},
    "Transports": {
      "Multiplexers": {},
      "Network": {},
      "Security": {}
    }
  }
}
' > ~/.ipfs${i}/config

echo '{"mounts":[{"mountpoint":"/blocks","path":"blocks","shardFunc":"/repo/flatfs/shard/v1/next-to-last/2","type":"flatfs"},{"mountpoint":"/","path":"datastore","type":"levelds"}],"type":"mount"}' > ~/.ipfs${i}/datastore_spec
echo '16' > ~/.ipfs${i}/version
}

# ipfs entrypoint
function entryPointIpfs(){
if [[ "${ipfsQn}" =~ ^([yY][eE][sS]|[yY])$ ]];
then
if [[ "${ipfsAutoQn}" =~ ^([yY][eE][sS]|[yY])$ ]];
then
for i in $(seq ${iLoop} ${jLoop});
do
sudo ufw allow 50${i}
sudo ufw allow 40${i}
sudo ufw allow 80${i}
mkdir ~/.ipfs${i}
ipfsConf
screen -dmS ipfs${i} -L -Logfile ipfs${i}.log bash -c "IPFS_PATH=~/.ipfs${i} ipfs daemon --init;exec bash;" 
done
else
read -p "Set main port eg. 5001 : " mainPort
until [[ ${mainPort} =~ ^[0-9]{4}$ ]]
do
echo "Please input in 4 digits number !"
read -p "Set main port eg. 5001 : " mainPort
done
read -p "Set second port eg. 4001 : " secPort
until [[ ${secPort} =~ ^[0-9]{4}$ ]]
do
echo "Please input in 4 digits number !"
read -p "Set second port eg. 4001 : " secPort
done
read -p "Set third port eg. 8080 : " trdPort
until [[ ${trdPort} =~ ^[0-9]{4}$ ]]
do
echo "Please input in 4 digits number !"
read -p "Set trd port eg. 8080 : " trdPort
done
if [[ "${mainPort}" == "" ]];
then
mainPort="500${iLoop}"
fi
if [[ "${secPort}" == "" ]];
then
secPort="4001${iLoop}"
fi
if [[ "${trdPort}" == "" ]];
then
trdPort="8080${iLoop}"
fi
sudo ufw allow ${mainPort}
sudo ufw allow ${secPort}
sudo ufw allow ${trdPort}
mkdir ~/.ipfs${iLoop}
ipfsConf
screen -dmS ipfs${iLoop} -L -Logfile ipfs${iLoop}.log bash -c "IPFS_PATH=~/.ipfs${iLoop} ipfs daemon --init;exec bash;" 
fi
else
screen -dmS ipfs${iLoop} -L -Logfile ipfs${iLoop}.log bash -c "IPFS_PATH=~/.ipfs${iLoop} ipfs daemon --init;exec bash;" 
fi
}
function startUp(){
cd;
myHeader;
if [ -f ~/ewm-das ]
then
   if [ -f $cfgDir ]
   then
     read -p "ewm-das directories found ! do you want to add light-client or running from stratch ? (y/n) : " dirFound
     if [[ "${dirFound}" =~ ^([yY][eE][sS]|[yY])$ ]];
     then
     source $cfgFir
     installer
     else
     rm -rf $cfgDir
     notInstalled
     installer
     fi
   else
   myHeader
   notInstalled
   installer
   fi
else
   myHeader
   notInstalled
   installer
fi
}
function notInstalled(){
     sudo rm -rf ~/ewm-das
     sudo rm -rf ~/.ipfs*
     sudo pkill -f "covalent*"
     sudo pkill -f "ipfs*"
     checkGo &&
     checkIpfs 
# Install ewm-das
     git clone https://github.com/covalenthq/ewm-das  &&
     cd ewm-das &&
     mkdir ~/ewm-das/.mr9868 
     }

function installer(){
myHeader;
echo "Installing required dependencies ..."
   command -v screen >/dev/null 2>&1 || { echo >&2 "Screen is not found on this machine, Installing screen ... "; sleep 5;sudo apt install screen -y;} 
   command -v git >/dev/null 2>&1 || { echo >&2 "Git is not found on this machine, Installing git ... "; sleep 5;sudo apt install git -y;}
   command -v wget >/dev/null 2>&1 || { echo >&2 "Wget is not found on this machine, Installing Wget ... "; sleep 5;sudo apt install wget -y;}
   command -v ufw >/dev/null 2>&1 || { echo >&2 "Ufw is not found on this machine, Installing ufw ... "; sleep 5;sudo apt install ufw -y;}
myHeader;  
entryPointPK;
myHeader;
read -p "Do you want to set client port ? (y/n)  : " ipfsQn
echo "Note: If you choose automatic port, light client and IPFS will run different port on each account"
read -p "Do you want to set automatic port ? (y/n)  : " ipfsAutoQn


# Running ipfs daemon
entryPointIpfs &&
entryPointTg;
myHeader;
echo
echo "==================== INSTALLATION START ===================="
echo

if [[ "${dirFound}" =~ ^([yY][eE][sS]|[yY])$ ]];
     then
     echo "Next ..."
     sleep 2;
     else
     # Installing required Go packages
     go install honnef.co/go/tools/cmd/staticcheck@latest && 
     make deps &&
     make  && 
     sudo bash install-trusted-setup.sh &&
     # Installing covalent light-client node
     sudo cp -r bin/light-client /usr/local/bin/light-client 
 fi

runLightClient &&
tgInit &&

# Welldone ! 
myHeader;
covalentLog;
echo
echo "================== INSTALLED DEPENDENCIES =================="
echo
go version
ipfs version
echo
echo "=================== INSTALLATION SUCCESS ==================="
echo
unset $loop;
}

startUp

