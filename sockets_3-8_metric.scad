// Author: Russell Stout
// Version 1.4

// Show OpenSCAD version in the console
echo(version=version());

// ***********************************************
// ###############################################
// ***********************************************

// Feel free to edit below this section

// ***********************************************
// ###############################################
// ***********************************************

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Modified by Breno Auto Garage
// to include a central wall
// to divide shallow and deep
// sockets in the same model

// EVERYTHING I'VE ADDED is
// is noted by a double comment ( //// )
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~

//// Divider thickness variable added
// Thickness of the socket divider wall
dividerThickness = 2;

// Height of the socket. Consider adding a few extra mm so the socket fits easily when you are using "wallWidthAboveTools"

//// Two separate heights added, top & bottom
//// (These values are not influenced by clearance offset)
// Bottom socket height base value (exact size, add clearance manually)
socketHeight1Base = 30;
// Top socket height base value (exact size, add clearance manually)  
socketHeight2Base = 54;

// Size of the text
textSize = 5;
// Gap above and below the text
textPaddingTopAndBottom = 1;
// Height of the extruded text
textHeight = 0.6;
// Extrude or emboss text. Options are "emboss" and "engrave"
textPosition = "emboss";
// textPosition = "engrave";

//// Depth below surface for divider wall
dividerHeightOffset = 2;

//// Overall height reduction (for very large sockets)
overallHeightOffset = 0;

//// Angle parameters for tilting socket pockets (in degrees)
// Angle for bottom row of sockets (positive tilts forward)
// Recommended range: 0-30 degrees for easy socket removal
bottomSocketAngle = 0;
// Angle for top row of sockets (positive tilts forward)  
// Recommended range: 0-30 degrees for easy socket removal
topSocketAngle = 0;

// Calculate actual socket heights accounting for tilt angles
socketHeight1 = socketHeight1Base / cos(bottomSocketAngle);
socketHeight2 = socketHeight2Base / cos(topSocketAngle);

// Wall width between and above sockets
wallWidthBetweenTools = 2;
// Wall size above sockets. Set to 0 for no wall above
wallWidthAboveTools = 2;
// Wall behind the largest socket to the "floor"
wallWidthBehindTools = 2;
// Extra wall width added to either end of the block
wallWidthExtraOnEnds = 1;

