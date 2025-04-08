/*

 Header file for struct used in fragment shader to pass in various parameters.
 
 Declare this Bridging file inside of the Build Settings
 Under the Build Settings tab -> Use the Filter text box to search for: 'Swift Compiler - General'
 Under the Swift Compiler - General settings -> add the path to this header
 file to the Object-C Briding Header -> SwiftMetal/Metal/Shaders/CommonDataTypes.h
 This allows you to use the struct in the Metal fragment shader code and also in the swift code.

 The file should not be included in "Target Membership" under File Inspector

 */

#ifndef CommonDataTypes_h

#define CommonDataTypes_h

typedef struct {
    
    float time;
    float deltaTime;
    float width;
    float height;
    
} Params;


#endif
