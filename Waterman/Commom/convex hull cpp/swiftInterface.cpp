//
//  testWatermanCPP.cpp
//  WatermanPoly
//
//  Created by asd on 09/12/2018.
//  Copyright © 2018 voicesync. All rights reserved.
//

#include "watermanpoly.h"

typedef long Intsw; // the swift Int type

extern "C" {
    Intsw genWaterman(double radius, Intsw*nFaces, Intsw**__faces, Intsw*nCoords, double**__coords) {
        class Local {
        public:
            static double* normalizeCoords(double*coords, Intsw nc3) {
                double maxc=-__DBL_MAX__, minc=__DBL_MAX__;
                for (Intsw i=0; i<nc3; i++) {
                    maxc=std::max<double>(maxc, coords[i]);
                    minc=std::min<double>(minc, coords[i]);
                }
                double diff=abs(maxc-minc);
                if(diff!=0)
                    for (Intsw i=0; i<nc3; i++) coords[i]/=diff;
                return coords;
            }
            
            static double* copyCoords(vector<Point3d*> &points) {
                Intsw nc3=points.size() * 3;
                auto coords = (double*)calloc(nc3, sizeof(double));
                
                for (size_t i=0, j=0; i<points.size(); i++, j+=3) {
                    auto pnt=points[i];
                    coords[j+0]=pnt->x;
                    coords[j+1]=pnt->y;
                    coords[j+2]=pnt->z;
                }
                return coords;
            }
            
            static double* genNormalizedCoords(vector<Point3d*>points) {
                return normalizeCoords(copyCoords(points), points.size()*3);
            }
            
            
            static Intsw sumFaces(vector<vector<int>> &_faces) {
               
                Intsw sumFaceIx=_faces.size();
                for (auto f:_faces) sumFaceIx+=f.size();
                return sumFaceIx;
            }
            
            static Intsw*genFaces(vector<vector<int>> &_faces) {  // faces: [n0, f0, f1.., n1, f10, f11 ]
                Intsw*faces=(Intsw*)calloc(sumFaces(_faces), sizeof(Intsw));
                
                Intsw ixf=0;
                for (auto _face:_faces) {
                    faces[ixf++]=_face.size();
                    for (auto _f:_face) faces[ixf++]=_f;
                }
                return faces;
            }
        };
        
        WatermanPoly poly;
        QuickHull3D hull=poly.genHull(radius);
        
        bool ok=hull.check();
        
        if(ok) {
            auto faces = hull.getFaces();

            *nCoords = hull.getNumVertices();
            *nFaces  = Local::sumFaces(faces);
            
            *__coords=Local::genNormalizedCoords(hull.getVertices());
            *__faces =Local::genFaces(faces);
        }
        
        return ok;
    }
    
    void freeMem(void*ptr) {
        if (ptr) free(ptr);
    }
}
