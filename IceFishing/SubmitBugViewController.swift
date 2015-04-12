//
//  SubmitBugViewController.swift
//  IceFishing
//
//  Created by Dennis Fedorko on 4/11/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit
import Alamofire

class SubmitBugViewController: UIViewController {
    
    var recordingURL:NSURL!

    override func viewDidLoad() {
        super.viewDidLoad()
    

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        setUpViews()
    }
    
    func setUpViews() {
        
        let titleLabel = UILabel(frame: CGRectMake(0, 20, view.frame.width, 30))
        titleLabel.text = "Submit Bug Report"
        titleLabel.textAlignment = NSTextAlignment.Center
        self.view.addSubview(titleLabel)
        
        let cancelButton = UIButton(frame: CGRectMake(0, 20, 80, 30))
        cancelButton.setTitle("Cancel", forState: UIControlState.Normal)
        cancelButton.setTitleColor(UIColor(red:0.0, green:122.0/255.0, blue:1.0, alpha:1.0), forState: UIControlState.Normal)
        cancelButton.addTarget(self, action: Selector("cancel"), forControlEvents: UIControlEvents.TouchDown)
        self.view.addSubview(cancelButton)
        
        let submitButton = UIButton(frame: CGRectMake(view.frame.width - 80 , 20, 80, 30))
        submitButton.setTitle("Submit", forState: UIControlState.Normal)
        submitButton.setTitleColor(UIColor(red:0.0, green:122.0/255.0, blue:1.0, alpha:1.0), forState: UIControlState.Normal)
        submitButton.addTarget(self, action: Selector("submitBug"), forControlEvents: UIControlEvents.TouchDown)
        self.view.addSubview(submitButton)

        
        let textView = UITextView(frame: CGRectMake(0, 50, view.frame.width, 250))
        textView.font = UIFont.systemFontOfSize(16)
        self.view.addSubview(textView)
        
        textView.becomeFirstResponder()
        
        
    }
    func submitBug() {
        
        let postURL = "https://slack.com/api/files.upload"
        let fileContents = NSData(contentsOfURL: recordingURL)!
        let token = "xoxp-2342414247-2344160688-4426650793-038bbb"
        let channel = "C02LG613T"
        let comment = "this is a comment"
        
        let boundaryConstant = "thisisaboundaryconstant"
        
        var mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: postURL)!)
        mutableURLRequest.HTTPMethod = "POST"
        
        let contentType = "multipart/form-data; boundary=" + boundaryConstant
        var error: NSError?
        let boundaryStart = "--\(boundaryConstant)\r\n"
        let boundaryEnd = "--\(boundaryConstant)--\r\n"
        let contentDispositionString = "Content-Disposition: form-data; name=\"file\"; filename=\"BugReport\"\r\n"
        let contentTypeString = "Content-Type: video/quicktime\r\n\r\n"
        
        // Prepare the HTTPBody for the request.
        let requestBodyData : NSMutableData = NSMutableData()
        requestBodyData.appendData(boundaryStart.dataUsingEncoding(NSUTF8StringEncoding)!)
        requestBodyData.appendData(contentDispositionString.dataUsingEncoding(NSUTF8StringEncoding)!)
        requestBodyData.appendData(contentTypeString.dataUsingEncoding(NSUTF8StringEncoding)!)
        requestBodyData.appendData(fileContents)
        requestBodyData.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        requestBodyData.appendData(boundaryEnd.dataUsingEncoding(NSUTF8StringEncoding)!)
        
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        mutableURLRequest.HTTPBody = requestBodyData
        
        
//        let request =  Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: ["token":token]).0
//        println(request)
        Alamofire.request(.POST, "https://slack.com/api/files.upload", parameters: ["token":token], encoding: .URL)
            .response { (request, response, data, error) -> Void in
                if (error != nil) {
                    print(error)
                }
                println(data)
                println(response)
        }
        
        //https://slack.com/api/files.upload?token=xoxp-2342414247-2693337898-4405497914-7cb1a7&file=this%20is%20a%20file&initial_comment=this%20is%20a%20comment&channels=C02LG613T&pretty=1
        
        
        
        dismissViewControllerAnimated(false, completion: nil)
        
    }
    func cancel() {
        dismissViewControllerAnimated(false, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
