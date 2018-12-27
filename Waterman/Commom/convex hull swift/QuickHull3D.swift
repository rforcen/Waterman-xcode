/**
 * Computes the convex hull of a set of three dimensional points.
 *
 * <p>The algorithm is a three dimensional implementation of Quickhull, as
 * described in Barber, Dobkin, and Huhdanpaa, <a
 * href=http://citeseer.ist.psu.edu/barber96quickhull.html> ``The Quickhull
 * Algorithm for Convex Hulls''</a> (ACM Transactions on Mathematical Software,
 * Vol. 22, No. 4, December 1996), and has a complexity of O(n log(n)) with
 * respect to the number of points. A well-known C implementation of Quickhull
 * that works for arbitrary dimensions is provided by <a
 * href=http://www.qhull.org>qhull</a>.
 *
 * <p>A hull is constructed by providing a set of points
 * to either a constructor or a
 * {@link #build(Point3d[]) build} method. After
 * the hull is built, its vertices and faces can be retrieved
 * using {@link #getVertices()
 * getVertices} and {@link #getFaces() getFaces}.
 * A typical usage might look like this:
 * <pre>
 *   // x y z coordinates of 6 points
 *   Point3d[] points = new Point3d[] 
 *    { new Point3d (0.0,  0.0,  0.0),
 *      new Point3d (1.0,  0.5,  0.0),
 *      new Point3d (2.0,  0.0,  0.0),
 *      new Point3d (0.5,  0.5,  0.5),
 *      new Point3d (0.0,  0.0,  2.0),
 *      new Point3d (0.1,  0.2,  0.3),
 *      new Point3d (0.0,  2.0,  0.0),
 *    }
 *
 *   QuickHull3D hull = new QuickHull3D()
 *   hull.build (points)
 *
 *   System.out.println ("Vertices:")
 *   Point3d[] vertices = hull.getVertices()
 *   for (int i = 0 i < vertices.length i++)
 *    { Point3d pnt = vertices[i]
 *      System.out.println (pnt.x + " " + pnt.y + " " + pnt.z)
 *    }
 *
 *   System.out.println ("Faces:")
 *   int[][] faceIndices = hull.getFaces()
 *   for (int i = 0 i < faceIndices.length i++)
 *    { for (int k = 0 k < faceIndices[i].length k++)
 *       { System.out.print (faceIndices[i][k] + " ")
 *       }
 *      System.out.println ("")
 *    }
 * </pre>
 * As a convenience, there are also {@link #build(Double[]) build}
 * and {@link #getVertices(Double[]) getVertex} methods which
 * pass point information using an array of doubles.
 *
 * <h3><a name=distTol>Robustness</h3> Because this algorithm uses floating
 * point arithmetic, it is potentially vulnerable to errors arising from
 * numerical imprecision.  We address this problem in the same way as <a
 * href=http://www.qhull.org>qhull</a>, by merging faces whose edges are not
 * clearly convex. A face is convex if its edges are convex, and an edge is
 * convex if the centroid of each adjacent plane is clearly <i>below</i> the
 * plane of the other face. The centroid is considered below a plane if its
 * distance to the plane is less than the negative of a {@link
 * #getDistanceTolerance() distance tolerance}.  This tolerance represents the
 * smallest distance that can be reliably computed within the available numeric
 * precision. It is normally computed automatically from the point data,
 * although an application may {@link #setExplicitDistanceTolerance set this
 * tolerance explicitly}.
 *
 * <p>Numerical problems are more likely to arise in situations where data
 * points lie on or within the faces or edges of the convex hull. We have
 * tested QuickHull3D for such situations by computing the convex hull of a
 * random point set, then adding additional randomly chosen points which lie
 * very close to the hull vertices and edges, and computing the convex
 * hull again. The hull is deemed correct if {@link #check check} returns
 * <code>true</code>.  These tests have been successful for a large number of
 * trials and so we are confident that QuickHull3D is reasonably robust.
 *
 * <h3>Merged Faces</h3> The merging of faces means that the faces returned by
 * QuickHull3D may be convex polygons instead of triangles. If triangles are
 * desired, the application may {@link #triangulate triangulate} the faces, but
 * it should be noted that this may result in triangles which are very small or
 * thin and hence difficult to perform reliable convexity tests on. In other
 * words, triangulating a merged face is likely to restore the numerical
 * problems which the merging process removed. Hence is it
 * possible that, after triangulation, {@link #check check} will fail (the same
 * behavior is observed with triangulated output from <a
 * href=http://www.qhull.org>qhull</a>).
 *
 * <h3>Degenerate Input</h3>It is assumed that the input points
 * are non-degenerate in that they are not coincident, colinear, or
 * colplanar, and thus the convex hull has a non-zero volume.
 * If the input points are detected to be degenerate within
 * the {@link #getDistanceTolerance() distance tolerance}, an
 * IllegalArgumentException will be thrown.
 *
 * @author John E. Lloyd, Fall 2004 */

