//
//  C_Interface.swift
//  WatermanPoly
//
//  Created by asd on 18/12/2018.
//  Copyright © 2018 voicesync. All rights reserved.
//

import SceneKit

func genWatermanCoords(radius : Double) -> [[SCNVector3]] {
    func genWatermanPoly(radius:Double) -> (ok:Bool, faces:[Int], vertices:[Double]) {
        var nFaces:Int=0
        var nCoords:Int=0
        var _faces : UnsafeMutablePointer<Int>?=nil
        var _coords :UnsafeMutablePointer<Double>?=nil
        
        let ok=Bool( truncating: genWaterman(Double(radius), &nFaces, &_faces, &nCoords, &_coords) as NSNumber )
        
        let ifaces = Array<Int>( UnsafeMutableBufferPointer(start: _faces, count: nFaces) )
        let vertices = Array<Double> ( UnsafeMutableBufferPointer(start: _coords, count: nCoords*3))
        
        freeMem(_faces) // release _faces, _coords
        freeMem(_coords)
        
        return (ok, faces:ifaces, vertices:vertices)
    }
    
    func genCoords(faces:[Int], vertices:[Double]) -> [[SCNVector3]] {
        var i:Int=0
        var coords=[[SCNVector3]]()
        
        repeat {
            let n=faces[i]
            i+=1
            var crdf=[SCNVector3]()
            for j in 0..<n {
                let ix=faces[(i+j)] * 3
                crdf.append(SCNVector3Make(Real(vertices[ix+0]), Real(vertices[ix+1]), Real(vertices[ix+2])))
            }
            coords.append(crdf)
            
            i=i+n
        } while i<faces.count
        return coords
    }
    
    let wp = genWatermanPoly(radius: radius)
    return genCoords(faces: wp.faces, vertices: wp.vertices)
}
