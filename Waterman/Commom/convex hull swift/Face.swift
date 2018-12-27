// package com.vs

// import java.util.*

/**
 * Basic triangular face used to form the hull.
 *
 * <p>The information stored for each face consists of a planar
 * normal, a planar offset, and a doubly-linked list of three <a
 * href=HalfEdge>HalfEdges</a> which surround the face in a
 * counter-clockwise direction.
 *
 * @author John E. Lloyd, Fall 2004 */

import Foundation

class Face
{
    var he0 : HalfEdge? = nil
    private var normal = Vector3d()
    private var centroid = Point3d()
    
    var area : Double = 0
    
    var planeOffset : Double = 0
    var index : Int = 0
    var numVerts : Int = 0
    
    var next : Face? = nil
    
    static  let VISIBLE : Int = 1
    static  let NON_CONVEX : Int = 2
    static  let DELETED : Int = 3
    
    var mark : Int = VISIBLE
    
    var outside : Vertex? = nil
    
    
    func computeCentroid ()
    {
        centroid.setZero()
        for he in HalfEdgeLoopIterator(start:he0)
        {
            centroid.add (he.head()!.pnt)
        }
        
        centroid.scale (1.0/Double(numVerts))
    }
    
    func computeNormal (_ minArea : Double)
    {
        computeNormal()
        
        if (area < minArea)
        {
            // make the normal more robust by removing
            // components parallel to the longest edge
            
            var hedgeMax : HalfEdge?
            var lenSqrMax : Double = 0
            for  hedge in HalfEdgeLoopIterator(start: he0)
            {
                let lenSqr : Double = hedge.lengthSquared()
                if (lenSqr > lenSqrMax)
                { hedgeMax = hedge
                    lenSqrMax = lenSqr
                }
            }
            
            let p2 : Point3d = hedgeMax!.head()!.pnt
            let p1 : Point3d = hedgeMax!.tail()!.pnt
            let lenMax : Double = sqrt(lenSqrMax)
            let ux : Double = (p2.x - p1.x)/lenMax
            let uy : Double = (p2.y - p1.y)/lenMax
            let uz : Double = (p2.z - p1.z)/lenMax
            let dot : Double = normal.x*ux + normal.y*uy + normal.z*uz
            normal.x -= dot*ux
            normal.y -= dot*uy
            normal.z -= dot*uz
            
            normal.normalize()
        }
    }
    
    func computeNormal ()
    {
        let p0 = he0!.head()!.pnt
        var p2 = he0!.next!.head()!.pnt
        
        var d2x = p2.x - p0.x
        var d2y = p2.y - p0.y
        var d2z = p2.z - p0.z
        
        normal.setZero()
        
        numVerts = 2
        
        for he2 in HalfEdgeNNLoopIterator(start: he0) { // from he0.next.next to he0
            let d1x = d2x, d1y = d2y, d1z = d2z
            
            p2 = he2.head()!.pnt
            
            d2x = p2.x - p0.x
            d2y = p2.y - p0.y
            d2z = p2.z - p0.z
            
            normal.add( Vector3d(d1y*d2z - d1z*d2y, d1z*d2x - d1x*d2z, d1x*d2y - d1y*d2x) )
            
            numVerts+=1
        }
        area = normal.norm()
        normal.scale (1/area)
    }
    
    private func computeNormalAndCentroid()
    {
        computeNormal()
        computeCentroid ()
        planeOffset = normal.dot(centroid)
        
        let numv = HalfEdgeLoopIterator(start: he0).count
        
        assert( (numv == numVerts) , "face \(getVertexString()) numVerts=\(numVerts) should be \(numv)")
    }
    
    private func computeNormalAndCentroid(_ minArea : Double)
    {
        computeNormal (minArea)
        computeCentroid ()
        planeOffset = normal.dot(centroid)
    }
    
    class func createTriangle (_ v0 : Vertex, _ v1 : Vertex, _ v2 : Vertex) -> Face
    {
        return createTriangle (v0, v1, v2, 0)
    }
    
    /**
     * Constructs a triangule Face from vertices v0, v1, and v2.
     *
     * @param v0 first vertex
     * @param v1 second vertex
     * @param v2 third vertex
     */
    class func createTriangle (_ v0 : Vertex, _ v1 : Vertex, _ v2 : Vertex,
                                      _ minArea : Double) -> Face
    {
        let face = Face()
        let he0 = HalfEdge (v0, face)
        let he1 = HalfEdge (v1, face)
        let he2 = HalfEdge (v2, face)
        
        he0.prev = he2
        he0.next = he1
        he1.prev = he0
        he1.next = he2
        he2.prev = he1
        he2.next = he0
        
        face.he0 = he0
        
        // compute the normal and offset
        face.computeNormalAndCentroid(minArea)
        return face
    }
    
