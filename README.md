# Covalent light-client installer 
WELCOME, and don't forget to leave a star to my project :) 

Update feature :
1. Better notification report on telegram BOT
2. Multi port for ipfs and light-client
3. Backup and Migrate, so if there is an update you can upgrade without input anything again
4. Auto ipfs setting with dht acceleration
5. Auto restart the ipfs service if there is an error on it

We will update more feature soon ! so stay tune !

## Why you must install from the source ?
It's so efficient, and easy if you facing any error from the ipfs daemon, because the process is running separately, you can just restart it without restarting the main node. And you can run multiple client in ONE server 🤫
## EWM light-client setup auto installer
```
sudo rm -rf ewm_install.sh && wget https://github.com/mr9868/ewm-light-client/blob/main/ewm_install.sh && chmod 777 ewm_install.sh && bash ewm_install.sh && sudo rm ewm_install.sh
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

To add light-client, just rerun the ewm_install.sh

## The script will checking for verified samples every 30 minutes

### How to setting up telegram bot and get your bot API KEY
1. Go to [https://t.me/botfather]
2. Start the bot
3. type */newbot*
4. Setting up your bot names eg: Covalent Monitor Bot
5. Setting up your bot username eg: MyCovalentMonitor_Bot

*Warning: Username is unique, username cannot be the same with other telegram users*

7. Write up your HTTP API
8. Start your bot

### Here is the example :
[![2BcmmUF.md.jpg](https://iili.io/2BcmmUF.md.jpg)](https://freeimage.host/i/2BcmmUF)

### How to get your chat ID
1. Go to [https://t.me/getidsbot] 
2. Start the bot
3. Click and copy your chat ID

### Here is the example
[![2Bcsn1a.md.jpg](https://iili.io/2Bcsn1a.md.jpg)](https://freeimage.host/i/2Bcsn1a)


## Remove light-client
Warning ! Do this below just for remove your node only !

This will be permanently delete all data from your light-client!

```
wget https://raw.githubusercontent.com/mr9868/ewm-light-client/refs/heads/main/remove.sh && chmod 777 remove.sh && ./remove.sh && rm remove.sh
```
