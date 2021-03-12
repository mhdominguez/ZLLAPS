# ZLAPS
ZEN (Zeiss) Live Lightsheet Adaptive Positioning Scripts

## Requirements
Requires Zeiss ZEN workstation on MS Windows x64, with multiview acquisition (i.e. Zeiss Lightsheet Z.1).  This application does NOT require administrator privileges to install or run.

## Install
#### 1. AutoIT3
- Download zipped AutoIT3 ready-to-run package: https://www.autoitscript.com/cgi-bin/getfile.pl?autoit3/autoit-v3.zip
- Unzip above package to user's Desktop folder, and rename `install` folder to `AutoIT3.app`

#### 2. ImageJ
- Download zipped ImageJ 1 (i.e. v1.53, NOT Fiji) ready-to-run package: https://wsr.imagej.net/distros/win/ij153-win-java8.zip
- Unzip above package to user's Desktop folder, and rename `ImageJ` folder to `ImageJ.app`
- Download BioFormats plugin: https://downloads.openmicroscopy.org/bio-formats/6.6.0/artifacts/bioformats_package.jar, and move `bioformats_package.jar` file to `~\Desktop\ImageJ.app\plugins\` folder, where `~` is user profile directory
- Download 

#### 3. ZLAPS
- Download contents of `scripts` folder in this git repository to user's Desktop folder
- Create a desktop shortcut in user's Desktop folder, pointing to `"%UserProfile%\Desktop\AutoIT3.app\AutoIt3_x64.exe" %UserProfile%\Desktop\scripts\auto_live_zen.au3`
