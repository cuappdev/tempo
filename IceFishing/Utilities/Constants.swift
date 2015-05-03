//
//  Constants.swift
//  IceFishing
//
//  Created by Dennis Fedorko on 4/26/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

class Constants: NSObject {
    
    
    class func primaryColor() -> UIColor {
        
        let red = CGFloat(Tweaks.tweakValueForCategory("Colors", collectionName: "Primary Color", name: "Red", defaultValue: 100, minimumValue: 0, maximumValue: 255)) / 255.0
        let green = CGFloat(Tweaks.tweakValueForCategory("Colors", collectionName: "Primary Color", name: "Green", defaultValue: 100, minimumValue: 0, maximumValue: 255)) / 255.0
        let blue = CGFloat(Tweaks.tweakValueForCategory("Colors", collectionName: "Primary Color", name: "Blue", defaultValue: 100, minimumValue: 0, maximumValue: 255)) / 255.0
        let alpha = CGFloat(Tweaks.tweakValueForCategory("Colors", collectionName: "Primary Color", name: "Alpha", defaultValue: 255, minimumValue: 0, maximumValue: 255)) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
        
    }
    
    class func secondaryColor() -> UIColor {
        
        let red = CGFloat(Tweaks.tweakValueForCategory("Colors", collectionName: "Secondary Color", name: "Red", defaultValue: 100, minimumValue: 0, maximumValue: 255)) / 255.0
        let green = CGFloat(Tweaks.tweakValueForCategory("Colors", collectionName: "Secondary Color", name: "Green", defaultValue: 100, minimumValue: 0, maximumValue: 255)) / 255.0
        let blue = CGFloat(Tweaks.tweakValueForCategory("Colors", collectionName: "Secondary Color", name: "Blue", defaultValue: 100, minimumValue: 0, maximumValue: 255)) / 255.0
        let alpha = CGFloat(Tweaks.tweakValueForCategory("Colors", collectionName: "Secondary Color", name: "Alpha", defaultValue: 255, minimumValue: 0, maximumValue: 255)) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
        
    }
    
    

    
   
}
