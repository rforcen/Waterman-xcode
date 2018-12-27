//
//  testWatermanCPP.hpp
//  WatermanPoly
//
//  Created by asd on 09/12/2018.
//  Copyright © 2018 voicesync. All rights reserved.
//
// included in "C" bridging-header

#ifndef testWatermanCPP_hpp
#define testWatermanCPP_hpp

#include <stdlib.h>
typedef long Intsw;

Intsw genWaterman(double radius, Intsw*nFaces, Intsw**faces, Intsw*nCoords, double**coords);
void freeMem(void*ptr);
#endif
