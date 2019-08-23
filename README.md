# Easy-Nightlight
Using ENVI-IDL to extract nighttime light data for social and economic studies.

**This repo is written in IDL, not Prolog.**

## Background
With the development of remote sensing techniques, people now can observe the beautiful night light on the Earth. It is common for researchers in the fields of remote sensing and economics to analyze those nighttime lights in a long sequence with GIS techniques. 

The most basic application is to calibrate nighttime light data, sometimes with the need to clip nighttime light images in order to save computation time. However, repeated works are annoying and hence I develop two simple tools, namely Easy-Subset and Easy-BandMath, as presented here.

## Documents
A simple Chinese version of user guide is attached since this was originally a homework of mine in ENVI-IDL programming when I was at Sun Yat-sen University. Feel free to contact me (liushengjie0756 (at) gmail.com) if you need any help.

*To do*: Add an English version of user guide.

## Usage
To run the program, your computer should install ENVI first. **The program was tested on ENVI 5.3 with IDL 8.5.** 

You can choose to build the program from the source code, download it from Google Drive (*To do*) or contact me for the prebuild version. 

You need to edit the parameters "DefaultAction" and "Action" in "ui.ini" so that the program can locate ENVI. The default setting assumes that ENVI is installed at "D://Program Files".

