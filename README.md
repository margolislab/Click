# Click v2.0
Simple MATLAB script to automate all components of Clack Whisker Tracker

Uses version 1.1.0d of Whisk (https://openwiki.janelia.org/wiki/display/MyersLab/Whisker+Tracking+Downloads) and Matlab 2013 
*(The "LoadMeasurements" matlab function included with Whisk only seems to work in matlab 2013 and perhaps older.)

WhiskerTracking should be installed on the Desktop

The user can select any directory and "Click" will batch process all tif files within that directory and all it's subdirectories. Movies within the datadir folder are first processed using the parallel batch trace processor provided with the Whisker Tracker.
Then all data files are analyzed, matrix files created for each movie with individual and average whisker figures which are then output to the source datadir folder. 

If there exists a gap in the data from the whisker tracker being unable to identify whiskers, figures will be created indicating an error per the respective movie. Also included is a function called "redo" which you can run after filling in the gaps in data via the Whisker Tracker GUI to remake the figures and data with the updated whisker information.

Also included is the "rdir" function written by Thomas Vanaret and Gus Brown, which allows click and redo to process all appropriate files in all subdirectories within the starting directory

