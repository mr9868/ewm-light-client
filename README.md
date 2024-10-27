# Covalent light-client installer 
WELCOME, and don't forget to leave a star to my project :) 
## Why you must install from the source ?
It's so efficient, and easy if you facing any error from the ipfs daemon, because the process is running separately, you can just restart it without restarting the main node. And you can run multiple client in ONE server 🤫
## EWM light-client setup auto installer
```
rm -rf ewm_install.sh && wget https://raw.githubusercontent.com/mr9868/ewm-light-client/refs/heads/main/ewm_install.sh && chmod 777 ewm_install.sh && ./ewm_install.sh && rm ewm_install.sh
```
To check the main node logs :
```
screen -r covalent
```
To check the ipfs daemon logs :
```
screen -r ipfs
```

if you facing any error on the ipfs daemon you can just :
``` 
screen -r ipfs
```
then ctrl + c to stop,
then restart again :
```
ipfs daemon --init
```
then close again the screen by pressing ctrl + a +d


## Remove light-client
Warning ! Do this below just for remove your node only !

This will be permanently delete all data from your light-client!

```
wget https://raw.githubusercontent.com/mr9868/ewm-light-client/refs/heads/main/remove.sh && chmod 777 remove.sh && ./remove.sh && rm remove.sh
```
