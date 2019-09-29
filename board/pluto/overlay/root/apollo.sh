mkfifo /root/rtmphacktvpipe
mkfifo /root/hacktvpipe



while :
do
#killall -9 ffmpeg
killall -9 hacktv
killall -9 iio_writedev
rm infortmp78
FREQ=""
VIDEORATE=""

 (ffmpeg -analyzeduration 4000000 -f flv -listen 1 -timeout -1 -rtmp_buffer 500 -i rtmp://0.0.0.0:7878/ -ss 4 -codec copy -f mpegts -metadata service_provider="BIGTS" -metadata service_name=F5OEO -streamid 0:256 -y /root/rtmphacktvpipe 2>infortmp78 ) &
while [ "$VIDEORATE" == "" ]
do
 
 sleep 1

 VIDEORATE=$(grep -o " Video:.*" infortmp78 | cut -f4 -d, | cut -f1 -d'k') 
 echo Wait for RTMP connexion
done


FREQ=$(grep -o "match up:.*" infortmp78 | cut -f2 -d,)
VIDEORES=$(grep -o "Stream #0:1:.*" infortmp78 | cut -f3 -d,) 


MODE=$(grep -o "match up:.*" infortmp78 | cut -f3 -d,)
CONSTEL=$(grep -o "match up:.*" infortmp78 | cut -f4 -d,)
SR=$(grep -o "match up:.*" infortmp78 | cut -f5 -d,)
FEC=$(grep -o "match up:.*" infortmp78 | cut -f6 -d,)

echo FREQ $FREQ 


echo 0 > /sys/bus/iio/devices/iio:device1/out_voltage_filter_fir_en
echo 2250000 > /sys/bus/iio/devices/iio:device1/out_voltage_sampling_frequency
echo $FREQ"000000" > /sys/bus/iio/devices/iio:device1/out_altvoltage1_TX_LO_frequency
ffmpeg -analyzeduration 4000000 -f mpegts -i /root/rtmphacktvpipe -ss 4 -codec copy -f mpegts -y /root/hacktvpipe \
| /root/hacktv -m apollo-fsc-fm -o - -t int16 -s 2250000 ffmpeg:/root/hacktvpipe | iio_writedev -b 100000 cf-ad9361-dds-core-lpc


echo endstreaming
done


