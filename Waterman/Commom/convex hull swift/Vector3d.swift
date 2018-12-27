/**
 * A three-element vector. This class is actually a reduced version of the
 * Vector3d class contained in the author's matlib package (which was partly
 * inspired by javax.vecmath). Only a mininal number of methods
 * which are relevant to convex hull generation are supplied here.
 *
 * @author John E. Lloyd, Fall 2004
 */
import Foundation

class Vector3d
{
    /**
     * Precision of a Double.
     */
    let DOUBLE_PREC : Double = 2.2204460492503131e-16
    
    /**
     * First element
     */
    var x : Double=0
    
    /**
     * Second element
     */
    var y: Double=0 ;
    
    /**
     * Third element
     */
    var z : Double=0
    
    /**
     * Creates a 3-vector and initializes its elements to 0.
     */
    init ()
    {
    }
    
    /**
     * Creates a 3-vector by copying an existing one.
     *
     * @param v vector to be copied
     */
    init (_ v : Vector3d)
    {
        set (v);
    }
    
    /**
     * Creates a 3-vector with the supplied element values.
     *
     * @param x first element
     * @param y second element
     * @param z third element
     */
    init (_ x : Double, _ y : Double, _ z : Double)
    {
        set (x, y, z);
    }
    
    /**
     * Gets a single element of this vector.
     * Elements 0, 1, and 2 correspond to x, y, and z.
     *
     * @param i element index
     * @return element value throws ArrayIndexOutOfBoundsException
     * if i is not in the range 0 to 2.
     */
    func get (_ i : Int) -> Double
    {
        switch (i)
        { case 0:
            return x
        case 1:
            return y
        case 2:
            return z
        default:
            return 0
        }
    }
    
    /**
     * Sets a single element of this vector.
     * Elements 0, 1, and 2 correspond to x, y, and z.
     *
     * @param i element index
     * @param value element value
     * @return element value throws ArrayIndexOutOfBoundsException
     * if i is not in the range 0 to 2.
     */
    func set (_ i : Int, _ value : Double)
    {
        switch (i)
        { case 0:
            x = value
        case 1:
            y = value
        case 2:
            z = value
        default:
            return
        }
    }
    
    subscript(i : Int) -> Double {
        get {
            switch (i) {
        case 0:   return x
        case 1:   return y
        case 2:   return z
        default:  return 0
            }
        }
        set {
            switch (i) {
        case 0:   x=newValue
        case 1:   y=newValue
        case 2:   z=newValue
        default: ()
            }
        }
    }
    
    /**
     * Sets the values of this vector to those of v1.
     *
     * @param v1 vector whose values are copied
     */
    func set (_ v1 : Vector3d)
    {
        x = v1.x
        y = v1.y
        z = v1.z
    }
    
    /**
     * Adds vector v1 to v2 and places the result in this vector.
     *
     * @param v1 left-hand vector
     * @param v2 right-hand vector
     */
    func add (_ v1 : Vector3d, _ v2 : Vector3d)
    {
        x = v1.x + v2.x
        y = v1.y + v2.y
        z = v1.z + v2.z
    }
    
    /**
     * Adds this vector to v1 and places the result in this vector.
     *
     * @param v1 right-hand vector
     */
    func add (_ v1 : Vector3d)
    {
        x += v1.x
        y += v1.y
        z += v1.z
    }
    
    
    /**
     * Subtracts vector v1 from v2 and places the result in this vector.
     *
     * @param v1 left-hand vector
     * @param v2 right-hand vector
     */
    func sub (_ v1 : Vector3d, _ v2 : Vector3d)
    {
        x = v1.x - v2.x
        y = v1.y - v2.y
        z = v1.z - v2.z
    }
    
    /**
     * Subtracts v1 from this vector and places the result in this vector.
     *
     * @param v1 right-hand vector
     */
    func sub (_ v1 : Vector3d)
    {
        x -= v1.x
        y -= v1.y
        z -= v1.z
    }
    
    /**
     * Scales the elements of this vector by <code>s</code>.
     *
     * @param s scaling factor
     */
    func scale (_ s : Double)
    {
        x = s*x
        y = s*y
        z = s*z
        
    }
    func scaleInv(_ s : Double) -> Vector3d {
        self.scale(1/s)
        return self
    }
    /**
     * Scales the elements of vector v1 by <code>s</code> and places
     * the results in this vector.
     *
     * @param s scaling factor
     * @param v1 vector to be scaled
     */
    func scale (_ s : Double, _ v1 : Vector3d)
    {
        x = s*v1.x
        y = s*v1.y
        z = s*v1.z
    }
    
