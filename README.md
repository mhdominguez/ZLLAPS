# ZLAPS
ZEN (Zeiss) Live Lightsheet Adaptive Positioning Scripts

## Requirements
Requires Zeiss ZEN workstation on MS Windows x64, with multiview acquisition (i.e. Zeiss Lightsheet Z.1).  This application does NOT require administrator privileges to install or run.

## Install
#### 1. AutoIT3
- download zipped AutoIT3 ready-to-run package (https://www.autoitscript.com/cgi-bin/getfile.pl?autoit3/autoit-v3.zip)
- unzip above package to user's Desktop folder, and rename `install` folder to `AutoIT3.app`

#### 2. ImageJ
- download zipped ImageJ 1 (i.e. v1.53, NOT Fiji) ready-to-run package (https://wsr.imagej.net/distros/win/ij153-win-java8.zip)
- unzip above package to user's Desktop folder, and rename `ImageJ` folder to `ImageJ.app`
- download BioFormats plugin (https://downloads.openmicroscopy.org/bio-formats/6.6.0/artifacts/bioformats_package.jar), and move `bioformats_package.jar` to `~\Desktop\ImageJ.app\plugins\`, where `~` is user profile directory
- download both MPICBG plugin libraries for ImageJ (https://maven.scijava.org/content/repositories/releases/mpicbg/mpicbg_/1.4.1/mpicbg_-1.4.1.jar and https://maven.scijava.org/content/repositories/releases/mpicbg/mpicbg/1.4.1/mpicbg-1.4.1.jar); then move `mpicbg_-1.4.1.jar` to `~\Desktop\ImageJ.app\plugins\`, and also move `mpicbg-1.4.1.jar` to `~\Desktop\ImageJ.app\jars\`, where `~` is user profile directory

#### 3. ZLAPS
- download `scripts` folder (and its contents) in this git repository to user's Desktop folder
- create a desktop shortcut called `ZLAPS` in user's Desktop folder, pointing to `"%UserProfile%\Desktop\AutoIT3.app\AutoIt3_x64.exe" "%UserProfile%\Desktop\scripts\auto_live_zen.au3"`

## Usage
#### 1. Open and configure ZEN
- open Zeiss ZEN software, and in the `Acquisition` tab, check "Z-stack", "Multiview Acquisition" (even if only acquiring one view), but DO NOT select "Time Series"
- configure proper laser/light path, incubation, objective/magnification, and channels
- select ZEN file output options, so that all views and channels are saved to a single CZI file
- position the specimen roughly in view, and establish correct light sheet position (this can/should be manually adjusted periodically during the experiment)
- set up the desired Multiview acquisition with correct angles and Z-stack start/stop positions

#### 2. Open and configure ZLAPS
- go back to Desktop view, and double-click the `ZLAPS` shortcut to open ZLAPS
- keep ZLAPS open and maximize ZEN window, then use taskbar to bring ZLAPS to foreground
- follow step-by-step instructions in ZLAPS window, including locating `ImageJ.exe` file, identifying location on screen where `Start Experiment` button, `MultiViewList Open`, aand `MultiViewList Save` button are located within `Acquisition` page
- continue ZLAPS step-by-step instructions, including selection of time interval (minutes), CZI save directory, starting timepoint index number (ZLAPS will name all files `LSFM_TXXXX.czi` by timepoint number), and channel number to use for registering consecutive timepoints(if prompted: 0 is first channel, 1 is second, etc.)

#### 3. Go!
- when everything is ready, hit `Start` button in ZLAPS; ZLAPS will control ZEN to acquire images to the chosen directory, at the chosen time interval
- periodically, you can stop the ZLAPS acquisition, adjust lightsheet position (highly recommended for long runs 6h+), confirm the incubation settings, re-center the specimen and use `Reset Positioning`, all before restarting using `Start`
- you can also use `Reset Positioning` if you manually re-center the specimen between acqusitions, without stopping ZLAPS 

#### 4. Previewing Acquisitions
- previewing the experiment is easy, even without running additional scripts, using the following steps in ImageJ or Fiji:
  - File -> Import Image Sequence -> choose any .tif file in `MVL_Updater` sub-directory within the CZI save directory
  - select `Use virtual stack`, and type `File name contains` “V00a” or something like that...
    - ‘V00’, ‘V01’, and ‘V02’ are the views, for example, if you have three views
    - ‘a’ is Z max projection (used for registering in XY)
    - ‘b’ is X max projection (used for registering in Z)
  - once the time series is opened, use the Linear Stack Alignment with SIFT plugin with modest parameters (i.e. min/max image size of 32 and 512) to remove jitter
