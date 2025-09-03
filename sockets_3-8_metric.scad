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
socketHeight2Base = 51;

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

//// Additional tray bottom height
// Extra height added to the bottom of the tray (in mm)
// Positive values make the tray taller by extending downward from the bottom
// Negative values reduce the tray height (use carefully to avoid thin walls)
// This is useful for adding extra strength or clearance to the tray base
additionalTrayHeight = 7;  // mm of height adjustment (positive = taller, negative = shorter)

//// Angle parameters for tilting socket pockets (in degrees)
// Angle for bottom row of sockets (positive tilts forward)
// Recommended range: 0-30 degrees for easy socket removal
bottomSocketAngle = 15;
// Angle for top row of sockets (positive tilts forward)  
// Recommended range: 0-30 degrees for easy socket removal
topSocketAngle = 15;

//// Socket visualization toggle
// Set to true to show semi-transparent sockets in the tray for visualization
showSockets = true;

//// Socket depth parameter
// How much deeper the socket cutouts extend beyond the default depth (as percentage of total tray height)
// 0% = default depth (previous behavior), positive values make sockets go deeper into the tray
// Higher values make sockets sit deeper in the tray for better security
// Recommended: 20-40% deeper for good socket retention without going through the bottom
socketDepthPercent = 2;  // 70% deeper than default

// Wall width between and above sockets
wallWidthBetweenTools = 2;
// Wall size above sockets. Set to 0 for no wall above
wallWidthAboveTools = 2;
// Wall behind the largest socket to the "floor"
wallWidthBehindTools = 2;
// Extra wall width added to either end of the block
wallWidthExtraOnEnds = 1;

// Enter diameters of the socket cut outs as they appear on the block. Add as many or as few as you'd like; the size of the print will automatically adjust
socketDiameters = [17.2, 17.2, 18.4, 19.7, 22.3, 24.3, 24.75, 27.9, 29.8];
// Add the label text for each entry above (there must be an entry for each socket). Text must have have dummy entries to match the diameter array
socketLabels = ["3/8", "7/16", "1/2", "9/16", "5/8", "11/16", "3/4", "13/16", "7/8"];
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

// Calculate actual socket heights using clearance plane approach
// Fixed clearance beyond the furthest tip of tilted sockets
socketClearanceExtension = 3;  // mm of clearance above the furthest socket tip

// Calculate the Y position of the furthest tip of tilted sockets
// Furthest tip Y = socket_height * cos(angle) + socket_radius * sin(angle)
bottomFurthestTipY = socketHeight1Base * cos(bottomSocketAngle) + (largestSocketDiameter/2) * sin(bottomSocketAngle);
topFurthestTipY = socketHeight2Base * cos(topSocketAngle) + (largestSocketDiameter/2) * sin(topSocketAngle);

// Calculate required heights: furthest tip position + extra clearance
socketHeight1 = bottomFurthestTipY + socketClearanceExtension;
socketHeight2 = topFurthestTipY + socketClearanceExtension;

//// Modifies original use of socketHeight variable
//// to accommodate the divier wall
socketHeight = socketHeight1 + socketHeight2 + dividerThickness;

//// Calculate divider wall z axis location
offsetCalc = (textPaddingTopAndBottom * 2) + textSize + socketHeight1;

// Add back wall thickness to ySize when top angle is small to prevent sockets sliding out
backWallThickness = (topSocketAngle <= 5) ? wallWidthBetweenTools : 0;  // Use wallWidthBetweenTools as back wall thickness

xSize = sumAccumulativeOffset(socketDiameters, len(socketDiameters)-1, wallWidthBetweenTools) + wallWidthBetweenTools + (wallWidthExtraOnEnds * 3);
ySize = socketHeight + textAreaThickness + wallWidthAboveTools;
zSize = (largestSocketDiameter / 2) + wallWidthBehindTools + additionalTrayHeight; // Length of the block + additional height adjustment

// Debug output to see the furthest tip positions
echo("Bottom furthest tip Y position:", bottomFurthestTipY, "mm");
echo("Top furthest tip Y position:", topFurthestTipY, "mm");
echo("Bottom total height:", socketHeight1, "mm");
echo("Top total height:", socketHeight2, "mm");
echo("Top socket angle:", topSocketAngle, "degrees");
echo("Back wall thickness:", backWallThickness, "mm");
echo("Total ySize:", ySize, "mm");
echo("Tray height (zSize):", zSize, "mm");
echo("Socket depth:", socketDepth, "mm", "(", socketDepthPercent, "% deeper than default)");

// Calculate where to start to center sockets on the block
socketsPerRow = len(socketDiameters);
yStart = wallWidthBetweenTools; 
xStart = (xSize + wallWidthBetweenTools - sumAccumulativeOffset(socketDiameters, socketsPerRow - 1, wallWidthBetweenTools)) / 2 - 1;
//// Last "-1" added to partially fix uneven left right wall size issue

//// Calculate divider wall height including offset
dividerHeight = zSize - dividerHeightOffset;

//// Position socket cutouts based on socketDepthPercent parameter
socketDepth = zSize * (socketDepthPercent / 100);  // Convert percentage to actual depth
socketHoleZ = zSize - socketDepth;

module solidBlock() {
    cube ([xSize, ySize, zSize]);
}

//// Divider wall added
module solidDivider() {
    cube ([xSize, dividerThickness, dividerHeight]);
}

//// Back wall for top row (when angle is small/zero to prevent sockets sliding out)
module topRowBackWall() {
    if (topSocketAngle <= 5) {
        translate([0, socketHeight + textAreaThickness + wallWidthAboveTools, 0]) {
            cube([xSize, wallWidthBetweenTools, zSize]);
        }
    }
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

// Module to visualize actual sockets sitting in the tray
module visualizeSockets() {
    for (yIndex = [0:socketsPerRow - 1]) {
        // Use actual socket diameter (without clearance)
        diameter = socketDiameters[yIndex];
        xPos = sumAccumulativeOffset(socketDiameters, yIndex, wallWidthBetweenTools) - (0.5 * diameter) + xStart;
        
        // Bottom row sockets - semi-transparent blue
        translate ([xPos, textAreaThickness, socketHoleZ]) {
            rotate([270 + bottomSocketAngle, 0, 0]) {
                color([0, 0.5, 1, 0.6]) // Semi-transparent blue
                cylinder (h = socketHeight1Base, d = diameter, center = false);
            }
        }
        
        // Top row sockets - semi-transparent red  
        translate ([xPos, textAreaThickness + socketHeight1 + dividerThickness, socketHoleZ]) {
            rotate([270 + topSocketAngle, 0, 0]) {
                color([1, 0.3, 0.3, 0.6]) // Semi-transparent red
                cylinder (h = socketHeight2Base, d = diameter, center = false);
            }
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
    //// Divider wall - show when both angles are small (0-5 degrees)
    //// **************************
    if (bottomSocketAngle <= 5 && topSocketAngle <= 5) {
        translate([0,offsetCalc,0]) {
            solidDivider();
        }
    }
    
    //// **************************
    //// Back wall for top row - show when top angle is small to prevent sockets sliding out
    //// **************************
    topRowBackWall();
    
    // **************************
    // Visualize sockets sitting in the tray (optional)
    // **************************
    if (showSockets) {
        visualizeSockets();
    }
}