import Foundation

class QuickHull3D
{
    /**
     * Specifies that (on output) vertex indices for a face should be
     * listed in clockwise order.
     */
    static  let CLOCKWISE : Int = 0x1
    
    /**
     * Specifies that (on output) the vertex indices for a face should be
     * numbered starting from 1.
     */
    static  let INDEXED_FROM_ONE : Int = 0x2
    
    /**
     * Specifies that (on output) the vertex indices for a face should be
     * numbered starting from 0.
     */
    static  let INDEXED_FROM_ZERO : Int = 0x4
    
    /**
     * Specifies that (on output) the vertex indices for a face should be
     * numbered with respect to the original input points.
     */
    static  let POINT_RELATIVE : Int = 0x8
    
    /**
     * Specifies that the distance tolerance should be
     * computed automatically from the input point data.
     */
    static  let AUTOMATIC_TOLERANCE : Double = -1.0
    
    private static  let NONCONVEX_WRT_LARGER_FACE : Int = 1
    private static  let NONCONVEX : Int = 2
    
    internal var findIndex : Int = -1
    
    // estimated size of the point set
    internal var charLength : Double = 0
    
    internal var pointBuffer        = [Vertex]()
    internal var vertexPointIndices = [Int]()
    private var discardedFaces      = Face.array(3)
    
    private var maxVtxs = Vertex.array(3)
    private var minVtxs = Vertex.array(3)
    
    internal var faces      = [Face]()
    internal var horizon    = [HalfEdge]()
    
    private var newFaces    = FaceList()
    private var unclaimed   = VertexList()
    private var claimed     = VertexList()
    
    internal var numVertices    : Int = 0
    internal var numFaces       : Int = 0
    internal var numPoints      : Int = 0
    
    internal var explicitTolerance : Double = AUTOMATIC_TOLERANCE
    internal var tolerance : Double = 0
    
    
    /**
     * Precision of a Double.
     */
    static private  var DOUBLE_PREC : Double = 2.2204460492503131e-16
    
    
    /**
     * Returns the distance tolerance that was used for the most recently
     * computed hull. The distance tolerance is used to determine when
     * faces are unambiguously convex with respect to each other, and when
     * points are unambiguously above or below a face plane, in the
     * presence of <a href=#distTol>numerical imprecision</a>. Normally,
     * this tolerance is computed automatically for each set of input
     * points, but it can be set explicitly by the application.
     *
     * @return distance tolerance
     * @see QuickHull3D#setExplicitDistanceTolerance
     */
    func getDistanceTolerance() -> Double
    {
        return tolerance
    }
    
    /**
     * Sets an explicit distance tolerance for convexity tests.
     * If {@link #AUTOMATIC_TOLERANCE AUTOMATIC_TOLERANCE}
     * is specified (the default), then the tolerance will be computed
     * automatically from the point data.
     *
     * @param tol explicit tolerance
     * @see #getDistanceTolerance
     */
    func setExplicitDistanceTolerance(_ tol : Double)
    {
        explicitTolerance = tol
    }
    
    /**
     * Returns the explicit distance tolerance.
     *
     * @return explicit tolerance
     * @see #setExplicitDistanceTolerance
     */
    func getExplicitDistanceTolerance() -> Double
    {
        return explicitTolerance
    }
    
