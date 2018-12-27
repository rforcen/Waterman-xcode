//
//  misc.swift
//  PlatonicPolyhedra
//
//  Created by asd on 05/12/2018.
//  Copyright © 2018 voicesync. All rights reserved.
//

import SceneKit


let sphereRadius:CGFloat=0.006, cylsRadius:CGFloat=0.003
let colorSet=[Color.yellow, Color.red, Color.green, Color.magenta, Color.brown, Color.purple]
let alphaFace:CGFloat=0.8

func createMaterial( color : Color ) -> SCNMaterial {
    let mat = SCNMaterial();
    mat.diffuse.contents         = color;
    mat.locksAmbientWithDiffuse  = true;
    return mat;
}

func createAmbientLight() -> SCNNode {
    let ambientLight=SCNLight()
    let ambientLightNode=SCNNode()
    ambientLight.type = SCNLight.LightType.ambient
    ambientLight.color = Color.init(white: 0.2, alpha: 1)
    
    ambientLightNode.light=ambientLight
    return ambientLightNode
}

func createDiffuseLight() -> SCNNode {
    let diffuseLight = SCNLight()
    let diffuseLightNode = SCNNode()
    diffuseLight.type=SCNLight.LightType.omni //SCNLightTypeOmni
    diffuseLightNode.light = diffuseLight
    diffuseLightNode.position = SCNVector3(-30, 30, 50)
    return diffuseLightNode
}

func createCamera(zoom:Float) -> SCNNode {
    let cameraNode=SCNNode()
    cameraNode.camera=SCNCamera()
    cameraNode.position=SCNVector3(0,0,zoom)
    return cameraNode
}

func createScene(sceneView:SCNView) -> SCNScene {
    let sc = SCNScene()
    let root = sc.rootNode
    root.addChildNode(createCamera(zoom: 2))
    root.addChildNode(createAmbientLight())
    root.addChildNode(createDiffuseLight())
    
    sceneView.scene = sc
    sceneView.allowsCameraControl = true
    sceneView.backgroundColor = Color.clear
    sceneView.showsStatistics = true
    
    return sc
}

func textPolygon(n:Int) -> [CGPoint] {
    var c=[CGPoint]()
    let pi2n:CGFloat = 2*CGFloat.pi / CGFloat(n), r:CGFloat = 0.5, xoffset:CGFloat = 0.5, yoffset:CGFloat = xoffset
    for i in 0..<n {
        let a = CGFloat(n - i - n) / 2.0
        c.append(CGPoint( x:r * sin(a * pi2n) + xoffset,
                          y:r * cos(a * pi2n) + yoffset ))
    }
    return c
}

// spheres in coords
func genPoints(coords:[[SCNVector3]], material:SCNMaterial) -> SCNNode {
    let objNode = SCNNode()
    var set=Set<Point>()
    
    for coord in coords.joined() {
        let pnt = Point(point:coord)
        if (!set.contains(pnt)) {
            set.insert(pnt)
            
            let sp = SCNSphere(radius: sphereRadius)
            sp.firstMaterial = material
            let node = SCNNode(geometry: sp)
            node.position = coord
            objNode.addChildNode(node)
        }
    }
    return objNode
}

// cyls as coords joins
func genTubes(coords:[[SCNVector3]], material:SCNMaterial) -> SCNNode {
    let objNode = SCNNode()
    
    func setSegments() -> Set<Segment> { // unique segments
        var setSeg = Set<Segment>()
        
        for face in coords { // find unique pairs from,to
            for f in 0..<face.count {
                let ifrom=f, ito=(f+1) % face.count
                let seg=Segment(from: face[ifrom], to:face[ito])
                if( !setSeg.contains(seg) )
                {
                    setSeg.insert(seg)
                }
            }
        }
        return setSeg
    }
    
    func cylVector(from : SCNVector3, to : SCNVector3) -> SCNNode {
        let vector = to - from,
            length = vector.length()
        
        let cylinder = SCNCylinder(radius: cylsRadius, height: CGFloat(length))
        cylinder.radialSegmentCount = 6
        cylinder.firstMaterial = material
        
        let node = SCNNode(geometry: cylinder)

        node.position = (to + from) / 2
        node.eulerAngles = SCNVector3Make(Real(Double.pi/2), acos((to.z-from.z)/Real(length)), atan2((to.y-from.y), (to.x-from.x) ))
        
        return node
    }
    
    for s in setSegments() {
        objNode.addChildNode(cylVector(from: s.from, to: s.to))
    }
    return objNode
    
}


// node = points + tubes
func genNode( coords:[[SCNVector3]], material:SCNMaterial ) -> SCNNode {
    let node=SCNNode()
    node.addChildNode(genPoints(coords:coords, material:material))
    node.addChildNode(genTubes(coords: coords, material: material))
    return node
}

// faced polyhedra
func genNodeSolid(coords:[[SCNVector3]], frameMaterial:SCNMaterial, withPointsCyls:Bool=true, alpha:CGFloat=0.8) -> SCNNode {
    func colorOfFace(vertexes:[SCNVector3], alpha:CGFloat) -> SCNMaterial {
        return createMaterial(color: colorSet[(vertexes.count-3) % colorSet.count].withAlphaComponent(alpha))
    }
    func strobeColor(vertexes:[SCNVector3], alpha:CGFloat) -> SCNMaterial {
        return createMaterial(color: StrobeColors.getColor(index:vertexes.count).withAlphaComponent(alpha))
    }
    func genElement(vertexes:[SCNVector3]) -> [SCNGeometryElement] {
        let ielem:[byte]=[byte(vertexes.count)] + Array<byte>(0..<byte(vertexes.count))
        return [SCNGeometryElement(
            data:Data(bytes: ielem, count: MemoryLayout<byte>.size * ielem.count),
            primitiveType: .polygon,  primitiveCount: 1,   bytesPerIndex: MemoryLayout<byte>.size)]
    }
    func genNormals(vertexes:[SCNVector3]) -> [SCNVector3] {
        return Array<SCNVector3>(repeating: SCNVectorNormal(vertices:vertexes), count: vertexes.count)
    }
    func genSources(vertexes : [SCNVector3]) -> [SCNGeometrySource] { // vertices, normals, textures
        return [SCNGeometrySource(vertices : vertexes),
                SCNGeometrySource(normals:  genNormals(vertexes:vertexes)),
                SCNGeometrySource(textureCoordinates: textPolygon(n:vertexes.count))]
    }
    func genNodes() -> SCNNode {
        let node = SCNNode()
        
        for vertexes in coords {
            let geo=SCNGeometry( sources : genSources(vertexes: vertexes),
                                 elements: genElement(vertexes: vertexes))
            //            geo.firstMaterial=colorOfFace(vertexes: vertexes, alpha:alpha) //createMaterial(color : faceColor)
            geo.firstMaterial=strobeColor(vertexes: vertexes, alpha:alpha) 
            
            node.addChildNode(SCNNode(geometry: geo))
        }
        
        return node
    }
    
    let node=withPointsCyls ? genNode( coords: coords, material: frameMaterial) : SCNNode() // add points & cyls ?
    
    node.addChildNode( genNodes() )
    
    return node
}

extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let idx1 = index(startIndex, offsetBy: max(0, range.lowerBound))
        let idx2 = index(startIndex, offsetBy: min(self.count, range.upperBound))
        return String(self[idx1..<idx2])
    }
    
}
