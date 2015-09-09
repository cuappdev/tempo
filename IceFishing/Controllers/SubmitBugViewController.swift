//
//  SubmitBugViewController.swift
//  IceFishing
//
//  Created by Dennis Fedorko on 4/11/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit
import MediaPlayer
import Alamofire

class SubmitBugViewController: UIViewController {
    
    var recordingURL:NSURL!
    var screenshot:UIImage!
    var textView:UITextView!

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

        
        textView = UITextView(frame: CGRectMake(0, 50, view.frame.width, 250))
        textView.font = UIFont.systemFontOfSize(16)
        self.view.addSubview(textView)
        
        textView.becomeFirstResponder()
        
        
    }

    
    func submitBug() {
        
        if(recordingURL != nil) {
            submitVideo()
        }
        else if(screenshot != nil) {
            submitScreenshot()
        }
        else {
            submitText()
        }
        
    }
    
    func submitText() {
        
        print("++++++++++++++++++++++++++++++++++")
        
        let parameters = [
            "channel": "C04C10672",
            "token": "xoxp-2342414247-2693337898-4405497914-7cb1a7",
            "text": textView.text!,
            "username": "DESTRUCTO-STEVE"
        ]
        
        Alamofire.request(.POST, "https://slack.com/api/chat.postMessage", parameters: parameters)
            .response { request, response, JSON, error in
                print("REQUEST \(request)")
                print("RESPONSE \(response)")
                print("JSON \(JSON)")
                print("ERROR \(error)")
        }
        
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    func submitScreenshot() {
        
        let fileContents = UIImageJPEGRepresentation(screenshot, 0.7)
        
        print("++++++++++++++++++++++++++++++++++")
        
        let parameters = [
            "channels": "C04C10672",
            "token": "xoxp-2342414247-2693337898-4405497914-7cb1a7",
            "initial_comment": textView.text!
        ]
        let imageData = fileContents as NSData!
        let urlRequest = urlRequestWithComponents("https://slack.com/api/files.upload", parameters: parameters, data: imageData)
        Alamofire.upload(urlRequest.0, data: urlRequest.1)
            .progress { bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in
                print("\(totalBytesWritten) / \(totalBytesExpectedToWrite)")
            }
            .responseJSON { request, response, result in
                print("REQUEST \(request)")
                print("RESPONSE \(response)")
                print("JSON \(result.value)")
                print("ERROR \(result.error)")
        }
        
        
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    func submitVideo() {
        
        let fileContents = NSData(contentsOfURL: recordingURL)
        
        print("++++++++++++++++++++++++++++++++++")
        
        let parameters = [
            "channels": "C04C10672",
            "token": "xoxp-2342414247-2693337898-4405497914-7cb1a7",
            "initial_comment": textView.text!
        ]
        let movieData = fileContents as NSData!
        let urlRequest = urlRequestWithComponents("https://slack.com/api/files.upload", parameters: parameters, data: movieData)
        Alamofire.upload(urlRequest.0, data: urlRequest.1)
            .progress { bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in
                print("\(totalBytesWritten) / \(totalBytesExpectedToWrite)")
            }
            .responseJSON { request, response, result in
                print("REQUEST \(request)")
                print("RESPONSE \(response)")
                print("JSON \(result.value)")
                print("ERROR \(result.error)")
        }
        
        
        dismissViewControllerAnimated(false, completion: nil)

    }
    
    func urlRequestWithComponents(urlString:String, parameters:Dictionary<String, String>, data:NSData) -> (URLRequestConvertible, NSData) {
        
        // create url request to send
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        let boundaryConstant = "myRandomBoundary12345"
        let contentType = "multipart/form-data;boundary="+boundaryConstant
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        
        
        // create upload data to send
        let uploadData = NSMutableData()
        
        // add image
        uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Disposition: form-data; name=\"file\"; filename=\"Bug_Report.mov\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Type: movie/quicktime\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData(data)
        
        // add parameters
        for (key, value) in parameters {
            uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        uploadData.appendData("\r\n--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        
        
        // return URLRequestConvertible and NSData
        return (Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData)
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
