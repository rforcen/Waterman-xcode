//
//  Segment.swift
//  Waterman
//
//  Created by asd on 25/12/2018.
//  Copyright © 2018 voicesync. All rights reserved.
//
// Segment item (from,to) for set operations

import SceneKit

class Segment : Equatable, Hashable  {
    var from, to : SCNVector3
    
    init(from: SCNVector3, to:SCNVector3) {
        self.from=from
        self.to=to
    }

    var hashValue: Int {
        get {
            return from.hash() + to.hash()
        }
    }
    
    static func == (left: Segment, right: Segment) -> Bool {
        return  (left.from==right.from && left.to==right.to) ||
                (left.to==right.from && left.from==right.to)
    }
    
}

class Point : Equatable, Hashable  {
    var point : SCNVector3
    
    init(point: SCNVector3) {
        self.point=point
    }
    
    var hashValue: Int {
        get {
            return point.hash()
        }
    }
    
    static func == (left: Point, right: Point) -> Bool {
        return  left.point == right.point
    }
    
}
