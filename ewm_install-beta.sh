# WELCOME, don't forget to leave a star to my project :) mr9868


# Make sure there is nothing complicated
goLts="1.23.2" &&
ipfsLts="31" &&
cfgDir=~/ewm-das/.mr9868;


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
BASH -c "wget -O go-latest.tar.gz https://go.dev/dl/go${goLts}.linux-amd64.tar.gz" &&
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
for i in $(seq 1 $loop)
do
myHeader;
echo "How many light-node do you want to run  : ${loop}"
read -p "$(eval 'echo -e "Input your \033[1;33m client $i \033[0m hexadecimal Private Keys ( without 0x ) : "')" pkey
until [[ "${pkey}" =~ ^[0-9a-fA-F]{64}$ ]]
do
  myHeader;
  echo "How many light-node do you want to run  : ${loop}"
  echo "Error: PRIVATE_KEY is not a valid 64-character hexadecimal number."
  read -p "$(eval 'echo -e "Input your \033[1;33m client $i \033[0m hexadecimal Private Keys ( without 0x ) : "')" pkey
done
privKey+=("$pkey")
done
if ! [ -f $cfgDir/config ]; 
then
set | grep ^privKey= >> ${cfgDir}/config
else
sed -r -i "s/privKey=.*/$(set | grep ^privKey= )/g" $cfgDir/config
fi
}

# Entrypoint for telegram monitor question
function entryPointTg(){
read -p "Do you want to add telegram monitor ? (y/n)  : " tgQn
if [[ "${tgQn}" =~ ^([yY][eE][sS]|[yY])$ ]];
then
read -p "Please provide your bot API Key from @botFather : " tgApiQn
read -p "Please provide your telegram ID's from @getidsbot : " tgIdQn
echo "tgApiQn=${tgApiQn}" >> ${cfgDir}/config
echo "tgIdQn=${tgIdQn}" >> ${cfgDir}/config
else
echo "See yaa ..."
fi
}

function tgConf(){
echo "
cfgDir=${cfgDir};
. \${cfgDir}/config
# Send tg message
function tgMsg(){
# Set the API token and chat ID
API_TOKEN=\"\${tgApiQn}\"
CHAT_ID=\"\${tgIdQn}\"
MESSAGE=\$(eval \" echo 'Please wait ....'\"); 
curl -s -X POST https://api.telegram.org/bot\${API_TOKEN}/sendMessage -d chat_id=\${CHAT_ID} -d text=\"\${MESSAGE}\"
sleep 120;
for akun in \$(seq 1 \${#privKey[@]});
do  
MESSAGE=\$(eval \" cat ipfs\${akun}.log | grep ready\"); 
curl -s -X POST https://api.telegram.org/bot\${API_TOKEN}/sendMessage -d chat_id=\${CHAT_ID} -d text=\"\${MESSAGE}\"
msgStart=\$(eval \" cat \${cfgDir}/covalent\${akun}.log | awk '{print tolower(\\\$0)}' | grep -ow '\w*0x\w*'\")
accStart=\$(eval \" echo 'Address \${akun} : \\\`\${msgStart}\\\`'\")
curl -s -X POST https://api.telegram.org/bot\${API_TOKEN}/sendMessage -d chat_id=\${CHAT_ID} -d text=\"\${accStart}\" -d parse_mode='MarkdownV2'
done

while sleep 1800;
do
for i in \$(seq 1 \${#privKey[@]});
do  
msgCount=\$(eval \" cat \${cfgDir}/covalent\${i}.log | grep -c 'verified'\")
start=\$(date -d \"-30 minutes\" +'%Y-%m-%d %H:%M:%S')
msgError=\$(awk -v s=\"\$start\" 's<\$0' \${cfgDir}/covalent\${i}.log | grep -E 'FATAL|ERROR')
ipfsError=\$(awk -v s=\"\$start\" 's<\$0' \${cfgDir}/ipfs\${i}.log | grep -E 'FATAL|ERROR')

#msgError=\$(eval \" cat \${cfgDir}/covalent\${i}.log | grep -E 'FATAL|ERROR'\")
#ipfsError=\$(eval \" cat \${cfgDir}/ipfs\${i}.log | grep 'ERROR'\")
accMsg=\$(eval \"echo ' Account \${i} has \${msgCount} verified samples'\")  
curl -s -X POST https://api.telegram.org/bot\${API_TOKEN}/sendMessage -d chat_id=\${CHAT_ID} -d text=\"\${ipfsError}\"
curl -s -X POST https://api.telegram.org/bot\${API_TOKEN}/sendMessage -d chat_id=\${CHAT_ID} -d text=\"\${msgError}\"                
curl -s -X POST https://api.telegram.org/bot\${API_TOKEN}/sendMessage -d chat_id=\${CHAT_ID} -d text=\"\${accMsg}\"                
# Use the curl command to send the message       
done
done
}
tgMsg;
" > ${cfgDir}/tgConf.sh
echo "
cfgDir=${cfgDir};
. \${cfgDir}/config
function runTg(){
screen -dmS ewmLog bash -c \"chmod 777 \${cfgDir}/tgConf.sh;bash \${cfgDir}/tgConf.sh;exec bash\"
}
runTg
" > ${cfgDir}/tgInit.sh
chmod 777 ${cfgDir}/tgInit.sh && bash ${cfgDir}/tgInit.sh &&
echo "Telegram Bot initialized"
}


# Run light-client node
function runLightClient(){
for i in $(seq ${lastKey} ${#privKey[@]});
do
varPkey=${privKey[$(((0-1)+${i}))]}
if [[ "${ipfsQn}" =~ ^([yY][eE][sS]|[yY])$ ]];
then
screen -dmS covalent${i} -L -Logfile ${cfgDir}/covalent${i}.log bash -c "sudo light-client --rpc-url wss://coordinator.das.test.covalentnetwork.org/v1/rpc --collect-url https://us-central1-covalent-network-team-sandbox.cloudfunctions.net/ewm-das-collector --ipfs-addr :${mainPort} --private-key ${varPkey} ;exec bash"
else
screen -dmS covalent${i} -L -Logfile ${cfgDir}/covalent${i}.log bash -c "sudo light-client --rpc-url wss://coordinator.das.test.covalentnetwork.org/v1/rpc --collect-url https://us-central1-covalent-network-team-sandbox.cloudfunctions.net/ewm-das-collector --ipfs-addr :${mainPort} --private-key ${varPkey} ;exec bash"
fi
done
}

# Covalent log
function covalentLog(){

for i in $(seq ${lastKey} ${#privKey[@]});
do
echo "To view node${i} log execute 'screen -r covalent${i}'"
done
echo "To view ipfs${lastKey} log execute 'screen -r ipfs${lastKey}'"
}

function tgInit(){
if [[ "${tgQn}" =~ ^([yY][eE][sS]|[yY])$ ]];
then
tgConf;
else
echo "Telegram bot: Not configured, Next ..."
fi
}

function ipfsConf(){
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
' > ${cfgDir}/.ipfs${lastKey}/config

echo '{"mounts":[{"mountpoint":"/blocks","path":"blocks","shardFunc":"/repo/flatfs/shard/v1/next-to-last/2","type":"flatfs"},{"mountpoint":"/","path":"datastore","type":"levelds"}],"type":"mount"}' > ${cfgDir}/.ipfs${lastKey}/datastore_spec
echo '16' > ${cfgDir}/.ipfs${lastKey}/version
}



# ipfs entrypoint
function entryPointIpfs(){
if [[ "${ipfsQn}" =~ ^([yY][eE][sS]|[yY])$ ]];
then

# Cek main Port
read -p "Set main port eg. 5001 : " mainPort
cekPort=$(eval "lsof -Pi :${mainPort} -sTCP:LISTEN -t")
until [[ ${mainPort} =~ ^[0-9]{4}$ ]]
do
echo "Please input in 4 digits number !"
read -p "Set main port eg. 5001 : " mainPort
cekPort=$(eval "lsof -Pi :${mainPort} -sTCP:LISTEN -t")
done
until [[ -z "$cekPort" ]]
do
echo "Port ${mainPort} is already in use !"
read -p "Set main port eg. 5001 : " mainPort
cekPort=$(eval "lsof -Pi :${mainPort} -sTCP:LISTEN -t")
done

# Cek sec Port
read -p "Set main port eg. 5001 : " secPort
cekPort=$(eval "lsof -Pi :${secPort} -sTCP:LISTEN -t")
until [[ ${secPort} =~ ^[0-9]{4}$ ]]
do
echo "Please input in 4 digits number !"
read -p "Set main port eg. 5001 : " secPort
cekPort=$(eval "lsof -Pi :${secPort} -sTCP:LISTEN -t")
done
until [[ -z "$cekPort" ]]
do
echo "Port ${secPort} is already in use !"
read -p "Set main port eg. 5001 : " secPort
cekPort=$(eval "lsof -Pi :${secPort} -sTCP:LISTEN -t")
done


# Cek third Port
read -p "Set main port eg. 5001 : " trdPort
cekPort=$(eval "lsof -Pi :${trdPort} -sTCP:LISTEN -t")
until [[ ${trdPort} =~ ^[0-9]{4}$ ]]
do
echo "Please input in 4 digits number !"
read -p "Set main port eg. 5001 : " trdPort
cekPort=$(eval "lsof -Pi :${trdPort} -sTCP:LISTEN -t")
done
until [[ -z "$cekPort" ]]
do
echo "Port ${trdPort} is already in use !"
read -p "Set main port eg. 5001 : " trdPort
cekPort=$(eval "lsof -Pi :${trdPort} -sTCP:LISTEN -t")
done


sudo ufw allow ${mainPort}
sudo ufw allow ${secPort}
sudo ufw allow ${trdPort}
mkdir ${cfgDir}/.ipfs${lastKey} &&
ipfsConf
screen -dmS ipfs${lastKey} -L -Logfile $cfgDir/ipfs${lastKey}.log bash -c "IPFS_PATH=${cfgDir}/.ipfs${lastKey} ipfs daemon --init;exec bash;" 
else
mainPort=5001
cekPort=$(eval "lsof -Pi :${mainPort} -sTCP:LISTEN -t")
until [[ -z "$cekPort" ]]
do
mainPort=$((${mainPort}+1))
cekPort=$(eval "lsof -Pi :${mainPort} -sTCP:LISTEN -t")
done

secPort=4001
cekPort=$(eval "lsof -Pi :${secPort} -sTCP:LISTEN -t")
until [[ -z "$cekPort" ]]
do
secPort=$((${secPort}+1))
cekPort=$(eval "lsof -Pi :${secPort} -sTCP:LISTEN -t")
done

trdPort=8080
cekPort=$(eval "lsof -Pi :${trdPort} -sTCP:LISTEN -t")
until [[ -z "$cekPort" ]]
do
trdPort=$((${trdPort}+1))
cekPort=$(eval "lsof -Pi :${trdPort} -sTCP:LISTEN -t")
done

sudo ufw allow ${mainPort}
sudo ufw allow ${secPort}
sudo ufw allow ${trdPort}
mkdir ${cfgDir}/.ipfs${lastKey} &&
ipfsConf
screen -dmS ipfs${lastKey} -L -Logfile ${cfgDir}/ipfs${lastKey}.log bash -c "IPFS_PATH=${cfgDir}/.ipfs${lastKey} ipfs daemon --init;exec bash;" 
fi
}


function startUp(){
cd;
myHeader;
if [ -d ~/ewm-das ]
then
   if [ -d $cfgDir ]
   then
     myHeader
     echo -e "Config directories found !\n"
     echo -e "1. Add Light Client\n"
     echo -e "2. Reinstall Light Client\n"
     echo -e "3. Uninstall Light Client\n"
     echo -e "Submit any key to exit\n"
     read -p "Config directories found ! do you want to add light-client ? : " dirFound
     until [[ "${dirFound}" =~ ^[0-3]+$ ]];
     do
     myHeader
     echo -e "Config directories found !\n"
     echo -e "1. Add Light Client\n"
     echo -e "2. Reinstall Light Client\n"
     echo -e "3. Uninstall Light Client\n"
     read -p "Config directories found ! do you want to add light-client ? : " dirFound
     done
     if [[ "${dirFound}"="1" ]];
     then
     . $cfgDir/config
     lastKey="$((${#privKey[@]}+1))"
     sed -r -i.bak "s/lastKey=([[:graph:]]+)/lastKey=${lastKey}/g" $cfgDir/config
     installer
     elif [[ "${dirFound}"="2" ]];
     then
     notInstalled
     installer
     elif [[ "${dirFound}"="3" ]];
     then
     rm -rf ewm*
     pkill -f "ipfs*"
     pkill -f "covalent*"
     exit 1
     else
     exit 1
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
     mkdir $cfgDir
     lastKey=1
     }

function installer(){
myHeader;
   command -v lsof >/dev/null 2>&1 || { echo >&2 "lsof is not found on this machine, Installing lsof ... "; sleep 5;sudo apt install lsof -y;} 
   command -v screen >/dev/null 2>&1 || { echo >&2 "Screen is not found on this machine, Installing screen ... "; sleep 5;sudo apt install screen -y;} 
   command -v git >/dev/null 2>&1 || { echo >&2 "Git is not found on this machine, Installing git ... "; sleep 5;sudo apt install git -y;}
   command -v wget >/dev/null 2>&1 || { echo >&2 "Wget is not found on this machine, Installing Wget ... "; sleep 5;sudo apt install wget -y;}
   command -v ufw >/dev/null 2>&1 || { echo >&2 "Ufw is not found on this machine, Installing ufw ... "; sleep 5;sudo apt install ufw -y;}
myHeader;  
entryPointPK;
myHeader;
read -p "Do you want to set client port ? (y/n)  : " ipfsQn

# Running ipfs daemon
entryPointIpfs &&
if [ -f ${cfgDir}/tgConf.sh ]
then
echo "Telegram is configured !"; sleep 2
else
entryPointTg;
tgInit
fi
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
