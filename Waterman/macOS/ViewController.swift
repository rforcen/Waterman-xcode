//
//  ViewController.swift
//  WatermanPoly
//
//  Created by asd on 07/12/2018.
//  Copyright © 2018 voicesync. All rights reserved.
//

import SceneKit

class ViewController: NSViewController {
    @IBOutlet weak var textRadius: NSTextField!
    @IBOutlet weak var stepRadius: NSStepperCell!
    
    @IBOutlet weak var watermanScene: WatermanScene!
    @IBOutlet weak var text: NSTextField!
    @IBOutlet weak var checkFrame: NSButton!
    
    @IBOutlet weak var langSelector: NSPopUpButton!
    @IBOutlet weak var alphaSlider: NSSlider!
    
    
    @IBAction func onStepRadius(_ sender: Any) {
        updateWaterman()
    }
    
    @IBAction func onShuffle(_ sender: Any) {
        StrobeColors.shuffle()
        updateWaterman()
    }
    
    @IBAction func onAlphaSlider(_ sender: Any) {
        updateWaterman()
    }
    
    @IBAction func onCheckFrame(_ sender: Any) {
        updateWaterman()
    }
    
    func updateWaterman() {
        let rad = Double(stepRadius!.floatValue)
        textRadius.stringValue = "radius: \(rad)"
        
        switch langSelector.titleOfSelectedItem {
        case "C++":
            watermanScene.repaint(coords:genWatermanCoords(radius: rad), withFrame: checkFrame.state==NSControl.StateValue.on, alpha:CGFloat(alphaSlider.floatValue/100.0)) // cpp implementation
            
        case "Swift":
            let wp = WatermanPolyhedra(rad) // swift pure implementation
            watermanScene.repaint(coords:wp.vertices, withFrame: checkFrame.state==NSControl.StateValue.on, alpha:CGFloat(alphaSlider.floatValue/100.0))
            
        default: break
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        onStepRadius(self)
    }
    
}

