// package com.vs;

/**
 * A three-element spatial point.
 *
 * The only difference between a point and a vector is in the
 * the way it is transformed by an affine transformation. Since
 * the transform method is not included in this reduced
 * implementation for QuickHull3D, the difference is
 * purely academic.
 *
 * @author John E. Lloyd, Fall 2004
 */
class Point3d  :  Vector3d
{
    /**
     * Creates a Point3d and initializes it to zero.
     */
    override init ()
    {
        super.init()
    }
    
    /**
     * Creates a Point3d by copying a vector
     *
     * @param v vector to be copied
     */
    override init (_ v : Vector3d)
    {
        super.init(v)
    }
    
    /**
     * Creates a Point3d with the supplied element values.
     *
     * @param x first element
     * @param y second element
     * @param z third element
     */
    override init (_ x : Double, _ y : Double, _ z : Double)
    {
        super.init (x, y, z);
    }
}