    private func addPointToFace (_ vtx : Vertex, _ face : Face)
    {
        vtx.face = face
        
        if (face.outside == nil)
        {
            claimed.add (vtx)
        }
        else
        {
            claimed.insertBefore (vtx, face.outside!)
        }
        face.outside = vtx
    }
    
    private func removePointFromFace (_ vtx : Vertex, _ face : Face)
    {
        if (vtx === face.outside)
        {
            if (vtx.next != nil && vtx.next!.face === face)
            {
                face.outside = vtx.next
            }
            else
            {
                face.outside = nil
            }
        }
        claimed.delete (vtx)
    }
    
    private func removeAllPointsFromFace (_ face : Face) -> Vertex?
    {
        if (face.outside != nil)
        {
            var end : Vertex = face.outside!
            while end.next != nil && end.next!.face === face
            {
                end = end.next!
            }
            
            claimed.delete (face.outside!, end)
            end.next = nil
            return face.outside
        }
        else
        {
            return nil
        }
    }
    
    /**
     * Creates an empty convex hull object.
     */
    init ()
    {
    }
    
    /**
     * Creates a convex hull object and initializes it to the convex hull
     * of a set of points whose coordinates are given by an
     * array of doubles.
     *
     * @param coords x, y, and z coordinates of each input
     * point. The length of this array will be three times
     * the the number of input points.
     * @throws IllegalArgumentException the number of input points is less
     * than four, or the points appear to be coincident, colinear, or
     * coplanar.
     */
    init (_ coords : [Double])
    {
        build (coords, coords.count/3)
    }
    
    /**
     * Creates a convex hull object and initializes it to the convex hull
     * of a set of points.
     *
     * @param points input points.
     * @throws IllegalArgumentException the number of input points is less
     * than four, or the points appear to be coincident, colinear, or
     * coplanar.
     */
    init (_ points : [Point3d])
    {
        build (points, points.count)
    }
    
    private func findHalfEdge (_ tail : Vertex, _ head : Vertex) -> HalfEdge?
    {
        // brute force ... OK, since setHull is not used much
        for face in faces {
            let he : HalfEdge? = face.findEdge (tail, head)
            if (he !== nil)
            {
                return he
            }
        }
        return nil
    }
    
    internal func setHull (_ coords : [Double], _ nump : Int,
                           _ faceIndices : [[Int]], _ numf : Int)
    {
        initBuffers (nump)
        setPoints (coords, nump)
        computeMaxAndMin ()
        for i in 0..<numf {
            let face = Face.create (pointBuffer, faceIndices[i])
            for he in HalfEdgeLoopIterator(start: face.he0!)
            {
                let heOpp = findHalfEdge (he.head()!, he.tail()!)
                if (heOpp != nil)
                {
                    he.setOpposite (heOpp)
                }
            }
            faces.append(face)
        }
    }
    
    private func printPoints ()
    {
        for  i in 0..<numPoints
        {
            let pnt : Point3d = pointBuffer[i].pnt
            print ("\(pnt.x , pnt.y , pnt.z)")
        }
    }
    
    /**
     * Constructs the convex hull of a set of points whose
     * coordinates are given by an array of doubles.
     *
     * @param coords x, y, and z coordinates of each input
     * point. The length of this array will be three times
     * the number of input points.
     * @throws IllegalArgumentException the number of input points is less
     * than four, or the points appear to be coincident, colinear, or
     * coplanar.
     */
    func build (_ coords : [Double])
    {
        build (coords, coords.count/3)
    }
    
    /**
     * Constructs the convex hull of a set of points whose
     * coordinates are given by an array of doubles.
     *
     * @param coords x, y, and z coordinates of each input
     * point. The length of this array must be at least three times
     * <code>nump</code>.
     * @param nump number of input points
     * @throws IllegalArgumentException the number of input points is less
     * than four or greater than 1/3 the length of <code>coords</code>,
     * or the points appear to be coincident, colinear, or
     * coplanar.
     */
    func build (_ coords : [Double], _ nump : Int)
    {
        assert(nump >= 4, "Less than four input points specified")
        assert(coords.count/3 >= nump, "Coordinate array too small for specified number of points")
        
        initBuffers (nump)
        setPoints (coords, nump)
        buildHull ()
    }
    