    /**
     * Returns the 2 norm of this vector. This is the square root of the
     * sum of the squares of the elements.
     *
     * @return vector 2 norm
     */
    func norm() -> Double
    {
        return sqrt(x*x + y*y + z*z);
    }
    
    /**
     * Returns the square of the 2 norm of this vector. This
     * is the sum of the squares of the elements.
     *
     * @return square of the 2 norm
     */
    func normSquared() -> Double
    {
        return x*x + y*y + z*z
    }
    
    /**
     * Returns the Euclidean distance between this vector and vector v.
     *
     * @return distance between this vector and v
     */
    func distance(_ v : Vector3d) -> Double
    {
        let dx : Double = x - v.x
        let dy : Double = y - v.y
        let dz : Double = z - v.z
        
        return sqrt (dx*dx + dy*dy + dz*dz);
    }
    
    /**
     * Returns the squared of the Euclidean distance between this vector
     * and vector v.
     *
     * @return squared distance between this vector and v
     */
    func distanceSquared(_ v : Vector3d) -> Double
    {
        let dx : Double = x - v.x
        let dy : Double = y - v.y
        let dz : Double = z - v.z
        
        return (dx*dx + dy*dy + dz*dz);
    }
    
    /**
     * Returns the dot product of this vector and v1.
     *
     * @param v1 right-hand vector
     * @return dot product
     */
    func dot (_ v1 : Vector3d) -> Double
    {
        return x*v1.x + y*v1.y + z*v1.z
    }
    
    /**
     * Normalizes this vector in place.
     */
    func normalize()
    {
        let lenSqr : Double = x*x + y*y + z*z
        let err : Double = lenSqr - 1
        if (err > (2*DOUBLE_PREC) ||
            err < -(2*DOUBLE_PREC))
        { let len : Double = sqrt(lenSqr);
            x /= len
            y /= len
            z /= len
        }
    }
    
    /**
     * Sets the elements of this vector to zero.
     */
    func setZero()
    {
        x = 0
        y = 0
        z = 0
    }
    
    /**
     * Sets the elements of this vector to the prescribed values.
     *
     * @param x value for first element
     * @param y value for second element
     * @param z value for third element
     */
    func set (_ x : Double, _ y : Double, _ z : Double)
    {
        self.x = x
        self.y = y
        self.z = z
    }
    
    /**
     * Computes the cross product of v1 and v2 and places the result
     * in this vector.
     *
     * @param v1 left-hand vector
     * @param v2 right-hand vector
     */
    func cross (_ v1 : Vector3d, _ v2 : Vector3d)
    {
        let tmpx : Double = v1.y*v2.z - v1.z*v2.y,
        tmpy : Double = v1.z*v2.x - v1.x*v2.z,
        tmpz : Double = v1.x*v2.y - v1.y*v2.x
        
        x = tmpx
        y = tmpy
        z = tmpz
    }
    
    /**
     * Sets the elements of this vector to uniformly distributed
     * random values in a specified range, using a supplied
     * random number generator.
     *
     * @param lower lower random value (inclusive)
     * @param upper upper random value (exclusive)
     * @param generator random number generator
     */
    internal func setRandom (_ lower : Double, _ upper : Double)
    {
        let range : Double = upper-lower
        
        x = Double.random(in: 0.0..<1.0) * range + lower
        y = Double.random(in: 0.0..<1.0) * range + lower
        z = Double.random(in: 0.0..<1.0) * range + lower
    }
    
    /**
     * Returns a string representation of this vector, consisting
     * of the x, y, and z coordinates.
     *
     * @return string representation
     */
    func toString() -> String
    {
        return "\(x,y,z)"
    }
    
    /**
     * Returns min & max value of x,y,z coords
     */
    func maxValue() -> Double {
        return max(x, max(y,z))
    }
    func minValue() -> Double {
        return min(x, min(y,z))
    }
    
    // generate multiple instances of Vector3d
    static func array(_ n : Int) -> [Vector3d] {
        var v = [Vector3d]()
        for _ in 0..<n {
            v.append(Vector3d())
        }
        return v
    }
    
}


extension Vector3d {
    static func += ( left: inout Vector3d, right: Vector3d) {
        left.add(right)
    }
}
