//
//  SCNVector3Extensions.swift
//  PlatonicPolyhedra
//
//  Created by asd on 04/12/2018.
//  Copyright © 2018 voicesync. All rights reserved.
//

/*
 * Copyright (c) 2013-2014 Kim Pedersen
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import SceneKit

extension SCNVector3
{
    /**
     * Negates the vector described by SCNVector3 and returns
     * the result as a new SCNVector3.
     */
    func negate() -> SCNVector3 {
        return self * -1
    }
    
    /**
     * Negates the vector described by SCNVector3
     */
    mutating func negated() -> SCNVector3 {
        self = negate()
        return self
    }
    
    /**
     * Returns the length (magnitude) of the vector described by the SCNVector3
     */
    func length() -> CGFloat {
         return CGFloat(sqrt((x*x + y*y + z*z)))
    }
    
    /**
     * Normalizes the vector described by the SCNVector3 to length 1.0 and returns
     * the result as a new SCNVector3.
     */
    func normalized() -> SCNVector3 {
        return self / length()
    }
    
    /**
     * Normalizes the vector described by the SCNVector3 to length 1.0.
     */
    mutating func normalize() -> SCNVector3 { // changes content of self
        self = normalized()
        return self
    }
    
    /**
     * Calculates the distance between two SCNVector3. Pythagoras!
     */
    func distance(vector: SCNVector3) -> CGFloat {
        return (self - vector).length()
    }
    
    /**
     * Calculates the dot product between two SCNVector3.
     */
    func dot(vector: SCNVector3) -> CGFloat {
        return CGFloat(x * vector.x + y * vector.y + z * vector.z)
    }
    
    /**
     * Calculates the cross product between two SCNVector3.
     */
    func cross(vector: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(y * vector.z - z * vector.y, z * vector.x - x * vector.z, x * vector.y - y * vector.x)
    }
    
   
    /**
     * hash
     */
    func hash() -> Int {
        return Int(self.x * 73856093 + self.y * 19349663 + self.z * 83492791)
    }
    
    func string() -> String {
        return "\(self)"
    }
    
    
}

/**
 * Adds two SCNVector3 vectors and returns the result as a new SCNVector3.
 */
func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

/**
 * Increments a SCNVector3 with the value of another.
 */
func += ( left: inout SCNVector3, right: SCNVector3) {
    left = left + right
}

/**
 * Subtracts two SCNVector3 vectors and returns the result as a new SCNVector3.
 */
func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
}

/**
 * Decrements a SCNVector3 with the value of another.
 */
func -= ( left: inout SCNVector3, right: SCNVector3) {
    left = left - right
}

/**
 * Multiplies two SCNVector3 vectors and returns the result as a new SCNVector3.
 */
func * (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x * right.x, left.y * right.y, left.z * right.z)
}

/**
 * Multiplies a SCNVector3 with another.
 */
func *= ( left: inout SCNVector3, right: SCNVector3) {
    left = left * right
}

/**
 * Multiplies the x, y and z fields of a SCNVector3 with the same scalar value and
 * returns the result as a new SCNVector3.
 */
func * (vector: SCNVector3, scalar: CGFloat) -> SCNVector3 {
    return SCNVector3Make(vector.x * Real(scalar), vector.y * Real(scalar), vector.z * Real(scalar))
}

/**
 * Multiplies the x and y fields of a SCNVector3 with the same scalar value.
 */
func *= ( vector: inout SCNVector3, scalar: CGFloat) {
    vector = vector * scalar
}

/**
 * Divides two SCNVector3 vectors abd returns the result as a new SCNVector3
 */
func / (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x / right.x, left.y / right.y, left.z / right.z)
}

/**
 * Divides a SCNVector3 by another.
 */
func /= ( left: inout SCNVector3, right: SCNVector3) {
    left = left / right
}

/**
 * Divides the x, y and z fields of a SCNVector3 by the same scalar value and
 * returns the result as a new SCNVector3.
 */
func / (vector: SCNVector3, scalar: CGFloat) -> SCNVector3 {
    return SCNVector3Make(vector.x / Real(scalar), vector.y / Real(scalar), vector.z / Real(scalar))
}

/**
 * Divides the x, y and z of a SCNVector3 by the same scalar value.
 */
func /= ( vector: inout SCNVector3, scalar: CGFloat) {
    vector = vector / scalar
}

/**
 * Negate a vector
 */
func SCNVector3Negate(vector: SCNVector3) -> SCNVector3 {
    return vector * -1
}

/**
 * Compare vectors
 */
func == (v1: SCNVector3, v2:SCNVector3) -> Bool {
    return v1.x==v2.x && v1.y==v2.y && v1.z==v2.z
}

/**
 * Returns the length (magnitude) of the vector described by the SCNVector3
 */
