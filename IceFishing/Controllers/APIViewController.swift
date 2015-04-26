//
//  APIViewController.swift
//  IceFishing
//
//  Created by Lucas Derraugh on 4/22/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

class APIViewController: UIViewController {

    @IBAction func sendRequest(sender: AnyObject) {
        API.sharedAPI.userNameIsValid("lucasderraugh") { isValid in
            println("Valid Username: \(isValid)")
        }
        
        API.sharedAPI.getSession()
    }
}
