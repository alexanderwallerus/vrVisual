# A replacement virtual reality visualization for a commercial rodent VR setup. It allows moving high resolution animated shapes.

## Usage
* Before first usage:
  * run createEncoded.pde to create encoded images for all parameter combinations and copy them into the original software's image data folder
  * In the .xml file for each experiment, replace the original image file names with those of the created encoded images. Replace the x/y coordinates and display order like in the example sampleXML.xml.
* Running the new VR:
  * Start the original VR software the same way as before, using the modified .xml file for your experiment
  * run runVisual.bat
  * After the experiment simply close all sketch windows

## How it works
This program takes advantage of the original VR setup having more displays available than are used for the experiment. The original VR is set to draw the encoded images on the hidden unused screens instead of the VR screens. The program reads in the pixels from those hidden screens to figure out the position of shapes, and the parameters encoded in the read in colors. It then draws the shapes onto the actual VR screens in real time, with the proper orientation, brightness, interpolation of the shape contour, and a continously moving texture.
For improved performance the left and right shapes are actually sketch windows without a title bar, which are being moved on the screens.

![example](/data/setup.png)

## Notes:
It is unlikely this code will ever find an application outside of the very specific setup and purpose for which it was programmed.

Due to limitations of the setup this code had to be written for processing2.2.1. Some parts could be better implemented with access to newer functionalities.

readAvgBright.pde and generateBrightness.pde are not needed to run the actual program, but may be helpful additions.
readAvgBright.pde just calculates the average brightness of a referenced image file containing i.e. a texture or screen snip and generateBrightness.pde creates textures with provided brightness scalings.