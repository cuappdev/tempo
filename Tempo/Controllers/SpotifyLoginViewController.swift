
import UIKit

protocol SpotifyLoginViewControllerDelegate: class {
	
	func spotifyLoginViewController(spotifyLoginViewController: SpotifyLoginViewController, didFinishLoggingIntoSpotifyWithAccessToken token: String?)
	
}

class SpotifyLoginViewController: UIViewController {

	var connectToSpotifyLabel: UILabel!
	var connectToSpotifyImageView: UIImageView!
	var descriptionLabel: UILabel!
	var connectToSpotifyButton: UIButton!
	var skipThisStepButton: UIButton!
	
	weak var delegate: SpotifyLoginViewControllerDelegate?
	
	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = .tempoOnboardingGray
		layoutSubviews()
	}
	
	func layoutSubviews() {
		// Connect to Spotify Label
		connectToSpotifyLabel = UILabel(frame: CGRect(x: 0, y: view.frame.height * 0.168, width: view.frame.width * 0.9, height: 28))
		connectToSpotifyLabel.text = "Connect to Spotify"
		connectToSpotifyLabel.font = UIFont(name: "AvenirNext-Regular", size: 29.0)
		connectToSpotifyLabel.textColor = .tempoGray
		connectToSpotifyLabel.textAlignment = .center
		connectToSpotifyLabel.sizeToFit()
		connectToSpotifyLabel.center.x = view.center.x
		
		// Connect to Spotify Graphic
		connectToSpotifyImageView = UIImageView(frame: CGRect(x: 0, y: view.frame.height * 0.33, width: view.frame.width * 0.549, height: (view.frame.width * 0.549) * 0.626))
		connectToSpotifyImageView.clipsToBounds = true
		connectToSpotifyImageView.contentMode = .scaleAspectFit
		connectToSpotifyImageView.image = #imageLiteral(resourceName: "ConnectToSpotifyGraphic")
		connectToSpotifyImageView.center.x = view.center.x
		
		// Description Label
		descriptionLabel = UILabel(frame: CGRect(x: 0, y: view.frame.height * 0.627, width: view.frame.width * 0.84, height: 56))
		
		let descParagraphStyle = NSMutableParagraphStyle()
		descParagraphStyle.lineSpacing = 5
		
		let descAttributedString = NSMutableAttributedString(string: "Add newly discovered songs to your Spotify library")
		descAttributedString.addAttribute(NSParagraphStyleAttributeName, value: descParagraphStyle, range: NSMakeRange(0, descAttributedString.length))
		descriptionLabel.attributedText = descAttributedString
		
		descriptionLabel.font = UIFont(name: "AvenirNext-Regular", size: 17.0)
		descriptionLabel.textColor = .tempoGray
		descriptionLabel.textAlignment = .center
		descriptionLabel.numberOfLines = 2
		descriptionLabel.sizeToFit()
		descriptionLabel.frame.size.width = view.frame.width * 0.84
		descriptionLabel.center.x = view.center.x
		
		// Connect to Spotify Button
		connectToSpotifyButton = UIButton(frame: CGRect(x: 0, y: view.frame.height * 0.784, width: view.frame.width * 0.736, height: view.frame.height * 0.09))
		connectToSpotifyButton.center.x = view.center.x
		connectToSpotifyButton.backgroundColor = .spotifyGreen
		connectToSpotifyButton.setTitle("Connect to Spotify", for: .normal)
		connectToSpotifyButton.setTitleColor(.buttonGrey, for: .normal)
		connectToSpotifyButton.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 17.0)
		connectToSpotifyButton.layer.cornerRadius = 5
		connectToSpotifyButton.addTarget(self, action: #selector(connectToSpotifyButtonPressed), for: .touchUpInside)
		connectToSpotifyButton.addTarget(self, action: #selector(pressButton), for: .touchDown)
		connectToSpotifyButton.addTarget(self, action: #selector(releaseButton), for: .touchDragExit)

		// Skip Button
		skipThisStepButton = UIButton(frame: CGRect(x: 0, y: view.frame.height * 0.9, width: view.frame.width * 0.736, height: 23))
	
		let skipButtonAttrString = NSMutableAttributedString(string: "Skip and connect later", attributes: [NSFontAttributeName : UIFont(name: "AvenirNext-Regular", size: 17.0)!, NSForegroundColorAttributeName : UIColor.buttonTransparentGrey, NSUnderlineStyleAttributeName : 1])
		skipThisStepButton.setAttributedTitle(skipButtonAttrString, for: .normal)
		skipThisStepButton.sizeToFit()
		skipThisStepButton.center.x = view.center.x
		skipThisStepButton.addTarget(self, action: #selector(skipThisStepButtonPressed), for: .touchUpInside)
		
		view.addSubview(connectToSpotifyLabel)
		view.addSubview(connectToSpotifyImageView)
		view.addSubview(descriptionLabel)
		view.addSubview(connectToSpotifyButton)
		view.addSubview(skipThisStepButton)
	}
	
	func pressButton() {
		connectToSpotifyButton.alpha = 0.5
	}
	
	func releaseButton() {
		connectToSpotifyButton.alpha = 1.0
	}
	
	func connectToSpotifyButtonPressed() {
		connectToSpotifyButton.alpha = 1.0
		SpotifyController.sharedController.loginToSpotify { (success: Bool) in
			if success {
				self.setSpotifyUserAndContinue()
			}
		}
	}
	
	func skipThisStepButtonPressed() {
		delegate?.spotifyLoginViewController(spotifyLoginViewController: self, didFinishLoggingIntoSpotifyWithAccessToken: nil)
	}

	func setSpotifyUserAndContinue() {
		if let session = SPTAuth.defaultInstance().session, session.isValid() {
			SpotifyController.sharedController.setSpotifyUser(session.accessToken, completion: nil)

			delegate?.spotifyLoginViewController(spotifyLoginViewController: self, didFinishLoggingIntoSpotifyWithAccessToken: session.accessToken)
		}
	}
	
	
}
