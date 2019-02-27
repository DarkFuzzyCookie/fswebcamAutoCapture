#!/bin/bash

echo "fswebcam_auto_capture initiated"

config_capture_delay=''
config_capture_on_startup=false
config_capture_directory=''
config_capture_name_format=''
config_capture_resolution=''

flag_good_config=1

readonly DIVIDER="---------------------------"
readonly CAPTURE_DELAY_REGEX='^[0-9]+[smhd]$'

function validateCaptureFolder(){

	echo "Checking Directory $1"

	if ! [ -d $1 ] ; then
		mkdir $1
	fi

	config_capture_directory=$1
}

function evaluateNameFormat(){

	if [[ $config_capture_name_format == *"&dt"* ]] ; then
		echo '&dt'
	elif [[ $config_capture_name_format == *"&t"* ]] ; then
		echo '&t'
	elif [[ $config_capture_name_format == *"&i"* ]] || [[ $config_capture_name_format == *"&"* ]] ; then
		echo '&i'
	else
		echo 'o'
	fi
}

function makeStartupFile(){
	echo "#! /bin/sh" > autostart_fswebcam.sh
	echo " " >> autostart_fswebcam.sh
	echo "sh /location/of/script/fswebcam_auto_capture.sh" >> autostart_fswebcam.sh
}

function makeConfigurationFile(){
	echo "capture_delay=3h" > fswebcam_auto_capture.ini 
	echo "capture_on_startup=false" >> fswebcam_auto_capture.ini 
	echo "capture_directory=./capture/" >> fswebcam_auto_capture.ini
	echo "capture_name_format=image_&i" >> fswebcam_auto_capture.ini
	echo "capture_resolution=1280x720" >> fswebcam_auto_capture.ini

	echo " " >> fswebcam_auto_capture.ini
	echo "*********capture_delay*********" >> fswebcam_auto_capture.ini
	echo "coresponds to the delay in time between image captures" >> fswebcam_auto_capture.ini
	echo "can be any numeric number followed by:" >> fswebcam_auto_capture.ini
	echo "'d' for days, 'h' for hours, 'm' for minutes, 's' for seconds or no suffix for default seconds" >> fswebcam_auto_capture.ini
	echo "examples: 3h , 5d, 2, 10m, 5s" >> fswebcam_auto_capture.ini
	echo " " >> fswebcam_auto_capture.ini
	echo "*********capture_on_startup*********" >> fswebcam_auto_capture.ini
	echo "indicates whether to take a screenshot on execution or after the first timer iteration" >> fswebcam_auto_capture.ini
	echo "can be either true or false" >> fswebcam_auto_capture.ini
	echo "examples: true , false" >> fswebcam_auto_capture.ini
	echo " " >> fswebcam_auto_capture.ini
	echo "*********capture_directory*********" >> fswebcam_auto_capture.ini
	echo "directory where the capture images will be saved to" >> fswebcam_auto_capture.ini
	echo "default directory is cwd/capture/, if directory doesn't exist it will be created" >> fswebcam_auto_capture.ini
	echo "can be a valid directory path ending in '/'" >> fswebcam_auto_capture.ini
	echo "examples: ./capture/ , c:/Users/FishBoi/Akon/TommiesRide/ , ~/Documents/ImageCapture/" >> fswebcam_auto_capture.ini
	echo " " >> fswebcam_auto_capture.ini
	echo "*********capture_name_format*********" >> fswebcam_auto_capture.ini
	echo "name of the images that will be saved by the capture" >> fswebcam_auto_capture.ini
	echo "can put a single iteration of either '&i', '&t', or '&dt' to create unique names per image capture" >> fswebcam_auto_capture.ini
	echo "'&i' for images taken, '&t' for time as H:M:S and '&dt' for datetime as Y-M-D H:M:S " >> fswebcam_auto_capture.ini
	echo "if no unique identifier exists then the image will be overriden every capture" >> fswebcam_auto_capture.ini
	echo "examples: image_&dt , coolimagename , image_number_&i, taken_at_&t, &dt" >> fswebcam_auto_capture.ini
	echo " " >> fswebcam_auto_capture.ini
	echo "*********capture_resolution*********" >> fswebcam_auto_capture.ini
	echo "resolution of the images that will be saved by the capture" >> fswebcam_auto_capture.ini
	echo "must be valid screen resoultion sizes in the form LengthxWidth" >> fswebcam_auto_capture.ini
	echo "examples: 640x480 , 1280x720 , 1920x1080" >> fswebcam_auto_capture.ini
	echo " " >> fswebcam_auto_capture.ini
	echo "*********READ_ME*********" >> fswebcam_auto_capture.ini
	echo "To create the 'autostart_fswebcam.sh' and 'fswebcam_auto_capture.ini' files, run the shell script." >> fswebcam_auto_capture.ini
	echo "To make the script executable and run on startup do the following:" >> fswebcam_auto_capture.ini
	echo "Edit 'autostart_fswebcam.sh' and change the directory to the download directory of the fswebcam_auto_capture.sh" >> fswebcam_auto_capture.ini
	echo "Move 'autostart_fswebcam.sh' script into /etc/init.d/" >> fswebcam_auto_capture.ini
	echo "Make auto-run script executable: sudo chmod 755 /etc/init.d/autostart_fswebcam.sh" >> fswebcam_auto_capture.ini
	echo "Make capture script executable: sudo chmod 755 /location/of/script/fswebcam_auto_capture.sh" >> fswebcam_auto_capture.ini
	echo "Register script to be run at start-up: sudo update-rc.d autostart_fswebcam.sh defaults" >> fswebcam_auto_capture.ini
	echo "If you ever want to remove the script from start-up, run the following command: sudo update-rc.d -f  autostart_fswebcam.sh remove" >> fswebcam_auto_capture.ini
	echo "" >> fswebcam_auto_capture.ini

	makeStartupFile
}

