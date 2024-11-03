# WELCOME, don't forget to leave a star to my project :) mr9868


# Make sure there is nothing complicated
goLts="1.23.2" &&
ipfsLts="31" &&
cfgDir=~/ewm-das/.mr9868;
if grep -wq "cfgDir" ~/.bashrc; then
sed -r -i "s/cfgDir=.*/cfgDir=${cfgDir}/g" ~/.bashrc
else
echo "cfgDir=${cfgDir}" >> ~/.bashrc
source .bashrc
fi

if grep -wq "cfgDir" ${cfgDir}/config; then
echo "cfgDir=${cfgDir}" >> ${cfgDir}/config
else
sed -r -i "s/cfgDir=.*/cfgDir=${cfgDir}/g" ${cfgDir}/config
fi


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
echo "ipfsCount=${ipfsCount}" >> $cfgDir/config
set | grep ^privKey= >> ${cfgDir}/config
else
sed -r -i "s/privKey=.*/$(set | grep ^privKey= )/g" $cfgDir/config

fi
}

function tgQnCheck(){
read -p "Please provide your bot API Key from @botFather : " tgApiQn
until [ -n "${tgApiQn}" ];
do
myHeader
echo "Please input the API ! "
read -p "Please provide your bot API Key from @botFather : " tgApiQn
done
myHeader
echo "Please provide your bot API Key from @botFather : ${tgApiQn}"
read -p "Please provide your telegram ID's from @getidsbot : " tgIdQn
until [ -n "${tgIdQn}" ];
do
myHeader
echo "Please input chat id !"
echo "Please provide your bot API Key from @botFather : ${tgApiQn}"
read -p "Please provide your telegram ID's from @getidsbot : " tgIdQn
done
}

