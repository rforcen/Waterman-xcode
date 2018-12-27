/**
 * Represents vertices of the hull, as well as the points from
 * which it is formed.
 *
 */
class Vertex
{
    /**
     * Spatial point associated with this vertex.
     */
    var pnt = Point3d()
    
    /**
     * Back index into an array.
     */
    var index : Int = 0
    
    /**
     * List forward link.
     */
    var prev : Vertex? = nil
    
    /**
     * List backward link.
     */
    var next : Vertex? = nil
    
    /**
     * Current face that this vertex is outside of.
     */
    var face : Face? = nil
    
    /**
     * Constructs a vertex and sets its coordinates to 0.
     */
    init()
    {
    }
    
    /**
     * Constructs a vertex with the specified coordinates
     * and index.
     */
    init (_ x : Double, _ y : Double, _ z : Double, _ idx : Int)
    {
        pnt = Point3d(x, y, z)
        index = idx
    }
    
    // generate multiple instances of Vector3d
    static func array(_ n : Int) -> [Vertex] {
        var v = [Vertex]()
        for _ in 0..<n {
            v.append(Vertex())
        }
        return v
    }
}

