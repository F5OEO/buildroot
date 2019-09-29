ffmpeg -analyzeduration 4000000 -f flv -listen 1 -timeout -1 -rtmp_buffer 500 
-i rtmp://0.0.0.0:7878/ -ss 4 -codec copy -f mpegts - | ./hacktv -m apollo-fsc-f
m -o - -t int16 -s 2250000 ffmpeg:/dev/stdin  

