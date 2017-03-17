#!/bin/env bash
# version: 1.0
# describle:
#
#

#白山云token
token="xxxxx"

CURE_DATE=$(date "+%F")
THREE_DATE=$(date -d '-2 day' "+%F")
ONE_DATE=$(date -d '-1 day' "+%F")

CURE_HOUR=$(date "+%F %H:59:59")
THREE_HOUR=$(date -d '-3 hour' "+%F %H:00:00")

#菜单
function menu(){
cat <<EOF
------白山云日志分析---------
    1:[下载最近3天日志]
    2:[下载最近1天日志]
    3:[下载最近3个小时日志]
    4:[自定义下载时间]
    5:[退出]
-----------------------------
EOF
	read  -p "请选择:" input
	case ${input} in
	 1)
         	read -t 10 -p "请输入域名:"   domain
		[ ! -n "$domain" ] && echo "输入错误" && continue
		downlog  $domain $THREE_DATE $CURE_DATE
	 ;;
	 2)
         	read -t 10 -p "请输入域名:"   domain
		[ ! -n "$domain" ] && echo "输入错误" && continue
		downlog  $domain $CURE_DATE $CURE_DATE
	 ;;
	 3)
         	read -t 10 -p "请输入域名:"   domain
		[ ! -n "$domain" ] && echo "输入错误" && continue
		downlog  $domain  "$THREE_HOUR" "$CURE_HOUR"
		#downlog  "www.acfun.tv" $THREE_DATE $CURE_DATE
	 ;;
	 4)
         	read -t 10 -p "请输入域名:"   domain
         	read -t 10 -p "开始时间（2017-2-22 01:00:00|2017-2-22）:"   start
         	read -t 10 -p "结束时间（2017-2-23 01:59:59|2017-2-23）:"   end1
		[ ! -n "$domain" ] && [ ! -n "$start" ] && [ ! -n "$end1" ] && echo "输入错误" && continue
		downlog  $domain "$start" "$end1"
		#downlog  "www.acfun.tv" $THREE_DATE $CURE_DATE
	 ;;
	 5)
	 exit 0
	 ;;
	 *)
	 printf "请选择{1|2|3|4|5}\n"
	esac

}

#下载日志
function downlog(){
	local DOMAIN=$1
	local START=$2
	local END=$3
	if [ -d $DOMAIN ] ;then
		mv $DOMAIN ${DOMAIN}.bak
		mkdir -p $DOMAIN
	else
		mkdir -p $DOMAIN
	fi
        cd $DOMAIN
        wget  -O "info"  "https://api.qingcdn.com/v1/domain/log/logs?token=${token}&domain=${DOMAIN}&start_time=${START}&end_time=${END}"           
        #wget  -O "info"  "https://api.qingcdn.com/v1/domain/log/logs?token=${token}&domain=${DOMAIN}&start_time=\"${START}\"&end_time=\"${END}\""           
        sed -i  's/{//g' info
        sed -i  's/}//g' info
        sed -i  's/,/\n/g' info
        #############################################
	THREAD_NUM=10
	#定义描述符为9的管道
	mkfifo tmp
	exec 9<>tmp	
	for ((i=0;i<$THREAD_NUM;i++))
	do
	    echo "" 
	done >&9
        #############################################
        
	while read line
	do
		read -u9
		{
			TIME=$( echo $line | awk -F '"' '{print $2}' | awk '{print $1"_"$2}' )
			URL=$(echo $line | awk -F '"' '{print $4}')
			#echo  "$TIME,$URL"
			wget "$URL"  -O ${DOMAIN}_${TIME}.gz
	 	        
			echo "" >&9
		}&
	done<info
	wait
        exec 9>&-
        rm -rf tmp
	#####################
	for file in $(ls *.gz)
	do
		ref $file
	done
        
}

function ref(){
	log=$1
	echo "----IP top-20----" >> result
	zcat $log | awk  '{a[$1]+=1} END{for (i in a) printf("%5d %10s\n",a[i],i)}'  | sort -nr | head -20 >> result
	echo "---Head Code total---" >> result
	zcat $log | awk  '{a[$9]+=1} END{for (i in a) printf("%5d %10s\n",a[i],i)}'  | sort -nr | head -20 >> result
	echo "---URI top-20----" >> result
	zcat $log | awk   '{print $7}' | awk -F '/' '{a[$4]+=1} END{for (i in a) printf("%5d %10s\n",a[i],i)}'  | sort -nr | head -20 >> result
}


while true
do
	clear
	menu
done
