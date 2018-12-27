//
//  Waterman.swift
//  WatermanPoly
//
//  Created by asd on 07/12/2018.
//  Copyright © 2018 voicesync. All rights reserved.
//

import SceneKit

class Waterman {
    static func waterMan(radius:Float) -> [[SCNVector3]] {
        
        func doCoords(radius:Float) -> [[SCNVector3]] {
            
            func doRawPoly() -> (faces:[Int32], coords:[Float]) {
                var _coords:UnsafeMutablePointer<Float>?=nil
                var _faces:UnsafeMutablePointer<Int32>?=nil
                var nCoords:Int32=0
                var nFaces:Int32=0
                
                getFaces(radius, &nCoords, &_coords, &nFaces, &_faces)
                
                let faces=Array( UnsafeBufferPointer(start:  UnsafePointer(_faces), count: Int(nFaces)) )
                let coords=Array( UnsafeBufferPointer(start:  UnsafePointer(_coords), count: Int(nCoords)) )
                
                freeMem(_faces)
                freeMem(_coords)
                
                return (faces, coords)
            }
            
            let rawPoly=doRawPoly()
            var coords=[[SCNVector3]]()
            
            var ix:Int32=0
            for _face in rawPoly.faces {
                var cf=[SCNVector3]()
                for i in 0..<_face {
                    let cix=Int((i+ix)*3)
                    cf.append(SCNVector3(rawPoly.coords[cix+0], rawPoly.coords[cix+1], rawPoly.coords[cix+2]))
                }
                coords.append(cf)
                ix+=_face
            }
            return coords
        }
        
        return doCoords(radius:radius)
    }
    
    static func coords2String(coords:[[SCNVector3]]) -> String {
        var t=""
        for crd in coords {
            t+=String(crd.count)+": "
            for c in crd {
                t+="(" + String(Float(c.x)) + "," + String(Float(c.y)) + "," + String(Float(c.z)) + ") - "
            }
            t+="\n"
        }
        return t
    }
}
