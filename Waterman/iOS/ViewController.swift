//
//  ViewController.swift
//  iOS
//
//  Created by asd on 19/12/2018.
//  Copyright © 2018 voicesync. All rights reserved.
//

import UIKit

extension Float {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}

class ViewController: UIViewController {
    @IBOutlet weak var lRad: UILabel!
    @IBOutlet weak var radSlider: UISlider!
    
    @IBOutlet weak var transSlider: UISlider!
    @IBOutlet weak var frameSW: UISwitch!
    @IBOutlet weak var lTrans: UILabel!
    
    @IBOutlet weak var watermanScene: WatermanScene!
    // update
    @IBAction func onUpdate(_ sender: Any) {
        updateWaterman()
    }
    @IBAction func onShuffle(_ sender: Any) {
         StrobeColors.shuffle()
        updateWaterman()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        updateWaterman()
    }
    func updateWaterman() {
        let rad = radSlider.value
        lRad.text = "radius: \(rad.format(f: ".1"))"
        lTrans.text = "alpha: \(transSlider.value.format(f: ".1"))"
        
//        let wp = WatermanPolyhedra(Double(rad))
//        watermanScene.repaint(coords:wp.vertices, withFrame: frameSW.isOn, alpha:CGFloat(transSlider.value))
//        let wp = WatermanPolyhedra(Double(rad))
        watermanScene.repaint(coords: genWatermanCoords(radius: Double(rad)), withFrame: frameSW.isOn, alpha:CGFloat(transSlider.value))

    }
}

