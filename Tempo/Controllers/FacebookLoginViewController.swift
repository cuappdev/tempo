
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
	var descriptionLabel: UILabel!
	var loginButton: UIButton!
	var activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
	
	weak var delegate: FacebookLoginViewControllerDelegate?
	
	static let usersRegisteredOnThisDeviceKey = "FacebookLoginViewController.usersRegisteredOnThisDevice"

    override func viewDidLoad() {
        super.viewDidLoad()
		
		view.backgroundColor = .tempoOnboardingGray
		view.alpha = 0.0
		layoutSubviews()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		UIView.animate(withDuration: 1.0, delay: 0.5, options: .curveEaseIn, animations: {
			self.view.alpha = 1.0
		})
	}
	
	func layoutSubviews() {
		// Logo Image
		logoImageView = UIImageView(frame: CGRect(x: 0, y: view.frame.height * 0.19, width: view.frame.width * 0.427, height: view.frame.width * 0.427))
		logoImageView.center.x = view.center.x
		logoImageView.image = #imageLiteral(resourceName: "TempoLogo")
		
		// Tempo Label
		tempoLabel = UILabel(frame: CGRect(x: 0, y: view.frame.height * 0.51, width: view.frame.width, height: view.frame.height))
		tempoLabel.text = "Tempo"
		tempoLabel.textAlignment = .center
		tempoLabel.textColor = .white
		tempoLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 60.0)
		tempoLabel.sizeToFit()
		tempoLabel.center.x = view.center.x
		
		// Description Label
		descriptionLabel = UILabel(frame: CGRect(x: 0, y: view.frame.height * 0.69, width: view.frame.width * 0.84, height: view.frame.height))
		
		let descParagraphStyle = NSMutableParagraphStyle()
		descParagraphStyle.lineSpacing = 5
		
		let descAttributedString = NSMutableAttributedString(string: "Share 30 second music snippets with your friends for 24 hours.")
		descAttributedString.addAttribute(NSParagraphStyleAttributeName, value: descParagraphStyle, range: NSMakeRange(0, descAttributedString.length))
		descriptionLabel.attributedText = descAttributedString
		
		descriptionLabel.textAlignment = .center
		descriptionLabel.textColor = .tempoGray
		descriptionLabel.font = UIFont(name: "AvenirNext-Regular", size: 17.0)
		descriptionLabel.numberOfLines = 2
		descriptionLabel.sizeToFit()
		descriptionLabel.center.x = view.center.x
		
		// Facebook Login Button
		loginButton = UIButton(frame: CGRect(x: 0, y: view.frame.height * 0.855, width: view.frame.width * 0.736, height: view.frame.height * 0.09))
		loginButton.center.x = view.center.x
		loginButton.setTitle("Log in with Facebook", for: .normal)
		loginButton.setTitleColor(.buttonGrey, for: .normal)
		loginButton.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 17.0)
		loginButton.backgroundColor = .facebookBlue
		loginButton.layer.cornerRadius = 5
		loginButton.addTarget(self, action: #selector(loginToFacebook), for: .touchUpInside)
		loginButton.addTarget(self, action: #selector(pressButton), for: .touchDown)
		loginButton.addTarget(self, action: #selector(releaseButton), for: .touchDragExit)
		
		view.addSubview(logoImageView)
		view.addSubview(tempoLabel)
		view.addSubview(descriptionLabel)
		view.addSubview(loginButton)
	}
	
	func showActivityIndicator() {
		view.isUserInteractionEnabled = false
		
		descriptionLabel.alpha = 0.0

		activityIndicatorView.center = descriptionLabel.center
		activityIndicatorView.startAnimating()
		view.addSubview(activityIndicatorView)
	}
	
	func hideActivityIndicator() {
		view.isUserInteractionEnabled = true

		descriptionLabel.alpha = 1.0
		
		activityIndicatorView.stopAnimating()
		activityIndicatorView.removeFromSuperview()
	}
	
	func pressButton() {
		loginButton.alpha = 0.5
	}
	
	func releaseButton() {
		loginButton.alpha = 1.0
	}
	
	func loginToFacebook() {
		showActivityIndicator()
		loginButton.alpha = 1.0
		
		let fbLoginManager = FBSDKLoginManager()
		fbLoginManager.logOut()
		
		fbLoginManager.logIn(withReadPermissions: ["public_profile", "email", "user_friends"], from: nil) { loginResult, error in
			self.loginButton.isUserInteractionEnabled = true
			if let err = error {
				print("Facebook login error: \(err)")
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
