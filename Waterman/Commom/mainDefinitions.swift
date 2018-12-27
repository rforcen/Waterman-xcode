//
//  mainDefinitions.swift
//  Waterman
//
//  Created by asd on 26/12/2018.
//  Copyright © 2018 voicesync. All rights reserved.
//  keeps compatibility macOS / iOS

import SceneKit

typealias byte=UInt8
#if os(OSX)
let frameColor=NSColor(calibratedRed: 0.5, green: 0.5, blue: 0, alpha: 0.8)

typealias Real = CGFloat
typealias Color = NSColor

#elseif os(iOS)
let frameColor=UIColor(red: 0.5, green: 0.5, blue: 0, alpha: 0.8)

typealias Real = Float
typealias Color = UIColor
#endif
