// package com.vs
/**
 * Maintains a single-linked list of faces for use by QuickHull3D
 */
class FaceList
{
    private var head : Face? = nil
    private var tail : Face? = nil
    
    /**
     * Clears this list.
     */
    public func clear()
    {
        head = nil
        tail = nil
    }
    
    /**
     * Adds a vertex to the end of this list.
     */
    public func add (_ vtx : Face)
    {
        if (head === nil) {
            head = vtx
        }
        else {
            tail!.next = vtx
        }
        vtx.next = nil
        tail = vtx
    }
    
    public func first() -> Face?
    {
        return head
    }
    
    /**
     * Returns true if this list is empty.
     */
    public func isEmpty() -> Bool
    {
        return head == nil
    }
}