    class func create (_ vtxArray : [Vertex], _ indices : [Int]) -> Face
    {
        let face = Face()
        var hePrev : HalfEdge? = nil
        for idx in indices
        {
            let he = HalfEdge (vtxArray[idx], face)
            if (hePrev != nil)
            {
                he.setPrev (hePrev!)
                hePrev!.setNext (he)
            }
            else
            {
                face.he0 = he
            }
            hePrev = he
        }
        face.he0!.setPrev (hePrev!)
        hePrev!.setNext (face.he0)
        
        // compute the normal and offset
        face.computeNormalAndCentroid()
        return face
    }
    
    init ()
    {
        normal = Vector3d()
        centroid = Point3d()
        mark = Face.VISIBLE
    }
    
    /**
     * Gets the i-th half-edge associated with the face.
     *
     * @param i the half-edge index, in the range 0-2.
     * @return the half-edge
     */
    func getEdge(_ _i : Int) -> HalfEdge?
    {
        var i=_i
        var he = he0
        
        while i > 0
        { he = he!.next
            i=i-1
        }
        while i < 0
        { he = he!.prev
            i=i+1
        }
        return he
    }
    
    func getFirstEdge() -> HalfEdge?
    {
        return he0
    }
    
    /**
     * Finds the half-edge within this face which has
     * tail <code>vt</code> and head <code>vh</code>.
     *
     * @param vt tail point
     * @param vh head point
     * @return the half-edge, or null if none is found.
     */
    func findEdge (_ vt : Vertex, _ vh : Vertex) -> HalfEdge?
    {
        for he in HalfEdgeLoopIterator(start: he0) {
            if (he.head() === vh && he.tail() === vt) {
                return he
            }
        }
        return nil
    }
    
    /**
     * Computes the distance from a point p to the plane of
     * this face.
     *
     * @param p the point
     * @return distance from the point to the plane
     */
    func distanceToPlane (_ p : Point3d) -> Double
    {
        return normal.x*p.x + normal.y*p.y + normal.z*p.z - planeOffset
    }
    
    /**
     * Returns the normal of the plane associated with this face.
     *
     * @return the planar normal
     */
    func getNormal () -> Vector3d?
    {
        return normal
    }
    
    func getCentroid () -> Point3d?
    {
        return centroid
    }
    
    func numVertices() -> Int
    {
        return numVerts
    }
    
    func getVertexString () -> String
    {
        var s = ""
        
        for he in HalfEdgeLoopIterator(start: he0) {
            if (s.isEmpty) {
                s = "\(he.head()!.index)"
            } else {
                s += "\(he.head()!.index)"
            }
        }
        
        return s
    }
    
    func getVertexIndices (idxs : inout [Int])
    {
        var i : Int = 0
        for he in HalfEdgeLoopIterator(start: he0) {
            idxs[i] = he.head()!.index
            i+=1
        }
    }
    
    private func connectHalfEdges (_ hedgePrev : HalfEdge?, _ hedge : HalfEdge?) -> Face?
    {
        var discardedFace : Face?
        
        if (hedgePrev!.oppositeFace() === hedge!.oppositeFace())
        { // then there is a redundant edge that we can get rid off
            
            let oppFace = hedge!.oppositeFace()
            var hedgeOpp : HalfEdge?
            
            if (hedgePrev === he0)
            { he0 = hedge
            }
            if (oppFace!.numVertices() == 3)
            { // then we can get rid of the opposite face altogether
                hedgeOpp = hedge!.getOpposite()!.prev!.getOpposite()
                
                oppFace!.mark = Face.DELETED
                discardedFace = oppFace
            }
            else
            { hedgeOpp = hedge!.getOpposite()!.next!
                
                if (oppFace!.he0 === hedgeOpp!.prev)
                { oppFace!.he0 = hedgeOpp
                }
                hedgeOpp!.prev = hedgeOpp!.prev!.prev
                hedgeOpp!.prev!.next = hedgeOpp
            }
            hedge!.prev = hedgePrev!.prev
            hedge!.prev!.next = hedge
            
            hedge!.opposite = hedgeOpp
            hedgeOpp!.opposite = hedge
            
            // oppFace was modified, so need to recompute
            oppFace!.computeNormalAndCentroid()
        }
        else
        {
            hedgePrev!.next = hedge
            hedge!.prev = hedgePrev
        }
        return discardedFace
    }
    
    func checkConsistency()
    {
        // do a sanity check on the face
        var maxd = 0.0
        var numv = 0
        
        assert( !(numVerts < 3), "degenerate face: \(getVertexString())")

        for hedge in HalfEdgeLoopIterator(start: he0) {
            let hedgeOpp = hedge.getOpposite()
            let oppFace = hedgeOpp!.face
            
            assert (!(hedgeOpp == nil), "face \(getVertexString()) :unreflected half edge  \(hedge.getVertexString())")
            assert(!(hedgeOpp!.getOpposite() !== hedge), "face \(getVertexString()) : opposite half edge \(hedgeOpp!.getVertexString()) has opposite \(hedgeOpp!.getOpposite()!.getVertexString())")
            assert(!(hedgeOpp!.head() !== hedge.tail() || hedge.head() !== hedgeOpp!.tail()),
                   "face \(getVertexString()) : half edge \(hedge.getVertexString()) reflected by \(hedgeOpp!.getVertexString())")
            assert (!(oppFace == nil), "face \(getVertexString()) : no face on half edge \(hedgeOpp!.getVertexString())")
            assert (!(oppFace!.mark == Face.DELETED), "face \(getVertexString()) : opposite face \(oppFace!.getVertexString()) not on hull")

            let d = abs(distanceToPlane(hedge.head()!.pnt))
            if (d > maxd)
            {
                maxd = d
            }
            numv+=1
        }
        
        assert( !(numv != numVerts), "face \(getVertexString()) numVerts=\(numVerts) should be \(numv)")
        
    }
    