    /**
     * Constructs the convex hull of a set of points.
     *
     * @param points input points
     * @throws IllegalArgumentException the number of input points is less
     * than four, or the points appear to be coincident, colinear, or
     * coplanar.
     */
    func build (points : [Point3d])
    {
        build (points, points.count)
    }
    
    /**
     * Constructs the convex hull of a set of points.
     *
     * @param points input points
     * @param nump number of input points
     * @throws IllegalArgumentException the number of input points is less
     * than four or greater then the length of <code>points</code>, or the
     * points appear to be coincident, colinear, or coplanar.
     */
    func build (_ points : [Point3d], _ nump : Int)
    {
        assert(nump >= 4, "Less than four input points specified")
        assert(points.count >= nump, "Point array too small for specified number of points")
        
        initBuffers (nump)
        setPoints (points, nump)
        buildHull ()
    }
    
    /**
     * Triangulates any non-triangular hull faces. In some cases, due to
     * precision issues, the resulting triangles may be very thin or small,
     * and hence appear to be non-convex (this same limitation is present
     * in <a href=http://www.qhull.org>qhull</a>).
     */
    func triangulate ()
    {
        let minArea : Double = 1000*charLength*QuickHull3D.DOUBLE_PREC
        newFaces.clear()
        for face in faces {
            if (face.mark == Face.VISIBLE)
            {
                face.triangulate (newFaces, minArea)
            }
        }
        
        for face in FaceIterator(newFaces.first()!) {
            faces.append(face)
        }
    }
    
    
    
    
    internal func initBuffers (_ nump : Int)
    {
        if (pointBuffer.count < nump)
        {
            vertexPointIndices = Array<Int>(repeating: 0, count: nump)
            pointBuffer += Vertex.array(nump - pointBuffer.count)
        }
        
        faces.removeAll()
        claimed.clear()
        numFaces = 0
        numPoints = nump
    }
    
    internal func setPoints (_ coords : [Double], _ nump : Int)
    {
        for  i in 0..<nump
        {
            let vtx = pointBuffer[i]
            vtx.pnt.set (coords[i*3+0], coords[i*3+1], coords[i*3+2])
            vtx.index = i
        }
    }
    
    internal func setPoints (_ pnts : [Point3d], _ nump : Int)
    {
        for  i in 0..<nump {
            pointBuffer[i].pnt.set (pnts[i])
            pointBuffer[i].index = i
        }
    }
    
    internal func computeMaxAndMin ()
    {
        let max = Vector3d()
        let min = Vector3d()
        
        for  i in 0..<3 {
            maxVtxs[i] = pointBuffer[0]
            minVtxs[i] = pointBuffer[0]
        }
        max.set (pointBuffer[0].pnt)
        min.set (pointBuffer[0].pnt)
        
        for i in 1..<numPoints
        { let pnt : Point3d = pointBuffer[i].pnt
            if (pnt.x > max.x)
            { max.x = pnt.x
                maxVtxs[0] = pointBuffer[i]
            }
            else if (pnt.x < min.x)
            { min.x = pnt.x
                minVtxs[0] = pointBuffer[i]
            }
            if (pnt.y > max.y)
            { max.y = pnt.y
                maxVtxs[1] = pointBuffer[i]
            }
            else if (pnt.y < min.y)
            { min.y = pnt.y
                minVtxs[1] = pointBuffer[i]
            }
            if (pnt.z > max.z)
            { max.z = pnt.z
                maxVtxs[2] = pointBuffer[i]
            }
            else if (pnt.z < min.z)
            { min.z = pnt.z
                maxVtxs[2] = pointBuffer[i]
            }
        }
        
        // this epsilon formula comes from QuickHull, and I'm
        // not about to quibble.
        charLength = Double.maximum(max.x-min.x, max.y-min.y)
        charLength = Double.maximum(max.z-min.z, charLength)
        if (explicitTolerance == QuickHull3D.AUTOMATIC_TOLERANCE)
        {
            tolerance =
            3.0 * QuickHull3D.DOUBLE_PREC *
            ( Double.maximum( abs(max.x),abs(min.x)) +
                Double.maximum(abs(max.y),abs(min.y))  +
                Double.maximum(abs(max.z),abs(min.z)) )
        }
        else
        {
            tolerance = explicitTolerance
        }
    }
    
