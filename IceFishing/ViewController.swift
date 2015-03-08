//
//  ViewController.swift
//  IceFishing
//
//  Created by Lucas Derraugh on 3/8/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

import Alamofire
import SwiftyJSON
import AlamofireSwiftyJSON

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Random test for Alamofire-SwiftyJSON
        Alamofire.request(.GET, "http://httpbin.org/get", parameters: ["foo": "bar"])
            .responseSwiftyJSON { (request, response, json, error) in
                println(json)
                println(error)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
