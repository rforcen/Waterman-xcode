//
//  PlatoScene.swift
//  PlatonicPolyhedra
//
//  Created by asd on 05/12/2018.
//  Copyright © 2018 voicesync. All rights reserved.
//

import SceneKit

class WatermanScene: SCNView {
    var myscene:SCNScene?
    var node:SCNNode?
    
    let yellowMaterial = createMaterial(color:Color.yellow)
  
    override func awakeFromNib() {
         myscene = createScene(sceneView: self)
    }
    
    func repaint(coords:[[SCNVector3]], withFrame:Bool, alpha:CGFloat) {
        let root=myscene!.rootNode
        
        if (node != nil) { node!.removeFromParentNode() }

        node=SCNNode()
        node!.addChildNode(genNodeSolid(coords: coords, frameMaterial: yellowMaterial,  withPointsCyls: withFrame, alpha: alpha))
        
        root.addChildNode(node!)
    }
    
}
