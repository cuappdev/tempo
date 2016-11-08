//
//  SubmitBugViewController.swift
//
//  Created by Dennis Fedorko on 4/11/15.
//  Copyright (c) 2015 Dennis Fedorko. All rights reserved.
//

import UIKit

class SubmitBugViewController: UIViewController {
    
    let toolsController: Tools
	let channel: String
	let token: String
	let username: String
    var screenshot: UIImage?
    var textView: UITextView!
    
    //initialize using this method to create a message without a screenshot
    init(toolsController: Tools, channel: String, token: String, username: String) {
		self.toolsController = toolsController
        self.channel = channel
        self.token = token
        self.username = username
		super.init(nibName: nil, bundle: nil)
    }
	
    //initialize using this method to create a message with a screenshot
    init(toolsController: Tools, screenshot: UIImage, channel: String, token: String, username: String) {
		self.toolsController = toolsController
        self.channel = channel
        self.token = token
        self.username = username
        self.screenshot = screenshot
		super.init(nibName: nil, bundle: nil)
    }
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		//set background color for view
		view.backgroundColor = UIColor.white
		
		//create title label in top center of view controller
		let titleLabel = UILabel(frame: CGRect(x: 0, y: 20, width: view.frame.width, height: 30))
		titleLabel.text = "Submit Bug Report"
		titleLabel.textAlignment = .center
		view.addSubview(titleLabel)
		
		//create cancel button to dismiss but submittion form
		let cancelButton = UIButton(frame: CGRect(x: 0, y: 20, width: 80, height: 30))
		cancelButton.setTitle("Cancel", for: UIControlState())
		cancelButton.setTitleColor(UIColor(red: 0, green:122.0/255.0, blue: 1, alpha: 1), for: UIControlState())
		cancelButton.addTarget(self, action: #selector(cancel), for: .touchDown)
		view.addSubview(cancelButton)
		
		//create submit button to send bug report to slack
		let submitButton = UIButton(frame: CGRect(x: view.frame.width - 80 , y: 20, width: 80, height: 30))
		submitButton.setTitle("Submit", for: UIControlState())
		submitButton.setTitleColor(UIColor(red: 0, green: 122.0/255.0, blue: 1, alpha: 1), for: UIControlState())
		submitButton.addTarget(self, action: #selector(submitBug), for: .touchDown)
		view.addSubview(submitButton)
	}

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
	
    override func viewDidAppear(_ animated: Bool) {
        //create text view for entering message
        textView = UITextView(frame: CGRect(x: 0, y: 50, width: view.frame.width, height: 250))
        textView.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(textView)
        
        //display keyboard as soon as view appears
        textView.becomeFirstResponder()
    }
    
    func submitBug() {
        // if we have a screenshot, submit it,
        // otherwise only submit text
        if screenshot != nil {
            submitScreenshot()
        }
        else {
            submitText()
        }
    }
    
    func submitText() {
        print("++++++++Submitting Text Message To Slack+++++++++++++")
        
        //create parameters for url request
        let requestURL = URL(string: "https://slack.com/api/chat.postMessage?")
        
        //create post request
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "POST"
        
        //sign parameters for url request based on slack api
        let parameters = "token=\(token)&channel=\(channel)&text=\(textView.text!)&username=\(username)&pretty=1"
        request.httpBody = parameters.data(using: String.Encoding.utf8)
        
        //asynchronously send url request through NSURLSession
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if error == nil {
                print("ERROR \(error)")
            } else {
                print("RESPONSE \(String(data: data!, encoding: String.Encoding.utf8))")
            }
        }) 
        task.resume()
        
        //after request is sent we can dismiss view controller
        dismiss(animated: true) {
            self.toolsController.assignFirstResponder()
        }
    }
    
    func submitScreenshot() {
        print("+++++++++Submitting Screenshot To Slack++++++++++")
        
        //create parameters for url request
        let parameters = [
            "channels": channel,
            "token": token,
            "initial_comment": textView.text!
        ]
        
        //represent screenshot as jpeg image data
        let imageData =  UIImageJPEGRepresentation(screenshot!, 0.7) as Data!
    
        //create multipart/form-data request with slack api url, parameters, and the image data to be uploaded
        makeMultipartFormDataRequest(URL(string: "https://slack.com/api/files.upload?")!, parameters: parameters, data: imageData!)
        
        //after request is sent we can dismiss view controller
        dismiss(animated: true) {
            self.toolsController.assignFirstResponder()
        }
    }
    
    func makeMultipartFormDataRequest (_ baseURL: URL, parameters: [String:String], data: Data) {
        // create url request to send
        var mutableURLRequest = URLRequest(url: baseURL)
        mutableURLRequest.httpMethod = "POST"
        let boundaryConstant = "myRandomBoundary123"
        let contentType = "multipart/form-data;boundary="+boundaryConstant
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        // create upload data to send
        let uploadData = NSMutableData()
    
        // add image
        uploadData.append("\r\n--\(boundaryConstant)\r\n".data(using: String.Encoding.utf8)!)
        uploadData.append("Content-Disposition: form-data; name=\"file\"; filename=\"app_screenshot.jpg\"\r\n".data(using: String.Encoding.utf8)!)
        uploadData.append("Content-Type: image/jpeg\r\n\r\n".data(using: String.Encoding.utf8)!)
        uploadData.append(data)
    
        // add parameters
        for (key, value) in parameters {
        uploadData.append("\r\n--\(boundaryConstant)\r\n".data(using: String.Encoding.utf8)!)
        uploadData.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".data(using: String.Encoding.utf8)!)
        }
        uploadData.append("\r\n--\(boundaryConstant)--\r\n".data(using: String.Encoding.utf8)!)
        
        //set http body for request
        mutableURLRequest.httpBody = uploadData as Data
        
        //asynchronously send url request through NSURLSession
        let task = URLSession.shared.dataTask(with: mutableURLRequest, completionHandler: { data, _, error in
            if error == nil {
                print("ERROR \(error)")
            } else {
                print("RESPONSE \(String(data: data!, encoding: String.Encoding.utf8))")
            }
        }) 
        task.resume()
    }

    func cancel() {
        //cancel button was pressed, remove screenshot submission form from view hierarchy
        textView.endEditing(true)
        dismiss(animated: true) {
            self.toolsController.assignFirstResponder()
        }
    }
}