// Enter diameters of the socket cut outs as they appear on the block. Add as many or as few as you'd like; the size of the print will automatically adjust
socketDiameters = [17.2, 17.2, 17.2, 17.2, 18.4, 19.6, 20.45, 22.3, 23.3, 24.2, 25.7];
// Add the label text for each entry above (there must be an entry for each socket). Text must have have dummy entries to match the diameter array
socketLabels = ["8", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19"];
// OPTIONAL: If this variable is enabled, the heights of each individual socket can be customized. Also, defining the height of each socket is not necessary; any socket height not defined here will default to the height specified above
socketHeightsCustom = [];
// socketHeightsCustom = [35, 40, 45];

// Extra clearance is required to make to socket slip in nicely. The amount of tolerance required varies on the size of socket. Base clearance applied to each hole
socketClearanceOffset = 0.4;
// Percent of diameter extra clearance (e.g. 0.01 = 1%)
socketClearanceGain = 0.01;

//// Font (Liberation Sans is Default)
fontVariable = "Liberation Sans";

// ***********************************************
// ###############################################
// ***********************************************

// You should not need to edit below this section

// ***********************************************
// ###############################################
// ***********************************************

//// Modifies original use of socketHeight variable
//// to accommodate the divier wall
socketHeight = socketHeight1 + socketHeight2 + dividerThickness;

//// Calculate divider wall z axis location
offsetCalc = (textPaddingTopAndBottom * 2) + textSize + socketHeight1;


// Size of the text area
textAreaThickness = textSize + (textPaddingTopAndBottom * 2);

// Recursive function
// calculate the maximum socket size in this row
function largestSocketSize(array, index = 0) = (index < len(array) - 1) 
    ? max(array[index], largestSocketSize(array, index + 1)) 
    : array[index];

// Recursive sum to calculate accumulative offset
function sumAccumulativeOffset(array, index, gap) = index == 0 
    ? array[index] 
    : array[index] + sumAccumulativeOffset(array, index - 1, gap) + gap;

// Overall size of the model
largestSocketDiameter = largestSocketSize(socketDiameters);
xSize = sumAccumulativeOffset(socketDiameters, len(socketDiameters)-1, wallWidthBetweenTools) + wallWidthBetweenTools + (wallWidthExtraOnEnds * 3);
ySize = socketHeight + textAreaThickness + wallWidthAboveTools;
zSize = (largestSocketDiameter / 2) + wallWidthBehindTools - overallHeightOffset; // Length of the block

// Calculate where to start to center sockets on the block
socketsPerRow = len(socketDiameters);
yStart = wallWidthBetweenTools; 
xStart = (xSize + wallWidthBetweenTools - sumAccumulativeOffset(socketDiameters, socketsPerRow - 1, wallWidthBetweenTools)) / 2 - 1;
//// Last "-1" added to partially fix uneven left right wall size issue

//// Calculate divider wall height including offset
dividerHeight = zSize - dividerHeightOffset;

//// Returns socket cutout to where it would be normally to allow overall height offset to sink everything else down except the hole cutouts.
socketHoleZ = zSize + overallHeightOffset;

module solidBlock() {
    cube ([xSize, ySize, zSize]);
}

//// Divider wall added
module solidDivider() {
    cube ([xSize, dividerThickness, dividerHeight]);
}

module textLabels(textHeightNew = textHeight) {
    for (yIndex = [0:socketsPerRow - 1]) {
        diameter = socketDiameters[yIndex];
        xPos = sumAccumulativeOffset(socketDiameters, yIndex, wallWidthBetweenTools) - (0.5 * diameter) + xStart;
        translate ([xPos, 0, 0]) color ([0, 1, 1]) linear_extrude (height = textHeightNew) text (socketLabels[yIndex], size = textSize, valign = "baseline", halign = "center", font = fontVariable);
    }
}

module socketHoles() {
    for (yIndex = [0:socketsPerRow - 1]) {
        socketClearance = (socketDiameters[yIndex] * socketClearanceGain) + socketClearanceOffset;
        diameter = socketDiameters[yIndex] + socketClearance;
        xPos = sumAccumulativeOffset(socketDiameters, yIndex, wallWidthBetweenTools) - (0.5 * diameter) + xStart;
        
        //// Bottom row sockets (shallow sockets) - tilted cylindrical cut
        translate ([xPos, 0, 0]) {
            rotate([270 + bottomSocketAngle, 0, 0]) {
                cylinder (h = socketHeight1 / cos(bottomSocketAngle) + 5, d = diameter, center = false);
            }
        }
        
        //// Top row sockets (deep sockets) - tilted cylindrical cut  
        translate ([xPos, socketHeight1 + dividerThickness, 0]) {
            rotate([270 + topSocketAngle, 0, 0]) {
                cylinder (h = socketHeight2 / cos(topSocketAngle) + 5, d = diameter, center = false);
            }
        }
        
        // Rectangular extrude for straight walls - starts at widest point (radius) of cylinder
        socketRadius = diameter / 2;
        rectWidth = diameter;  // Same width as cylinder diameter
        rectHeight = zSize + 10;  // Extend well above the block
        translate ([xPos - rectWidth/2, -1, socketRadius]) {
            cube([rectWidth, socketHeight + 2, rectHeight]);
        }
    }
}

//// **************************
//// First union adds divider wall to original code
//// **************************
union () {
    difference () {
        union () {
            // **************************
            // Draw the block that will have the sockets cut from
            // **************************
            solidBlock();
            

            // **************************
            // Add EMBOSSED text to the block
            // **************************
            if( textPosition == "emboss" ) {
                translate([0, textPaddingTopAndBottom, zSize]) {
                    textLabels();
                }
            }
        }

        // **************************
        // Remove ENGRAVED text from the block
        // **************************
        if( textPosition == "engrave" ) {
            translate([0, textPaddingTopAndBottom, (zSize - textHeight)]) {
                // Add some extra height to extrude text past block top surface
                textLabels(textHeight + 0.1);
            } 
        }

        // **************************
        // Cut out the sockets
        // **************************
        translate([0,textAreaThickness,socketHoleZ]) {
            // Loop through all the specified sockets
            socketHoles();
        }
    }
    
    //// **************************
    //// Divider wall
    //// **************************
    translate([0,offsetCalc,0]) {
        solidDivider();
    }
}