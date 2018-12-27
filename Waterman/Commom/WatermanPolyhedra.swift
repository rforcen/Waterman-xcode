import SceneKit

class WatermanPolyhedra {

    var vertices = [[SCNVector3]]()
    
    init(_ radius : Double) {
        let pts=genCoords(radius: radius)
        vertices = convexHull(coords: pts)
    }
    
    func genCoords(radius : Double) -> [Point3d] {
        var x : Double, y : Double, z : Double,
        xra : Double, xrb : Double, yra : Double, yrb : Double, zra : Double, zrb : Double, R : Double, Ry : Double, s : Double, radius2 : Double
        var coords = [Point3d]()
        
        
        coords = [Point3d]() 
        
        s = radius
        radius2 = radius * radius
        xra = ceil(-s)
        xrb = floor(s)
        
        x = xra
        while x <= xrb
        {
            R = radius2 - x * x
            if (R < 0) {
                x+=1
                continue
            }
            
            s = sqrt(R)
            yra = ceil(-s)
            yrb = floor(s)
            
            y = yra
            while y <= yrb  {
                Ry = R - y * y
                if (Ry < 0) {
                    y+=1
                    continue
                } //case Ry < 0
                if (Ry == 0) { //case Ry=0
                    if (remainder(x + y, 2) != 0) {
                        y+=1
                        continue
                    }
                    else {
                        zra = 0.0
                        zrb = 0.0
                    }
                } else { // case Ry > 0
                    s = sqrt(Ry)
                    zra = ceil(-s)
                    zrb = floor(s)
                    if (remainder(x + y , 2) == 0) {// (x+y)mod2=0
                        if (remainder(zra , 2) != 0) {
                            if (zra <= 0) { zra = zra + 1 }
                            else { zra = zra - 1 }
                        }
                    } else { // (x+y) mod 2 <> 0
                        if (remainder(zra , 2) == 0) {
                            if (zra <= 0) { zra = zra + 1 }
                            else { zra = zra - 1 }
                        }
                    }
                }
                
                z = zra
                while z <= zrb { // save vertex x,y,z
                    coords.append(Point3d(x,y,z))
                    z += 2
                }
                y+=1
            }
            x+=1
        }
        
        return coords
    }
    
    func convexHull(coords : [Point3d]) -> [[SCNVector3]] {
        
        func point2scnVector(_ p:Point3d) -> SCNVector3 {
                return SCNVector3Make(Real(p.x), Real(p.y), Real(p.z))
        }
        
        func scaleCoords(_ pts:[Point3d]) -> [Point3d] {
            func findDiff(_ pts:[Point3d]) -> Double {
                let dif=abs(pts.map({(Point3d) -> Double in return Point3d.maxValue()}).max()! -
                    pts.map({(Point3d) -> Double in return Point3d.minValue()}).min()!)
                return dif
            }
            let dif=findDiff(pts)
            return pts.map({(Point3d) -> Vector3d in return Point3d.scaleInv(dif)}) as! [Point3d]
        }
        
        
        
        let hull = QuickHull3D(coords)        
        
        var retcoords=[[SCNVector3]]()
        var vtxs=scaleCoords( hull.getVertices() )
        
        for face in hull.getFaces() {
            var c=[SCNVector3]()
            for ixc in face {
                c.append(point2scnVector(vtxs[ixc]))
            }
            retcoords.append(c)
        }
        
        return retcoords
    }
    
    
}

