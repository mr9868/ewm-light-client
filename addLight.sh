
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
read -p "Input your ipfs peer Id : " ipfsPeerId
read -p "Input your ipfs private key : " ipfsPrivKey
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


# if have installed directory :
# check with prompt -> 
start=$(date -d "-30 minutes" +'%Y-%m-%d %H:%M:%S')
   awk -v s="$start" 's<$0' covalent1.log
if [ -f ~/ewm-das ]
then
   read -p "ewm-das directories found ! do you want to add light-client ? (y/n) : " dirFound
   if [[ "$dirFound" =~ ^([yY][eE][sS]|[yY])$ ]];
   then
   
   fi
fi
