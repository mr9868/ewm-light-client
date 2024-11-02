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
function errInstruct(){
echo 
echo "====================== INSTRUCTIONS ========================"
echo
echo -e "
Instructions if there is an error : \n
1. Close ipfs screen that contain an error (Remember the screen name)
2. Go to config folder, or type this 'cd \$cfgDir'
3. Execute the ipfs daemon files, for example 'bash ipfs1' (ipfs1 is the screen name)
4. Holla ! monitor your bot if there is an error again !
"
}

# Entrypoint for telegram monitor question
function entryPointTg(){
read -p "Do you want to add telegram monitor ? (y/n)  : " tgQn
if [[ "${tgQn}" =~ ^([yY][eE][sS]|[yY])$ ]];
then
read -p "Please provide your bot API Key from @botFather : " tgApiQn
read -p "Please provide your telegram ID's from @getidsbot : " tgIdQn


if grep -wq "tgApiQn" ${cfgDir}/config; then    
sudo pkill -f "ewmLog"
sed -r -i "s/tgApiQn=.*/tgApiQn=${tgApiQn}/g" ${cfgDir}/config
sed -r -i "s/tgIdQn=.*/tgIdQn=${tgIdQn}/g" ${cfgDir}/config
else         
echo "tgApiQn=${tgApiQn}" >> ${cfgDir}/config
echo "tgIdQn=${tgIdQn}" >> ${cfgDir}/config
fi
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
gitVer=\$(git describe --abbrev=0)
gitCommit=\$(git log -1 | grep commit)
msgGit=\$(eval \" echo 'You are using git version = \${gitVer} with commit id \${gitCommit}'\")
curl -s -X POST https://api.telegram.org/bot\${API_TOKEN}/sendMessage -d chat_id=\${CHAT_ID} -d text=\"\${msgGit}\"

sleep 20;
for i in \$(seq 1 \${ipfsCount});
do  
MESSAGE=\$(cat \${cfgDir}/logs/ipfs\${i}.log | grep 'ready'); 
curl -s -X POST https://api.telegram.org/bot\${API_TOKEN}/sendMessage -d chat_id=\${CHAT_ID} -d text=\"\${MESSAGE}\"
done
unset i

for i in \$(seq 1 \${#privKey[@]});
do  
msgStart=\$(cat \${cfgDir}/logs/covalent\${i}.log | awk '{print tolower(\\\$0)}' | grep 'client' | grep -ow '\w*0x\w*')
accStart=\$(eval \"echo 'Covalent\${i} : \\\\`\${msgStart}\\\\`'\")
curl -s -X POST https://api.telegram.org/bot\${API_TOKEN}/sendMessage -d chat_id=\${CHAT_ID} -d text=\"\${accStart}\" -d parse_mode='MarkdownV2'
done
unset i
while sleep 1800;
do
start=\$(date -d \"-30 minutes\" +'%Y-%m-%d %H:%M:%S')

for i in \$(seq 1 \${ipfsCount});
do  
lastIpfsError=\$(eval \"awk -v s=\\\"\$start\\\" 's<\$0' \${cfgDir}/logs/ipfs\${i}.log | grep -E 'ERROR|FATAL' | tail -1\")
lastIpfsError=\$(cat \${lastIpfsError})
if \${lastIpfsError} ; then
ipfsMsg=\$(echo -e 'ipfs\${i} daemon : \n \${lastIpfsError} \n There is an error. Restart ipfs\${i} daemon for better performance')  
curl -s -X POST https://api.telegram.org/bot\${API_TOKEN}/sendMessage -d chat_id=\${CHAT_ID} -d text=\"\${ipfsMsg}\"
fi
done
unset i

for i in \$(seq 1 \${#privKey[@]});
do  
lastCovError=\$(eval \"awk -v s=\\\"\$start\\\" 's<\$0' \${cfgDir}/logs/covalent\${i}.log | grep -E 'ERROR|FATAL' | tail -1\")
lastCovError=\$(cat \${lastIpfsError})

if \${lastCovError} ; then
covMsg=\$(echo -e 'Covalent\${i} light-client : \n \${lastCovError} \n There is an error. Restart ipfs daemon that contain error inside for better performance')  
curl -s -X POST https://api.telegram.org/bot\${API_TOKEN}/sendMessage -d chat_id=\${CHAT_ID} -d text=\"\${covMsg}\"                
fi

msgCount=\$(cat \${cfgDir}/logs/covalent\${i}.log | grep -c 'verified')
accMsg=\$(echo ' Covalent\${i}: \${msgCount} verified samples')  
curl -s -X POST https://api.telegram.org/bot\${API_TOKEN}/sendMessage -d chat_id=\${CHAT_ID} -d text=\"\${accMsg}\"                
# Use the curl command to send the message       
done
unset i
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
errInstruct;
echo "Telegram Bot initialized"
echo "Check the logs 'screen -r ewmLogs'"
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
screen -dmS covalent${i} -L -Logfile ${cfgDir}/logs/covalent${i}.log bash -c \"sudo light-client --rpc-url wss://coordinator.das.test.covalentnetwork.org/v1/rpc --collect-url https://us-central1-covalent-network-team-sandbox.cloudfunctions.net/ewm-das-collector --ipfs-addr :${mainPort} --private-key ${varPkey} ;exec bash\"
}
covalent${i}
" >  ${cfgDir}/covalent${i}.sh
chmod 777 ${cfgDir}/covalent${i}.sh && bash ${cfgDir}/covalent${i}.sh
else
echo "
function covalent${i}(){
rm -rf ${cfgDir}/covalent${i}.log
screen -dmS covalent${i} -L -Logfile ${cfgDir}/logs/covalent${i}.log bash -c \"sudo light-client --rpc-url wss://coordinator.das.test.covalentnetwork.org/v1/rpc --collect-url https://us-central1-covalent-network-team-sandbox.cloudfunctions.net/ewm-das-collector --ipfs-addr :${mainPort} --private-key ${varPkey} ;exec bash\"
}
covalent${i}
" >  ${cfgDir}/covalent${i}.sh
chmod 777 ${cfgDir}/covalent${i}.sh && bash ${cfgDir}/covalent${i}.sh
fi
done
}

# Covalent log
function covalentLog(){

for i in $(seq ${lastKey} ${#privKey[@]});
do
echo "To view covalent${i} log execute 'screen -r covalent${i}'"
done
echo "To view ipfs${ipfsCount} daemon log execute 'screen -r ipfs${ipfsCount}'"
}

function tgInit(){
if [[ "${tgQn}" =~ ^([yY][eE][sS]|[yY])$ ]];
then
cd ${cfgDir};
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
screen -dmS ipfs${ipfsCount} -L -Logfile ${cfgDir}/logs/ipfs${ipfsCount}.log bash -c \"IPFS_PATH=${cfgDir}/.ipfs${ipfsCount} ipfs daemon --init;exec bash;\" 
}
ipfs${ipfsCount}
" > ${cfgDir}/ipfs${ipfsCount}.sh;
chmod 777 ${cfgDir}/ipfs${ipfsCount}.sh && bash ${cfgDir}/ipfs${ipfsCount}.sh
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
screen -dmS ipfs${ipfsCount} -L -Logfile ${cfgDir}/logs/ipfs${ipfsCount}.log bash -c \"IPFS_PATH=${cfgDir}/.ipfs${ipfsCount} ipfs daemon --init;exec bash\" 
}
ipfs${ipfsCount}
" > ${cfgDir}/ipfs${ipfsCount}.sh;
chmod 777 ${cfgDir}/ipfs${ipfsCount}.sh && bash ${cfgDir}/ipfs${ipfsCount}.sh
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
     echo -e "2. Configure monitor bot\n"
     echo -e "3. Reinstall Light Client\n"
     echo -e "4. Uninstall Light Client\n"
     echo -e "5. Exit setup\n"
     read -p "Choose your option : " dirFound
     until [[ "${dirFound}" =~ ^[0-5]+$ ]];
     do
     myHeader
     echo -e "Config directories found !\n"
     echo -e "1. Add Light Client\n"
     echo -e "2. Configure monitor bot\n"
     echo -e "3. Reinstall Light Client\n"
     echo -e "4. Uninstall Light Client\n"
     echo -e "5. Exit setup\n"
     echo
     echo -e "Please select 1-5 !\n"
     read -p "Choose your option : " dirFound
     done
     if [ ${dirFound} == "1" ];
     then
     . $cfgDir/config
     lastKey="$((${#privKey[@]}+1))"
     ipfsCount="$((${ipfsCount}+1))"
     sed -r -i "s/ipfsCount=.*/ipfsCount=${ipfsCount}/g" $cfgDir/config
     installer
     fi
     if [ ${dirFound} == "2" ];
     then
     entryPointTg;
     tgInit
     fi
     if [ ${dirFound} == "3" ];
     then
     notInstalled
     installer
     fi
     if [ ${dirFound} == "4" ];
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
     if [ ${dirFound} == "5" ];
     then
     :
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
     sudo pkill -f "ewmLog"
     checkGo &&
     checkIpfs 
# Install ewm-das
     git clone https://github.com/covalenthq/ewm-das  &&
     cd ewm-das &&
     mkdir $cfgDir
     mkdir $cfgDir/logs
     lastKey=1
     ipfsCount=1
     }

function installer(){
if [ ${dirFound} == "1" ];
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

if [ ${dirFound} == "1" ];
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
errInstruct;

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