    func mergeAdjacentFace (_ hedgeAdj : HalfEdge?,
                            _ discarded : inout [Face]) -> Int
    {
        let oppFace = hedgeAdj!.oppositeFace()
        var numDiscarded : Int = 0
        
        discarded[numDiscarded] = oppFace!
        numDiscarded+=1
        oppFace!.mark = Face.DELETED
        
        let hedgeOpp = hedgeAdj!.getOpposite()
        
        var hedgeAdjPrev = hedgeAdj!.prev,
            hedgeAdjNext = hedgeAdj!.next,
            hedgeOppPrev = hedgeOpp!.prev,
            hedgeOppNext = hedgeOpp!.next
        
        while hedgeAdjPrev!.oppositeFace() === oppFace
        {
            hedgeAdjPrev = hedgeAdjPrev!.prev
            hedgeOppNext = hedgeOppNext!.next
        }
        
        while hedgeAdjNext!.oppositeFace() === oppFace
        {
            hedgeOppPrev = hedgeOppPrev!.prev
            hedgeAdjNext = hedgeAdjNext!.next
        }
        
        for  hedge in HalfEdgeRangeIterator(from: hedgeOppNext, to: hedgeOppPrev!.next)
        {
            hedge.face = self
        }
        
        if (hedgeAdj === he0)
        {
            he0 = hedgeAdjNext
        }
        
        // handle the half edges at the head
        var discardedFace = connectHalfEdges (hedgeOppPrev, hedgeAdjNext)
        if (discardedFace !== nil) {
            discarded[numDiscarded] = discardedFace!
            numDiscarded+=1
        }
        
        // handle the half edges at the tail
        discardedFace = connectHalfEdges (hedgeAdjPrev, hedgeOppNext)
        if (discardedFace != nil) {
            discarded[numDiscarded] = discardedFace!
            numDiscarded+=1
        }
        
        computeNormalAndCentroid ()
        checkConsistency()
        
        return numDiscarded
    }
    
    private func areaSquared (_ hedge0 : HalfEdge, _ hedge1 : HalfEdge) -> Double
    {
        // return the squared area of the triangle defined
        // by the half edge hedge0 and the point at the
        // head of hedge1.
        
        let p0 = hedge0.tail()!.pnt
        let p1 = hedge0.head()!.pnt
        let p2 = hedge1.head()!.pnt
        
        let dx1 = p1.x - p0.x
        let dy1 = p1.y - p0.y
        let dz1 = p1.z - p0.z
        
        let dx2 = p2.x - p0.x
        let dy2 = p2.y - p0.y
        let dz2 = p2.z - p0.z
        
        let x = dy1*dz2 - dz1*dy2
        let y = dz1*dx2 - dx1*dz2
        let z = dx1*dy2 - dy1*dx2
        
        return x*x + y*y + z*z
    }
    
    func triangulate (_ newFaces : FaceList, _ minArea : Double)
    {
        
        if (numVertices() < 4)
        {
            return
        }
        
        let v0 = he0!.head()!
        
        var hedge = he0!.next!
        var oppPrev : HalfEdge = hedge.opposite!
        var face0 : Face?
        
        for hedge in HalfEdgeRangeIterator(from:he0!.next, to:he0!.prev)
        {
            let face = Face.createTriangle (v0, hedge.prev!.head()!, hedge.head()!, minArea)
            face.he0!.next!.setOpposite (oppPrev)
            face.he0!.prev!.setOpposite (hedge.opposite)
            oppPrev = face.he0!
            newFaces.add (face)
            if (face0 == nil)
            {
                face0 = face
            }
        }
        
        hedge = HalfEdge (he0!.prev!.prev!.head()!, self)
        hedge.setOpposite (oppPrev)
        
        hedge.prev = he0
        hedge.prev!.next = hedge
        
        hedge.next = he0!.prev
        hedge.next!.prev = hedge
        
        computeNormalAndCentroid (minArea)
        checkConsistency()
        
        for face in FaceIterator(face0!) {
            face.checkConsistency()
        }
        
    }
    
    // generate multiple instances of Vector3d
    static func array(_ n : Int) -> [Face] {
        var v = [Face]()
        for _ in 0..<n {
            v.append(Face())
        }
        return v
    }
}