    /**
     * Creates the initial simplex from which the hull will be built.
     */
    internal func createInitialSimplex ()
    {
        var max : Double = 0
        var imax : Int = 0
        
        for i in 0..<3 {
            let diff : Double = maxVtxs[i].pnt[i] - minVtxs[i].pnt[i]
            if (diff > max)
            {
                max = diff
                imax = i
            }
        }
        
        assert( !(max <= tolerance), "Input points appear to be coincident")
        
        var vtx : [Vertex] = [Vertex(),Vertex(),Vertex(), Vertex()]
        // set first two vertices to be those with the greatest
        // one dimensional separation
        
        vtx[0] = maxVtxs[imax]
        vtx[1] = minVtxs[imax]
        
        // set third vertex to be the vertex farthest from
        // the line between vtx0 and vtx1
        let u01 : Vector3d = Vector3d()
        let diff02 : Vector3d = Vector3d()
        let nrml : Vector3d = Vector3d()
        let xprod : Vector3d = Vector3d()
        var maxSqr : Double = 0
        u01.sub (vtx[1].pnt, vtx[0].pnt)
        u01.normalize()
        
        for i in 0..<numPoints {
            diff02.sub (pointBuffer[i].pnt, vtx[0].pnt)
            xprod.cross (u01, diff02)
            let lenSqr : Double = xprod.normSquared()
            if (lenSqr > maxSqr &&
                pointBuffer[i] !== vtx[0] &&  // paranoid
                pointBuffer[i] !== vtx[1])
            {
                maxSqr = lenSqr
                vtx[2] = pointBuffer[i]
                nrml.set (xprod)
            }
        }
        
        assert( !(sqrt(maxSqr) <= 100*tolerance), "Input points appear to be colinear")
        
        nrml.normalize()
        
        
        var maxDist : Double = 0
        let d0 : Double = vtx[2].pnt.dot (nrml)
        for i in 0..<numPoints {
            let dist : Double = abs (pointBuffer[i].pnt.dot(nrml) - d0)
            if (dist > maxDist &&
                pointBuffer[i] !== vtx[0] &&  // paranoid
                pointBuffer[i] !== vtx[1] &&
                pointBuffer[i] !== vtx[2])
            {
                maxDist = dist
                vtx[3] = pointBuffer[i]
            }
        }
        
        assert( !(abs(maxDist) <= 100*tolerance), "Input points appear to be coplanar")
        
        var tris : [Face] = [Face(), Face(), Face(), Face()]
        
        if (vtx[3].pnt.dot (nrml) - d0 < 0)
        {
            tris[0] = Face.createTriangle (vtx[0], vtx[1], vtx[2])
            tris[1] = Face.createTriangle (vtx[3], vtx[1], vtx[0])
            tris[2] = Face.createTriangle (vtx[3], vtx[2], vtx[1])
            tris[3] = Face.createTriangle (vtx[3], vtx[0], vtx[2])
            
            for i in 0..<3
            {
                let k : Int = (i+1)%3
                tris[i+1].getEdge(1)!.setOpposite (tris[k+1].getEdge(0))
                tris[i+1].getEdge(2)!.setOpposite (tris[0].getEdge(k))
            }
        }
        else
        {
            tris[0] = Face.createTriangle (vtx[0], vtx[2], vtx[1])
            tris[1] = Face.createTriangle (vtx[3], vtx[0], vtx[1])
            tris[2] = Face.createTriangle (vtx[3], vtx[1], vtx[2])
            tris[3] = Face.createTriangle (vtx[3], vtx[2], vtx[0])
            
            for i in 0..<3
            {
                let k : Int = (i+1)%3
                tris[i+1].getEdge(0)!.setOpposite (tris[k+1].getEdge(1))
                tris[i+1].getEdge(2)!.setOpposite (tris[0].getEdge((3-i)%3))
            }
        }
        
        
        for i in 0..<4
        {
            faces.append(tris[i])
        }
        
        for i in 0..<numPoints
        {
            let v : Vertex = pointBuffer[i]
            
            if (v === vtx[0] || v === vtx[1] || v === vtx[2] || v === vtx[3])
            { continue
            }
            
            maxDist = tolerance
            var maxFace : Face? = nil
            for k in 0..<4
            {
                let dist : Double = tris[k].distanceToPlane (v.pnt)
                if (dist > maxDist)
                {
                    maxFace = tris[k]
                    maxDist = dist
                }
            }
            if (maxFace != nil)
            {
                addPointToFace (v, maxFace!)
            }
        }
    }
    