func SCNVector3Length(vector: SCNVector3) -> CGFloat
{
    return sqrt(CGFloat(vector.x*vector.x + vector.y*vector.y + vector.z*vector.z))
}

/**
 * Returns the distance between two SCNVector3 vectors
 */
func SCNVector3Distance(vectorStart: SCNVector3, vectorEnd: SCNVector3) -> CGFloat {
    return SCNVector3Length(vector: vectorEnd - vectorStart)
}

/**
 * Returns the distance between two SCNVector3 vectors
 */
func SCNVector3Normalize(vector: SCNVector3) -> SCNVector3 {
    return vector / SCNVector3Length(vector: vector)
}

/**
 * Calculates the dot product between two SCNVector3 vectors
 */
func SCNVector3DotProduct(left: SCNVector3, right: SCNVector3) -> CGFloat {
    return CGFloat(left.x * right.x + left.y * right.y + left.z * right.z)
}

/**
 * Calculates the cross product between two SCNVector3 vectors
 */
func SCNVector3CrossProduct(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.y * right.z - left.z * right.y, left.z * right.x - left.x * right.z, left.x * right.y - left.y * right.x)
}

/**
 * Calculates the SCNVector from lerping between two SCNVector3 vectors
 */
func SCNVector3Lerp(vectorStart: SCNVector3, vectorEnd: SCNVector3, t: CGFloat) -> SCNVector3 {
    return SCNVector3Make(vectorStart.x + ((vectorEnd.x - vectorStart.x) * Real(t)), vectorStart.y + ((vectorEnd.y - vectorStart.y) * Real(t)), vectorStart.z + ((vectorEnd.z - vectorStart.z) * Real(t)))
}

/**
 * Project the vector, vectorToProject, onto the vector, projectionVector.
 */
func SCNVector3Project(vectorToProject: SCNVector3, projectionVector: SCNVector3) -> SCNVector3 {
    let scale: CGFloat = SCNVector3DotProduct(left: projectionVector, right: vectorToProject) / SCNVector3DotProduct(left: projectionVector, right: projectionVector)
    let v: SCNVector3 = projectionVector * scale
    return v
}

func SCNVector3Normal(p:SCNVector3, p1:SCNVector3, p2:SCNVector3) -> SCNVector3 {
    var n=SCNVector3(), pa=SCNVector3(), pb=SCNVector3()
    
    pa.x = p1.x - p.x
    pa.y = p1.y - p.y
    pa.z = p1.z - p.z
    pb.x = p2.x - p.x
    pb.y = p2.y - p.y
    pb.z = p2.z - p.z
    n.x = pa.y * pb.z - pa.z * pb.y
    n.y = pa.z * pb.x - pa.x * pb.z
    n.z = pa.x * pb.y - pa.y * pb.x
    
    return SCNVector3Normalize(vector: n)
}

func SCNVectorNormal(vertices:[SCNVector3]) -> SCNVector3 {
    return SCNVector3Normal(p: vertices[0], p1: vertices[1], p2: vertices[2])
}

func string2v3Pair(_ s:String) -> (from:SCNVector3, to:SCNVector3) { // ^[-+]?[0-9]\d*(\.\d+)?$
    let regex = try? NSRegularExpression(pattern: "[-+]?\\d*\\.\\d+", options: [])
    let resMatch = regex?.matches(in: s, options: [], range: NSMakeRange(0, s.count))
    let nsStr = s as NSString
    return (
        SCNVector3(
            CGFloat(Float(nsStr.substring(with: resMatch![0].range))!),
            CGFloat(Float(nsStr.substring(with: resMatch![1].range))!),
            CGFloat(Float(nsStr.substring(with: resMatch![2].range))!)),
        
        SCNVector3(
            CGFloat(Float(nsStr.substring(with: resMatch![3].range))!),
            CGFloat(Float(nsStr.substring(with: resMatch![4].range))!),
            CGFloat(Float(nsStr.substring(with: resMatch![5].range))!))
    )
}

func v3NotInSet(set:Set<String>, vf:SCNVector3, vt:SCNVector3) -> Bool {
    return !set.contains("\(vf,vt)") && !set.contains("\(vt,vf)")
}


func pair2String(_ x:Int, _ y:Int) -> String {
    return "\(x,y)"
}

func string2Pair(_ s:String) -> (x:Int, y:Int) {
    let regex = try? NSRegularExpression(pattern: "\\d+", options: [])
    let resMatch = regex?.matches(in: s, options: [], range: NSMakeRange(0, s.count))
    let nsStr = s as NSString
    return (
        Int(nsStr.substring(with: resMatch![0].range))!,
        Int(nsStr.substring(with: resMatch![1].range))!
    )
}

func pairNotInSet(set:Set<String>, x:Int, y:Int) -> Bool {
    let sf="\(x,y)", st="\(y,x)"
    return !set.contains(sf) && !set.contains(st)
}
