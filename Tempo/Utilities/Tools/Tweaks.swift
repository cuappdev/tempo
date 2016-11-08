//
//  Tweaks.swift
//
//  Created by Dennis Fedorko on 4/16/15.
//  Copyright (c) 2015 Dominik Hauser. All rights reserved.
//

import Foundation
import Tweaks

class Tweaks: NSObject, FBTweakObserver {
    
    typealias ActionWithValue = ((_ currentValue:AnyObject) -> ())
    var actionsWithValue = [String:ActionWithValue]()
    
    class func collectionWithName(_ collectionName: String, categoryName: String) -> FBTweakCollection {
        
        let store = FBTweakStore.sharedInstance()
        
        var category = store?.tweakCategory(withName: categoryName)
        if category == nil {
            category = FBTweakCategory(name: categoryName)
            store?.addTweakCategory(category)
        }
        
        var collection = category?.tweakCollection(withName: collectionName)
        if collection == nil {
            collection = FBTweakCollection(name: collectionName)
            category?.addTweakCollection(collection)
        }
        
        return collection!
    }
    
    class func tweakValueForCategory<T:AnyObject>(_ categoryName: String, collectionName: String, name: String, defaultValue: T, minimumValue: T? = nil, maximumValue: T? = nil) -> T {
        
        let identifier = categoryName.lowercased() + "." + collectionName.lowercased() + "." + name
        
        let collection = collectionWithName(collectionName, categoryName: categoryName)
        
        var tweak = collection.tweak(withIdentifier: identifier)
        if tweak == nil {
            tweak = FBTweak(identifier: identifier)
            tweak?.name = name
            tweak?.defaultValue = defaultValue
            
            if minimumValue != nil && maximumValue != nil {
                tweak?.minimumValue = minimumValue
                tweak?.maximumValue = maximumValue
            }
            
            collection.addTweak(tweak)
        }
        
        return (tweak!.currentValue ?? tweak!.defaultValue) as! T
        
    }
    
    func tweakActionForCategory<T>(_ categoryName: String, collectionName: String, name: String, defaultValue:T, minimumValue:T? = nil, maximumValue:T? = nil, action:@escaping (_ currentValue:AnyObject) -> ()) where T: AnyObject {
        
        let identifier = categoryName.lowercased() + "." + collectionName.lowercased() + "." + name
        
        let collection = Tweaks.collectionWithName(collectionName, categoryName: categoryName)
        
        var tweak = collection.tweak(withIdentifier: identifier)
        if tweak == nil {
            tweak = FBTweak(identifier: identifier)
            tweak?.name = name
            
            tweak?.defaultValue = defaultValue
            
            if minimumValue != nil && maximumValue != nil {
                tweak?.minimumValue = minimumValue
                tweak?.maximumValue = maximumValue
            }
            tweak?.add(self)
            
            collection.addTweak(tweak)
        }
        
        actionsWithValue[identifier] = action
        
        action(tweak?.currentValue as AnyObject? ?? tweak!.defaultValue as AnyObject)
    }
    
    
    func tweakDidChange(_ tweak: FBTweak!) {
        let action = actionsWithValue[tweak.identifier]
        action?(tweak.currentValue as AnyObject? ??  tweak.defaultValue as AnyObject)
    }
    
}