    /**
     * Returns the number of vertices in this hull.
     *
     * @return number of vertices
     */
    func getNumVertices() -> Int
    {
        return numVertices
    }
    
    /**
     * Returns the vertex points in this hull.
     *
     * @return array of vertex points
     * @see QuickHull3D#getVertices(Double[])
     * @see QuickHull3D#getFaces()
     */
    func getVertices() -> [Point3d]
    {
        var vtxs = [Point3d]()
        for i in 0..<numVertices
        {
            vtxs.append( pointBuffer[vertexPointIndices[i]].pnt )
        }
        return vtxs
    }
    
    /**
     * Returns the coordinates of the vertex points of this hull.
     *
     * @param coords returns the x, y, z coordinates of each vertex.
     * This length of this array must be at least three times
     * the number of vertices.
     * @return the number of vertices
     * @see QuickHull3D#getVertices()
     * @see QuickHull3D#getFaces()
     */
    func getVertices(_ coords : inout [Double]) -> Int
    {
        for i in 0..<numVertices
        {
            let pnt : Point3d = pointBuffer[vertexPointIndices[i]].pnt
            coords[i*3+0] = pnt.x
            coords[i*3+1] = pnt.y
            coords[i*3+2] = pnt.z
        }
        return numVertices
    }
    
    /**
     * Returns an array specifing the index of each hull vertex
     * with respect to the original input points.
     *
     * @return vertex indices with respect to the original points
     */
    func getVertexPointIndices() -> [Int]
    {
        var indices = [Int]()
        for i in 0..<numVertices
        {
            indices.append( vertexPointIndices[i] )
        }
        return indices
    }
    
    /**
     * Returns the number of faces in this hull.
     *
     * @return number of faces
     */
    func getNumFaces() -> Int
    {
        return faces.count
    }
    
    /**
     * Returns the faces associated with this hull.
     *
     * <p>Each face is represented by an integer array which gives the
     * indices of the vertices. These indices are numbered
     * relative to the
     * hull vertices, are zero-based,
     * and are arranged counter-clockwise. More control
     * over the index format can be obtained using
     * {@link #getFaces(int) getFaces(indexFlags)}.
     *
     * @return array of integer arrays, giving the vertex
     * indices for each face.
     * @see QuickHull3D#getVertices()
     * @see QuickHull3D#getFaces(int)
     */
    func getFaces () -> [[Int]]
    {
        return getFaces(0)
    }
    
    /**
     * Returns the faces associated with this hull.
     *
     * <p>Each face is represented by an integer array which gives the
     * indices of the vertices. By default, these indices are numbered with
     * respect to the hull vertices (as opposed to the input points), are
     * zero-based, and are arranged counter-clockwise. However, this
     * can be changed by setting {@link #POINT_RELATIVE
     * POINT_RELATIVE}, {@link #INDEXED_FROM_ONE INDEXED_FROM_ONE}, or
     * {@link #CLOCKWISE CLOCKWISE} in the indexFlags parameter.
     *
     * @param indexFlags specifies index characteristics (0 results
     * in the default)
     * @return array of integer arrays, giving the vertex
     * indices for each face.
     * @see QuickHull3D#getVertices()
     */
    func getFaces (_ indexFlags : Int) -> [[Int]]
    {
        func getFaceIndices ( _ face : Face, _ flags : Int) -> [Int]
        {
            var faceIx = [Int]()
            for hedge in HalfEdgeLoopIterator(start: face.he0!) {
                faceIx.append(hedge.head()!.index)
            }
            return faceIx
        }
        
        var allFaces = [[Int]]()
        for face in faces
        {
            allFaces.append( getFaceIndices (face, indexFlags) )
        }
        return allFaces
    }
    
    
    internal func resolveUnclaimedPoints (_ newFaces : FaceList)
    {
        for vtx in VertexIterator(unclaimed.first())
        {
            var maxDist : Double = tolerance
            var maxFace : Face? = nil
            
            for  newFace in FaceIterator ( newFaces.first()! )
            {
                if (newFace.mark == Face.VISIBLE)
                {
                    let dist : Double = newFace.distanceToPlane(vtx.pnt)
                    if (dist > maxDist)
                    {
                        maxDist = dist
                        maxFace = newFace
                    }
                    if (maxDist > 1000*tolerance)
                    { break
                    }
                }
            }
            
            if (maxFace != nil)
            {
                addPointToFace (vtx, maxFace!)
            }
        }
    }
    
