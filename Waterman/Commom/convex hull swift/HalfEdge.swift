// package com.vs
/*
 * Represents the half-edges that surround each
 * face in a counter-clockwise direction.
 */
class HalfEdge
{
    /**
     * The vertex associated with the head of this half-edge.
     */
    var vertex : Vertex? = nil
    
    /**
     * Triangular face associated with this half-edge.
     */
    var face : Face? = nil
    
    /**
     * Next half-edge in the triangle.
     */
    var next : HalfEdge? = nil
    
    /**
     * Previous half-edge in the triangle.
     */
    var prev : HalfEdge? = nil
    
    /**
     * Half-edge associated with the opposite triangle
     * adjacent to this edge.
     */
    var opposite : HalfEdge? = nil
    
    /**
     * Constructs a HalfEdge with head vertex <code>v</code> and
     * left-hand triangular face <code>f</code>.
     *
     * @param v head vertex
     * @param f left-hand triangular face
     */
    init (_ v : Vertex, _ f : Face)
    {
        vertex = v
        face = f
    }
    
//    init ?()
//    {
//    }
    
    /**
     * Sets the value of the next edge adjacent
     * (counter-clockwise) to this one within the triangle.
     *
     * @param edge next adjacent edge */
    func setNext (_ edge : HalfEdge?)
    {
        next = edge
    }
    
    /**
     * Gets the value of the next edge adjacent
     * (counter-clockwise) to this one within the triangle.
     *
     * @return next adjacent edge */
    func getNext() -> HalfEdge?
    {
        return next
    }
    
    /**
     * Sets the value of the previous edge adjacent (clockwise) to
     * this one within the triangle.
     *
     * @param edge previous adjacent edge */
    func setPrev (_ edge : HalfEdge?)
    {
        prev = edge
    }
    
    /**
     * Gets the value of the previous edge adjacent (clockwise) to
     * this one within the triangle.
     *
     * @return previous adjacent edge
     */
    func getPrev() -> HalfEdge?
    {
        return prev
    }
    
    /**
     * Returns the triangular face located to the left of this
     * half-edge.
     *
     * @return left-hand triangular face
     */
    func getFace() -> Face?
    {
        return face
    }
    
    /**
     * Returns the half-edge opposite to this half-edge.
     *
     * @return opposite half-edge
     */
    func getOpposite() -> HalfEdge?
    {
        return opposite
    }
    
    /**
     * Sets the half-edge opposite to this half-edge.
     *
     * @param edge opposite half-edge
     */
    func setOpposite (_ edge : HalfEdge?)
    {
        opposite = edge
        edge!.opposite = self
    }
    
    /**
     * Returns the head vertex associated with this half-edge.
     *
     * @return head vertex
     */
    func head() -> Vertex?
    {
        return vertex
    }
    
    /**
     * Returns the tail vertex associated with this half-edge.
     *
     * @return tail vertex
     */
    func tail() -> Vertex?
    {
        return (prev != nil ? prev!.vertex : nil)
    }
    
    /**
     * Returns the opposite triangular face associated with this
     * half-edge.
     *
     * @return opposite triangular face
     */
    func oppositeFace() -> Face?
    {
        return (opposite != nil ? opposite!.face : nil)
    }
    
    /**
     * Produces a string identifying this half-edge by the point
     * index values of its tail and head vertices.
     *
     * @return identifying string
     */
    func getVertexString() -> String
    {
        if (tail() != nil)
        { return "\(tail()!.index, head()!.index)"
        }
        else
        { return "?-\(head()!.index)"
        }
    }
    
    /**
     * Returns the length of this half-edge.
     *
     * @return half-edge length
     */
    func length() -> Double
    {
        if (tail() != nil)
        { return head()!.pnt.distance(tail()!.pnt)
        }
        else
        { return -1
        }
    }
    
    /**
     * Returns the length squared of this half-edge.
     *
     * @return half-edge length squared
     */
    func lengthSquared() -> Double
    {
        if (tail() != nil)
        { return head()!.pnt.distanceSquared(tail()!.pnt)
        }
        else
        { return -1
        }
    }
    
}

