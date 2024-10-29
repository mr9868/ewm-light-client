if [ -f ~/ewm-das ]
then
   read -p "ewm-das directories found ! do you want to add light-client ? (y/n) : " dirFound
   if [[ "$dirFound" =~ ^([yY][eE][sS]|[yY])$ ]];
   then
   start=$(date -d "-30 minutes" +'%Y-%m-%d %H:%M:%S')
   awk -v s="$start" 's<$0' covalent1.log
   fi
fi