    internal func deleteFacePoints (_ face : Face, _ absorbingFace : Face?)
    {
        let faceVtxs : Vertex? = removeAllPointsFromFace (face)
        if (faceVtxs != nil)
        {
            if (absorbingFace == nil)
            {
                unclaimed.addAll (faceVtxs!)
            }
            else
            {
                for vtx in VertexIterator(faceVtxs) {
                    if (absorbingFace!.distanceToPlane (vtx.pnt) > tolerance)
                    {
                        addPointToFace (vtx, absorbingFace!)
                    }
                    else
                    {
                        unclaimed.add (vtx)
                    }
                }
            }
        }
    }
    
    internal func oppFaceDistance (_ he : HalfEdge) -> Double
    {
        return he.face!.distanceToPlane (he.opposite!.face!.getCentroid()!)
    }
    
    private func doAdjacentMerge (_ face : Face, _ mergeType : Int) -> Bool
    {
        var convex : Bool = true
        
        for hedge in HalfEdgeLoopIterator(start: face.he0!)
        {
            let oppFace : Face = hedge.oppositeFace()!
            var merge : Bool = false
            var dist1 : Double
            
            if (mergeType == QuickHull3D.NONCONVEX)
            { // then merge faces if they are definitively non-convex
                if (oppFaceDistance (hedge) > -tolerance ||
                    oppFaceDistance (hedge.opposite!) > -tolerance)
                {
                    merge = true
                }
            }
            else // mergeType == NONCONVEX_WRT_LARGER_FACE
            { // merge faces if they are parallel or non-convex
                // wrt to the larger face otherwise, just mark
                // the face non-convex for the second pass.
                if (face.area > oppFace.area)
                {
                    dist1 = oppFaceDistance (hedge)
                    if (dist1 > -tolerance)
                    {
                        merge = true
                    }
                    else if (oppFaceDistance (hedge.opposite!) > -tolerance)
                    {
                        convex = false
                    }
                }
                else {
                    if (oppFaceDistance (hedge.opposite!) > -tolerance)
                    {
                        merge = true
                    }
                    else {
                        if (oppFaceDistance (hedge) > -tolerance)
                        {
                            convex = false
                        }
                    }
                }
            }
            
            if (merge)
            {
                let numd : Int = face.mergeAdjacentFace (hedge, &discardedFaces)
                for i in 0..<numd
                {
                    deleteFacePoints (discardedFaces[i], face)
                }
                return true
            }
        }
        if (!convex)
        { face.mark = Face.NON_CONVEX
        }
        return false
    }
    
    internal func calculateHorizon (_ eyePnt : Point3d, _ _edge0 : HalfEdge?, _ face : Face, _ horizon : inout [HalfEdge])
    {
        deleteFacePoints (face, nil)
        face.mark = Face.DELETED
        
        var edge : HalfEdge?, edge0 = _edge0
        if (edge0 == nil)
        {
            edge0 = face.getEdge(0)
            edge = edge0!
        }
        else
        {
            edge = edge0!.getNext()
        }
        
        for e in HalfEdgeRangeIterator(from: edge!, to: edge0!)
        {
            let oppFace : Face = e.oppositeFace()!
            if (oppFace.mark == Face.VISIBLE)
            {
                if (oppFace.distanceToPlane (eyePnt) > tolerance)
                {
                    calculateHorizon (eyePnt, e.getOpposite(), oppFace, &horizon)
                }
                else
                {
                    horizon.append (e)
                }
            }
        }
    }
    
