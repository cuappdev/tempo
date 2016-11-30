
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Haneke

protocol FacebookLoginViewControllerDelegate: class {
	
	func facebookLoginViewController(facebookLoginViewController: FacebookLoginViewController, didFinishLoggingInWithNewUserNamed name: String, withFacebookID fbid: String)

	func facebookLoginViewController(facebookLoginViewController: FacebookLoginViewController, didFinishLoggingInWithPreviouslyRegisteredUserNamed name: String, withFacebookID fbid: String)
}

class FacebookLoginViewController: UIViewController {
	
	var logoImageView: UIImageView!
	var tempoLabel: UILabel!
	var descriptionTextView: UITextView!
	var loginButton: UIButton!
	var activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
	
	weak var delegate: FacebookLoginViewControllerDelegate?
	
	static let usersRegisteredOnThisDeviceKey = "FacebookLoginViewController.usersRegisteredOnThisDevice"

    override func viewDidLoad() {
        super.viewDidLoad()
		view.alpha = 0.0
		layoutSubviews()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		UIView.animate(withDuration: 1.0, delay: 0.5, options: .curveEaseIn, animations: {
			self.view.alpha = 1.0

		}, completion: nil)

	}
	
	func layoutSubviews() {
		
		logoImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.width * 0.45, height: view.frame.width * 0.45))
		logoImageView.center = CGPoint(x: view.center.x, y: view.frame.height * 0.275)
		logoImageView.image = UIImage(named: "tempo-logo-transparent")
		
		tempoLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height / 10))
		tempoLabel.center = view.center
		tempoLabel.text = "Tempo"
		tempoLabel.textAlignment = .center
		tempoLabel.textColor = .white
		tempoLabel.font = UIFont(name: "HelveticaNeue-Bold", size: view.frame.height / 10)
		tempoLabel.isUserInteractionEnabled = false
		
		loginButton = UIButton(frame: CGRect(x: 0, y: 0, width: view.frame.width * 0.7, height: 60))
		loginButton.frame.bottom = CGPoint(x: view.center.x, y: view.frame.height - view.frame.width * 0.15)
		loginButton.backgroundColor = UIColor.tempoBlue
		loginButton.setTitle("Log in with Facebook", for: .normal)
		loginButton.setTitleColor(.white, for: .normal)
		loginButton.layer.cornerRadius = 5
		loginButton.addTarget(self, action: #selector(loginToFacebook), for: .touchUpInside)
		loginButton.addTarget(self, action: #selector(pressButton), for: .touchDown)
		loginButton.addTarget(self, action: #selector(releaseButton), for: .touchDragExit)
		
		descriptionTextView = UITextView(frame: CGRect(x: 0, y: 0, width: view.frame.width * 0.8, height: 80))
		descriptionTextView.center = CGPoint(x: view.center.x, y: tempoLabel.frame.bottom.y + (loginButton.frame.top.y - tempoLabel.frame.bottom.y) / 2)
		descriptionTextView.backgroundColor = .clear
		descriptionTextView.text = "Tempo is a music sharing app that allows you to share 30 second clips with your friends"
		descriptionTextView.textAlignment = .center
		descriptionTextView.textColor = .white
		descriptionTextView.font = UIFont(name: "AvenirNext-Regular", size: 16)
		descriptionTextView.isScrollEnabled = false
		
		view.addSubview(logoImageView)
		view.addSubview(tempoLabel)
		view.addSubview(descriptionTextView)
		view.addSubview(loginButton)
	}
	
	func showActivityIndicator() {
		view.isUserInteractionEnabled = false
		descriptionTextView.alpha = 0.0

		activityIndicatorView.center = descriptionTextView.center
		activityIndicatorView.startAnimating()
		view.addSubview(activityIndicatorView)
	}
	
	func hideActivityIndicator() {
		view.isUserInteractionEnabled = true

		descriptionTextView.alpha = 1.0
		
		activityIndicatorView.stopAnimating()
		activityIndicatorView.removeFromSuperview()
	}
	
	func pressButton(){
		loginButton.alpha = 0.8
		loginButton.isUserInteractionEnabled = false

	}
	
	func releaseButton(){
		loginButton.alpha = 1.0
	}
	
	func loginToFacebook() {
		showActivityIndicator()
		loginButton.alpha = 1.0
		let fbLoginManager = FBSDKLoginManager()
		fbLoginManager.logOut()
		fbLoginManager.logIn(withReadPermissions: ["public_profile", "email", "user_friends"], from: nil) { loginResult, error in
			self.loginButton.isUserInteractionEnabled = true
			if error != nil {
				print("Facebook login error: \(error)")
				self.hideActivityIndicator()
			} else if (loginResult?.isCancelled)! {
				print("FB Login Cancelled")
				self.hideActivityIndicator()
			} else {
				self.fbSessionStateChanged(error: error as NSError?)
			}
		}
		Shared.imageCache.removeAll()
	}

	// Facebook Session
	func fbSessionStateChanged(error : NSError?) {
		guard error == nil else { FBSDKAccessToken.setCurrent(nil); return }
		guard FBSDKAccessToken.current() != nil else { return }
		let userRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "name, first_name, last_name, id, email, picture.type(large)"])
		
		let _ = userRequest?.start(completionHandler: { (connection: FBSDKGraphRequestConnection?, result: Any?, error: Error?) in
			
			guard let responseJSON = result as? [String:Any],
				let fbid = responseJSON["id"] as? String,
				let name = responseJSON["name"] as? String,
				error == nil else { print("Error getting Facebook user: \(error)"); return }
			
			let fbAccessToken = FBSDKAccessToken.current().tokenString
			
			API.sharedAPI.fbAuthenticate(fbid, userToken: fbAccessToken!) { success, newUser in
				guard success else { return }
				if newUser {
					self.delegate?.facebookLoginViewController(facebookLoginViewController: self, didFinishLoggingInWithNewUserNamed: name, withFacebookID: fbid)
					self.hideActivityIndicator()

				} else {
					API.sharedAPI.setCurrentUser(fbid, fbAccessToken: fbAccessToken!) { success in
						guard success else { return }
						self.delegate?.facebookLoginViewController(facebookLoginViewController: self, didFinishLoggingInWithPreviouslyRegisteredUserNamed: name, withFacebookID: fbid)
						self.hideActivityIndicator()
					}
				}
				
			}
		})
	}
	
	static func retrieveCurrentFacebookUserWithAccessToken(token: String, completion: ((Bool) -> ())?) {

		let userRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "name, first_name, last_name, id, email, picture.type(large)"])
				
		let _ = userRequest?.start(completionHandler: { (connection: FBSDKGraphRequestConnection?, result: Any?, error: Error?) in
					
			guard let responseJSON = result as? [String:Any],
			let fbid = responseJSON["id"] as? String,
			error == nil else {
				print("Error getting Facebook user: \(error)")
				completion?(false)
				return
			}
					
			API.sharedAPI.fbAuthenticate(fbid, userToken: token) { success, newUser in
				guard success else { completion?(false); return }
				completion?(true)
			}
		})
		
		Shared.imageCache.removeAll()
	}
	
}
