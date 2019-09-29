#!/bin/sh
mkfifo /root/bigtspipe
mkfifo /root/tspipe



while :
do
#killall ffmpeg
rm infortmp
FREQ=""
VIDEORATE=""

 (ffmpeg -analyzeduration 4000000 -f flv -listen 1 -timeout -1 -rtmp_buffer 500 -i rtmp://0.0.0.0:7272/ -ss 4 -codec copy -f mpegts -metadata service_provider="BIGTS" -metadata service_name=F5OEO -streamid 0:256 -y /root/bigtspipe 2>infortmp ) &
while [ "$VIDEORATE" == "" ]
do
 
 sleep 1

 VIDEORATE=$(grep -o " Video:.*" infortmp | cut -f4 -d, | cut -f1 -d'k') 
 echo Wait for RTMP connexion
done


FREQ=$(grep -o "match up:.*" infortmp | cut -f2 -d,)
VIDEORES=$(grep -o "Stream #0:1:.*" infortmp | cut -f3 -d,) 

echo $VIDEORATE $VIDEORES 



MODE=$(grep -o "match up:.*" infortmp | cut -f3 -d,)
CONSTEL=$(grep -o "match up:.*" infortmp | cut -f4 -d,)
SR=$(grep -o "match up:.*" infortmp | cut -f5 -d,)
FEC=$(grep -o "match up:.*" infortmp | cut -f6 -d,)

echo FREQ $FREQ MODE $MODE CONSTEL $CONSTEL SR $SR FEC $FEC

CALL=$(grep -o "Unexpected stream.*" infortmp | cut -f2 -d,)
echo CALL $CALL
TSBITRATE=$(/root/pluto_dvb -m $MODE -c $CONSTEL -s $SR"000" -f $FEC -d)
echo TsBitrate $TSBITRATE   	

VIDEOMAX=$(echo "($TSBITRATE/1000)*80/100" | bc)

if [[ "$VIDEORATE" -ge "$VIDEOMAX" ]] ; then
MESSAGE="V!$VIDEOMAX kb"
else
MESSAGE="V$VIDEORATE kb"
fi


ffmpeg -analyzeduration 4000000 -f mpegts -i /root/bigtspipe -ss 4 -codec copy -muxrate $TSBITRATE -f mpegts -metadata service_provider="$MESSAGE" -metadata service_name=$CALL -streamid 0:256 -y /root/tspipe | /root/pluto_dvb -i /root/tspipe -m $MODE -c $CONSTEL -s $SR"000" -f $FEC -t $FREQ"e6" 
echo endstreaming
done
done