    private func addAdjoiningFace (_ eyeVtx : Vertex, _ he : HalfEdge) -> HalfEdge?
    {
        let face : Face = Face.createTriangle ( eyeVtx, he.tail()!, he.head()! )
        
        faces.append (face)
        face.getEdge(-1)!.setOpposite(he.getOpposite())
        
        return face.getEdge(0)
    }
    
    internal func addNewFaces (_ newFaces : FaceList, _ eyeVtx : Vertex, _ horizon : [HalfEdge])
    {
        newFaces.clear()
        
        var hedgeSidePrev : HalfEdge? = nil
        var hedgeSideBegin : HalfEdge? = nil
        
        for horizonHe in horizon
        {
            let hedgeSide : HalfEdge? = addAdjoiningFace (eyeVtx, horizonHe)
            if (hedgeSidePrev != nil)
            {
                hedgeSide!.next!.setOpposite (hedgeSidePrev)
            }
            else
            {
                hedgeSideBegin = hedgeSide
            }
            newFaces.add (hedgeSide!.getFace()!)
            hedgeSidePrev = hedgeSide
        }
        hedgeSideBegin!.next!.setOpposite (hedgeSidePrev)
    }
    
    internal func nextPointToAdd() -> Vertex?
    {
        if (!claimed.isEmpty())
        {
            let eyeFace : Face = claimed.first()!.face!
            var eyeVtx : Vertex? = nil
            var maxDist : Double = 0
            
            for vtx in VertexIterator(eyeFace.outside)
            {
                let dist : Double = eyeFace.distanceToPlane(vtx.pnt)
                if (dist > maxDist)
                {
                    maxDist = dist
                    eyeVtx = vtx
                }
                if (vtx.face === eyeFace) { break }
            }
            return eyeVtx
        }
        else {
            return nil
        }
    }
    
    
    internal func addPointToHull(_ eyeVtx : Vertex)
    {
        horizon.removeAll()
        unclaimed.clear()
        
        removePointFromFace (eyeVtx, eyeVtx.face!)
        calculateHorizon (eyeVtx.pnt, nil, eyeVtx.face!, &horizon)
        newFaces.clear()
        addNewFaces (newFaces, eyeVtx, horizon)
        
        // first merge pass ... merge faces which are non-convex
        // as determined by the larger face
        
        for face in FaceIterator( newFaces.first()!) {
            if (face.mark == Face.VISIBLE) {
                while doAdjacentMerge(face, QuickHull3D.NONCONVEX_WRT_LARGER_FACE) {}
            }
        }
        
        // second merge pass ... merge faces which are non-convex
        // wrt either face
        for face in FaceIterator( newFaces.first()!) {
            if (face.mark == Face.NON_CONVEX) {
                face.mark = Face.VISIBLE
                while doAdjacentMerge(face, QuickHull3D.NONCONVEX) {}
            }
        }
        resolveUnclaimedPoints(newFaces)
    }
    
    internal func buildHull ()
    {
        computeMaxAndMin ()
        createInitialSimplex ()
        
        for eyeVtx in FuncIterator<Vertex>(funcCall : nextPointToAdd) {
            addPointToHull (eyeVtx)
        }
        
        reindexFacesAndVertices()
    }
    
    
    private func markFaceVertices (_ face : Face, _ mark : Int)
    {
        for he in HalfEdgeLoopIterator(start: face.getFirstEdge())
        {
            he.head()!.index = mark
        }
    }
    
    internal func reindexFacesAndVertices()
    {
        for i in 0..<numPoints {
            pointBuffer[i].index = -1
        }
        
        // keep visible faces
        faces = faces.filter({(face: Face) -> Bool in return face.mark == Face.VISIBLE})
        
        // and mark active vertices
        for face in faces  {
            markFaceVertices (face, 0)
        }
        numFaces=faces.count
        
        // reindex vertices
        numVertices = 0
        for  i in 0..<numPoints
        {
            let vtx : Vertex = pointBuffer[i]
            if (vtx.index == 0)
            {
                vertexPointIndices[numVertices] = i
                vtx.index = numVertices
                numVertices+=1
            }
        }
    }
    
}

