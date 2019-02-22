# fswebcamAutoCapture

Automatically captures the screen at specified intervals using fswebcam, and saves to specified directory and name.

*********capture_delay*********
coresponds to the delay in time between image captures
can be any numeric number followed by:
'd' for days, 'h' for hours, 'm' for minutes, 's' for seconds or no suffix for default seconds
examples: 3h , 5d, 2, 10m, 5s
 
*********capture_on_startup*********
indicates whether to take a screenshot on execution or after the first timer iteration
can be either true or false
examples: true , false
 
*********capture_directory*********
directory where the capture images will be saved to
default directory is cwd/capture/, if directory doesn't exist it will be created
can be a valid directory path ending in '/'
examples: ./capture/ , c:/Users/FishBoi/Akon/SexCam/ , ~/Documents/ImageCapture/
 
*********capture_name_format*********
name of the images that will be saved by the capture
can put a single iteration of either '&i', '&t', or '&dt' to create unique names per image capture
'&i' for images taken, '&t' for time as H:M:S and '&dt' for datetime as Y-M-D H:M:S 
if no unique identifier exists then the image will be overriden every capture
examples:\n image_&dt , coolimagename , image_number_&i, taken_at_&t, &dt
 
*********READ_ME*********
To make the script executable and run on startup do the following:
Edit 'autostart_fswebcam.sh' and change the directory to the download directory of the script
Move 'autostart_fswebcam.sh' script into /etc/init.d/
Make auto-run script executable: sudo chmod 755 /etc/init.d/autostart_fswebcam.sh
Make capture script executable: sudo chmod 755 /location/of/script/fswebcam_auto_capture.sh
Register script to be run at start-up: sudo update-rc.d autostart_fswebcam.sh defaults
If you ever want to remove the script from start-up, run the following command: sudo update-rc.d -f  autostart_fswebcam.sh remove