function readConfigurationFile(){
	
	x=1
	while read p
	do
		if [ $x -eq 1 ]
		then
			pattern="capture_delay="
			config_capture_delay="${p/$pattern/}"
			
			if ! [[ $config_capture_delay =~ $CAPTURE_DELAY_REGEX ]] ; then
				flag_good_config=0
			fi
		elif [ $x -eq 2 ] ; then
			pattern="capture_on_startup="
			config_capture_on_startup=${p/$pattern/}
		elif [ $x -eq 3 ] ; then
			pattern="capture_directory="
			validateCaptureFolder "${p/$pattern/}"
		elif [ $x -eq 4 ] ; then
			pattern="capture_name_format="
			config_capture_name_format=${p/$pattern/}
		elif [ $x -eq 5 ] ; then
			pattern="capture_resolution="
			config_capture_resolution=${p/$pattern/}
			# So we don't process the readme file
			break
		fi

		x=$(($x+1))
	done <fswebcam_auto_capture.ini

	return "$flag_good_config"
}

function captureWebcamImage(){
	name_format=$(evaluateNameFormat)

	if [[ $name_format == *"&dt"* ]] ; then
		file_extension=`date '+%Y-%m-%d %H:%M:%S'`
		file_name="${config_capture_name_format/\&\d\t/$file_extension}"
	elif [[ $name_format == *"&t"* ]] ; then
		file_extension=`date '+%H:%M:%S'`
		file_name="${config_capture_name_format/\&\t/$file_extension}"
	elif [[ $name_format == *"&i"* ]] ; then
		file_extension=($increment_counter)
		file_name="${config_capture_name_format/\&\i/$file_extension}"
	elif [[ $name_format == *"o"* ]] ; then
		file_name="$config_capture_name_format"
	fi
		
	file_name="$config_capture_directory$file_name"
	fswebcam -r "$config_capture_resolution" "$file_name"
	echo "$file_name"
}

function startCaptureWebcamImage(){

	increment_counter=1
	if [ "$config_capture_on_startup" = "true" ] ; then
		captureWebcamImage
	fi

	while [ 1 ]
	do
		echo `captureWebcamImage`		 
		let "increment_counter+=1"

		sleep "$config_capture_delay"
	done
}

function launchConfigurationSetup(){

	# check if configuration file exists
	if ! [ -f ./fswebcam_auto_capture.ini ] ; then
		echo "No configuration file found!"
		makeConfigurationFile
	fi
	readConfigurationFile
}

function main(){
	
	launchConfigurationSetup
	startCaptureWebcamImage
}

main
