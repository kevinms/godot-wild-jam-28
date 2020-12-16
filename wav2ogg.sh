#!/bin/bash

for file in `ls -1 *.wav`; do
	echo $file
	ffmpeg -i $file -acodec libvorbis ${file%.*}.ogg
done