# Entrypoint for telegram monitor question
function entryPointTg(){
myHeader
read -p "Do you want to add telegram monitor ? (y/n)  : " tgQn
if [[ "${tgQn}" =~ ^([yY][eE][sS]|[yY])$ ]];
then   
tgQnCheck
API_TOKEN=${tgApiQn}
CHAT_ID=${tgIdQn}
myHeader
msgTg=$(echo -e "Authorized !\nPlease wait for up to 1 minute ... ")
tgTest=$(curl -s -X POST https://api.telegram.org/bot${API_TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d text="${msgTg}" | grep 'error_code')
tgTest=$(echo ${tgTest})
until [ -z "${tgTest}" ];
do
myHeader
echo -e "Unauthorized !\nPlease recheck your API and CHAT ID"
tgQnCheck
API_TOKEN=${tgApiQn}
CHAT_ID=${tgIdQn}
tgTest=$(curl -s -X POST https://api.telegram.org/bot${API_TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d text="${msgTg}" | grep 'error_code')
tgTest=$(echo ${tgTest})
done
echo -e ${msgTg}
if grep -wq "tgApiQn" ${cfgDir}/config; then    
sudo pkill -f "ewmLog"
sed -r -i "s/tgApiQn=.*/tgApiQn=${tgApiQn}/g" ${cfgDir}/config
sed -r -i "s/tgIdQn=.*/tgIdQn=${tgIdQn}/g" ${cfgDir}/config
tgConf;
else         
echo "tgApiQn=${tgApiQn}" >> ${cfgDir}/config
echo "tgIdQn=${tgIdQn}" >> ${cfgDir}/config
tgConf;
fi
else
echo "See yaa ..."
fi
}

function tgConf(){
echo "
cfgDir=${cfgDir}
. \${cfgDir}/config
# Send tg message
function tgMsg(){
# Set the API token and chat ID
API_TOKEN=\"\${tgApiQn}\"
CHAT_ID=\"\${tgIdQn}\"

msgStart=\$(eval \" echo -e 'Covalent Monitor Bot, Coded By Mr9868\nGithub: Https://www\\.github\\.com/mr9868'\")
curl -s -X POST https://api.telegram.org/bot\${API_TOKEN}/sendMessage -d chat_id=\${CHAT_ID} -d text=\"\${msgStart}\" -d parse_mode=\"MarkdownV2\"

gitVer=\$(git describe --abbrev=0)
gitCommit=\$(git log -1 | grep commit)
msgGit=\$(eval \" echo 'You are using git version = \${gitVer} with commit id \${gitCommit}'\")
curl -s -X POST https://api.telegram.org/bot\${API_TOKEN}/sendMessage -d chat_id=\${CHAT_ID} -d text=\"\${msgGit}\"

sleep 60;
for ipfsDaemon in \$(seq 1 \${ipfsCount});
do  
MESSAGE=\$(cat \${cfgDir}/logs/ipfs\${ipfsDaemon}.log | grep 'ready' | tail -1); 
MESSAGE=\$(eval \"echo 'ipfs\${ipfsDaemon} status : \${MESSAGE} ✅'\")
curl -s -X POST https://api.telegram.org/bot\${API_TOKEN}/sendMessage -d chat_id=\${CHAT_ID} -d text=\"\${MESSAGE}\"
done

for akun in \$(seq 1 \${#privKey[@]});
do  
msgStart=\$(cat \${cfgDir}/logs/covalent\${akun}.log | awk '{print tolower(\$0)}' | grep 'client' | grep -ow '\w*0x\w*')
accStart=\$(eval \" echo 'Address covalent\${akun} : \\\`\${msgStart}\\\`'\")
curl -s -X POST https://api.telegram.org/bot\${API_TOKEN}/sendMessage -d chat_id=\${CHAT_ID} -d text=\"\${accStart}\" -d parse_mode='MarkdownV2'
done
while sleep 1800;
do
start=\$(date -d \"-30 minutes\" +'%Y-%m-%d %H:%M:%S')

for ipfsError in \$(seq 1 \${ipfsCount});
do  
lastIpfsError=\$(awk -v s=\"\$start\" 's<\$0' \${cfgDir}/logs/ipfs\${ipfsError}.log | grep -E 'ERROR|FATAL' | tail -1)
if [ -n \"\${lastIpfsError}\" ] ; then
ipfsMsg=\$(eval \"echo 'There is an error on ipfs\"\${ipfsError}\" daemon, auto restarting your ipfs\"\${ipfsError}\"'\")  
curl -s -X POST https://api.telegram.org/bot\${API_TOKEN}/sendMessage -d chat_id=\${CHAT_ID} -d text=\"\${ipfsMsg}\" -d parse_mode='MarkdownV2' &&
sudo pkill -f 'ipfs'\${ipfsError}'' && sudo rm -rf \${cfgDir}/logs/ipfs\${ipfsError}.log && bash \${cfgDir}/ipfs\${ipfsError} &&
ipfsMsg2=\$(eval \"echo 'Auto restart complete on ipfs\"\${ipfsError}\" daemon ✅'\")  
curl -s -X POST https://api.telegram.org/bot\${API_TOKEN}/sendMessage -d chat_id=\${CHAT_ID} -d text=\"\${ipfsMsg2}\" -d parse_mode='MarkdownV2'
fi
done

for covError in \$(seq 1 \${#privKey[@]});
do  
lastCovError=\$(awk -v s=\"\$start\" 's<\$0' \${cfgDir}/logs/covalent\${covError}.log | grep -E 'ERROR|FATAL' | tail -1)
if [ -n \"\${lastCovError}\" ]; then
covMsg=\$(eval \"echo 'There is an error on covalent\"\${covError}\" node, auto restarting your covalent\"\${covError}\" node'\")  
curl -s -X POST https://api.telegram.org/bot\${API_TOKEN}/sendMessage -d chat_id=\${CHAT_ID} -d text=\"\${covMsg}\" -d parse_mode='MarkdownV2' &&
sed -i \"s/.*ERROR.*//g\" \${cfgDir}/logs/covalent\${covError}.log && sed -i \"s/.*FATAL.*//g\" \${cfgDir}/logs/covalent\${covError}.log &&
covMsg2=\$(eval \"echo 'Auto restart complete on covalent\"\${covError}\" node ✅'\")  
curl -s -X POST https://api.telegram.org/bot\${API_TOKEN}/sendMessage -d chat_id=\${CHAT_ID} -d text=\"\${covMsg2}\" -d parse_mode='MarkdownV2'
fi
done

for accCov in \$(seq 1 \${#privKey[@]});
do
msgCount=\$(cat \${cfgDir}/logs/covalent\${accCov}.log | grep -c 'verified')
accMsg=\$(eval \" echo ' Covalent\${accCov}: \${msgCount} verified samples' ✅\")  
curl -s -X POST https://api.telegram.org/bot\${API_TOKEN}/sendMessage -d chat_id=\${CHAT_ID} -d text=\"\${accMsg}\"                
# Use the curl command to send the message 
done
done
}
tgMsg;
" > ${cfgDir}/tgConf
echo "
cfgDir=${cfgDir}
. \${cfgDir}/config
function runTg(){
sudo pkill -f 'ewmLog'
screen -dmS ewmLog bash -c \"cd \${cfgDir}; chmod 777 \${cfgDir}/tgConf;bash \${cfgDir}/tgConf;exec bash;cd ${cfgDir}\"
}
runTg
" > ${cfgDir}/tgInit
chmod 777 ${cfgDir}/tgInit && bash ${cfgDir}/tgInit 
echo "Telegram Bot initialized"
echo "Check the logs 'screen -r ewmLog'"
}

function runAll(){
echo "
cfgDir=${cfgDir}
. \${cfgDir}/config
for i in \$(seq 1 \${ipfsCount});
do
sudo rm -rf \${cfgDir}/logs/ipfs*
bash \${cfgDir}/ipfs\${i}
echo 'Successfull to run  ipfs\${i} daemon ✅'
done

for i in \$(seq 1 \${#privKey[@]});
do
sudo rm -rf \${cfgDir}/logs/covalent*
bash \${cfgDir}/covalent\${i}
echo 'Successfull to run covalent\${i} node ✅'
done

if [ -f \${cfgDir}/tgInit -a -f \${cfgDir}/tgConf -a  -f \${cfgDir}/config ];
then
chmod 777 tgInit
bash tgInit
fi


" > ${cfgDir}/runAll
}

function stopAll(){
echo "
cfgDir=${cfgDir}
. \${cfgDir}/config
sudo rm -rf \${cfgDir}/logs/ipfs*
sudo rm -rf \${cfgDir}/logs/covalent*
sudo pkill -f 'ipfs*'
sudo pkill -f 'covalent*'
echo 'Successfull to stop all ipfs daemon ✅'
echo 'Successfull to stop covalent node ✅'
" > ${cfgDir}/runAll
}

# Run light-client node
function runLightClient(){
for i in $(seq ${lastKey} ${#privKey[@]});
do
varPkey=${privKey[$((${i}-1))]}
if [[ "${ipfsQn}" =~ ^([yY][eE][sS]|[yY])$ ]];
then
echo "
function covalent${i}(){
rm -rf ${cfgDir}/covalent${i}.log
screen -dmS covalent${i} -L -Logfile ${cfgDir}/logs/covalent${i}.log bash -c \"sudo light-client --rpc-url wss://coordinator.das.test.covalentnetwork.org/v1/rpc --collect-url https://us-central1-covalent-network-team-sandbox.cloudfunctions.net/ewm-das-collector --ipfs-addr :${mainPort} --private-key ${varPkey} ;exec bash;cd ${cfgDir}\"
}
covalent${i}
" >  ${cfgDir}/covalent${i}
chmod 777 ${cfgDir}/covalent${i} && bash ${cfgDir}/covalent${i}
else
echo "
function covalent${i}(){
rm -rf ${cfgDir}/covalent${i}.log
screen -dmS covalent${i} -L -Logfile ${cfgDir}/logs/covalent${i}.log bash -c \"sudo light-client --rpc-url wss://coordinator.das.test.covalentnetwork.org/v1/rpc --collect-url https://us-central1-covalent-network-team-sandbox.cloudfunctions.net/ewm-das-collector --ipfs-addr :${mainPort} --private-key ${varPkey} ;exec bash;cd ${cfgDir}\"
}
covalent${i}
" >  ${cfgDir}/covalent${i}
chmod 777 ${cfgDir}/covalent${i} && bash ${cfgDir}/covalent${i}
fi
done
}

# Covalent log
function covalentLog(){

for i in $(seq 1 ${#privKey[@]});
do
echo "To view covalent${i} log execute 'screen -r covalent${i}'"
done

for i in $(seq 1 ${ipfsCount});
do
echo "To view ipfs${i} log execute 'screen -r ipfs${i}'"
done
. ${cfgDir}/config
sed -r -i "s/ipfsCount=.*/ipfsCount=${ipfsCount}/g" ${cfgDir}/config
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
' > ${cfgDir}/.ipfs${ipfsCount}/config

echo '{"mounts":[{"mountpoint":"/blocks","path":"blocks","shardFunc":"/repo/flatfs/shard/v1/next-to-last/2","type":"flatfs"},{"mountpoint":"/","path":"datastore","type":"levelds"}],"type":"mount"}' > ${cfgDir}/.ipfs${ipfsCount}/datastore_spec
echo '16' > ${cfgDir}/.ipfs${ipfsCount}/version
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
read -p "Set second port eg. 4001 : " secPort
cekPort=$(eval "lsof -Pi :${secPort} -sTCP:LISTEN -t")
until [[ ${secPort} =~ ^[0-9]{4}$ ]]
do
echo "Please input in 4 digits number !"
read -p "Set second port eg. 4001 : " secPort
cekPort=$(eval "lsof -Pi :${secPort} -sTCP:LISTEN -t")
done
until [[ -z "$cekPort" ]]
do
echo "Port ${secPort} is already in use !"
read -p "Set second port eg. 4001 : " secPort
cekPort=$(eval "lsof -Pi :${secPort} -sTCP:LISTEN -t")
done


# Cek third Port
read -p "Set third port eg. 8080 : " trdPort
cekPort=$(eval "lsof -Pi :${trdPort} -sTCP:LISTEN -t")
until [[ ${trdPort} =~ ^[0-9]{4}$ ]]
do
echo "Please input in 4 digits number !"
read -p "Set third port eg. 8080 : " trdPort
cekPort=$(eval "lsof -Pi :${trdPort} -sTCP:LISTEN -t")
done
until [[ -z "$cekPort" ]]
do
echo "Port ${trdPort} is already in use !"
read -p "Set third port eg. 8080 : " trdPort
cekPort=$(eval "lsof -Pi :${trdPort} -sTCP:LISTEN -t")
done


sudo ufw allow ${mainPort}
sudo ufw allow ${secPort}
sudo ufw allow ${trdPort}
mkdir ${cfgDir}/.ipfs${ipfsCount} &&
ipfsConf
echo "
function ipfs${ipfsCount}(){
rm -rf ${cfgDir}/ipfs${ipfsCount}.log
screen -dmS ipfs${ipfsCount} -L -Logfile ${cfgDir}/logs/ipfs${ipfsCount}.log bash -c \"IPFS_PATH=${cfgDir}/.ipfs${ipfsCount} ipfs daemon --init;exec bash;cd ${cfgDir}\" 
}
ipfs${ipfsCount}
" > ${cfgDir}/ipfs${ipfsCount};
chmod 777 ${cfgDir}/ipfs${ipfsCount} && bash ${cfgDir}/ipfs${ipfsCount}
# screen -dmS ipfs${ipfsCount} -L -Logfile $cfgDir/ipfs${ipfsCount}.log bash -c "IPFS_PATH=${cfgDir}/.ipfs${ipfsCount} ipfs daemon --init;exec bash;" 
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
mkdir ${cfgDir}/.ipfs${ipfsCount} &&
ipfsConf
echo "
function ipfs${ipfsCount}(){
rm -rf ${cfgDir}/ipfs${ipfsCount}.log
screen -dmS ipfs${ipfsCount} -L -Logfile ${cfgDir}/logs/ipfs${ipfsCount}.log bash -c \"IPFS_PATH=${cfgDir}/.ipfs${ipfsCount} ipfs daemon --init;exec bash;cd ${cfgDir}\" 
}
ipfs${ipfsCount}
" > ${cfgDir}/ipfs${ipfsCount};
chmod 777 ${cfgDir}/ipfs${ipfsCount} && bash ${cfgDir}/ipfs${ipfsCount}
fi
}


function startUp(){
cd;
myHeader;
if [ -d ~/.mr9868 -a ! -d ${cfgDir} ] 
then
backup;
fi
if [ -d ~/ewm-das ]
then
   if [ -d ${cfgDir} -a -f ${cfgDir}/config ]
   then
   
     myHeader
     echo -e "Config directories found !\n"
     echo -e "1. Add Light Client\n"
     echo -e "2. Configure monitor bot\n"
     echo -e "3. Upgrade git version / Migration\n"
     echo -e "4. Reinstall Light Client\n"
     echo -e "5. Uninstall Light Client\n"
     echo -e "6. Exit setup\n"
     echo
     echo -e "Please select 1-6 !\n"
     read -p "Choose your option : " dirFound
     until [[ "${dirFound}" =~ ^[0-6]+$ ]];
     do
     myHeader
     echo -e "Config directories found !\n"
     echo -e "1. Add Light Client\n"
     echo -e "2. Configure monitor bot\n"
     echo -e "3. Upgrade git version / Migration\n"
     echo -e "4. Reinstall Light Client\n"
     echo -e "5. Uninstall Light Client\n"
     echo -e "6. Exit setup\n"
     echo
     echo -e "Please select 1-6 !\n"
     read -p "Choose your option : " dirFound
     done
     if [[ "${dirFound}" == "1" ]];
     then
     . ${cfgDir}/config
     sumIpfs=$(cd ${cfgDir}  && ls -dq *ipfs* | wc -l)
     ipfsCount="$((${sumIpfs}+1))"
     lastKey="$((${#privKey[@]}+1))"
     installer
     fi
     if [[ "${dirFound}" == "2" ]];
     then
     entryPointTg;
     fi
     if [[ "${dirFound}" == "3" ]];
     then
     backup
     fi
     if [[ "${dirFound}" == "4" ]];
     then
     notInstalled
     installer
     fi
     if [[ "${dirFound}" == "5" ]];
     then
     sudo rm -rf ~/ewm-das
     sudo rm -rf ~/.ipfs*
     sudo rm -rf /usr/local/bin/ipfs
     sudo pkill -f "covalent*"
     sudo pkill -f "ipfs*"
     sudo pkill -f "ewmLog"
     sed -r -i "s/cfgDir=.*/ /g" ~/.bashrc
     :
     fi
     if [[ "${dirFound}" == "6" ]];
     then
     :
     echo "good bye..."
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

function backup(){
myHeader
     read -p "For migration, please copy your backup first (y/n) : " backupQn
     if [[ "${backupQn}" =~ ^([yY][eE][sS]|[yY])$ ]];
     then
     sudo cp -r ${cfgDir} ~/.mr9868
     sudo rm -rf ~/ewm-das
     sudo pkill -f "covalent*"
     sudo pkill -f "ipfs*"
     sudo pkill -f "ewmLog"
     checkGo &&
     checkIpfs 
     cd; git clone https://github.com/covalenthq/ewm-das  &&
     cd ewm-das &&
     myHeader;
   command -v lsof >/dev/null 2>&1 || { echo >&2 "lsof is not found on this machine, Installing lsof ... "; sleep 2;sudo apt install lsof -y;} 
   command -v sed >/dev/null 2>&1 || { echo >&2 "sed is not found on this machine, Installing sed ... "; sleep 2;sudo apt install sed -y;} 
   command -v screen >/dev/null 2>&1 || { echo >&2 "Screen is not found on this machine, Installing screen ... "; sleep 2;sudo apt install screen -y;} 
   command -v git >/dev/null 2>&1 || { echo >&2 "Git is not found on this machine, Installing git ... "; sleep 2;sudo apt install git -y;}
   command -v wget >/dev/null 2>&1 || { echo >&2 "Wget is not found on this machine, Installing Wget ... "; sleep 2;sudo apt install wget -y;}
   command -v ufw >/dev/null 2>&1 || { echo >&2 "Ufw is not found on this machine, Installing ufw ... "; sleep 2;sudo apt install ufw -y;}
   # Installing required Go packages
     go install honnef.co/go/tools/cmd/staticcheck@latest && 
     make deps &&
     make  && 
     sudo bash install-trusted-setup &&
     # Installing covalent light-client node
     sudo cp -r bin/light-client /usr/local/bin/light-client 
     cp -r ~/.mr9868 ~/ewm-das
     cd ${cfgDir}
     myHeader
     chmod 777  ${cfgDir}/runAll
     bash ${cfgDir}/runAll
     covalentLog
     
     echo
     echo "=================== INSTALLATION SUCCESS ==================="
     echo
     git log -1
     git version
     go version
     ipfs version
     else
     :
     echo "Good Bye ..."
     fi
}

function notInstalled(){
     sudo rm -rf ~/ewm-das
     sudo rm -rf ~/.ipfs*
     sudo pkill -f "covalent*"
     sudo pkill -f "ipfs*"
     sudo pkill -f "ewmLog"
     checkGo &&
     checkIpfs 
# Install ewm-das
     git clone https://github.com/covalenthq/ewm-das  &&
     cd ewm-das &&
     # Installing required Go packages
     go install honnef.co/go/tools/cmd/staticcheck@latest && 
     make deps &&
     make  && 
     sudo bash install-trusted-setup &&
     mkdir $cfgDir
     mkdir $cfgDir/logs
     lastKey=1
     ipfsCount=1
     }

function installer(){
if [[ "${dirFound}" == "1" ]];
     then
     echo "Next ..."
     sleep 2;
     else
myHeader;
   command -v lsof >/dev/null 2>&1 || { echo >&2 "lsof is not found on this machine, Installing lsof ... "; sleep 2;sudo apt install lsof -y;} 
   command -v sed >/dev/null 2>&1 || { echo >&2 "sed is not found on this machine, Installing sed ... "; sleep 2;sudo apt install sed -y;} 
   command -v screen >/dev/null 2>&1 || { echo >&2 "Screen is not found on this machine, Installing screen ... "; sleep 2;sudo apt install screen -y;} 
   command -v git >/dev/null 2>&1 || { echo >&2 "Git is not found on this machine, Installing git ... "; sleep 2;sudo apt install git -y;}
   command -v wget >/dev/null 2>&1 || { echo >&2 "Wget is not found on this machine, Installing Wget ... "; sleep 2;sudo apt install wget -y;}
   command -v ufw >/dev/null 2>&1 || { echo >&2 "Ufw is not found on this machine, Installing ufw ... "; sleep 2;sudo apt install ufw -y;}
     fi
myHeader;  
entryPointPK;
myHeader;
read -p "Do you want to set client port ? (y/n)  : " ipfsQn

# Running ipfs daemon
entryPointIpfs &&
if [ -f ${cfgDir}/tgConf ]
then
chmod 777 ${cfgDir}/tgInit && bash ${cfgDir}/tgInit 
echo "Telegram bot is restarted !"; sleep 2
else
entryPointTg;
fi
myHeader;
echo
echo "==================== INSTALLATION START ===================="
echo

     sudo cp -r ~/ewm-das/bin /usr/local/bin
     echo "success"
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
runAll
unset $loop;
}

startUp
