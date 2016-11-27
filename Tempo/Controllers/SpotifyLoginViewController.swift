
import UIKit

protocol SpotifyLoginViewControllerDelegate: class {
	
	func spotifyLoginViewController(spotifyLoginViewController: SpotifyLoginViewController, didFinishLoggingInWithAccessToken token: String?)
	
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

		layoutSubviews()
	}
	
	func layoutSubviews() {
		
		connectToSpotifyLabel = UILabel(frame: CGRect(x: 0, y: view.frame.height * 0.2, width: view.frame.width * 0.9, height: 29))
		connectToSpotifyLabel.center = CGPoint(x: view.center.x, y: connectToSpotifyLabel.center.y)
		connectToSpotifyLabel.text = "Connect to Spotify"
		connectToSpotifyLabel.textColor = .white
		connectToSpotifyLabel.font = UIFont(name: "AvenirNext-Regular", size: 29)
		connectToSpotifyLabel.textAlignment = .center
		
		connectToSpotifyImageView = UIImageView(frame: CGRect(x: 0, y: connectToSpotifyLabel.frame.bottom.y + 50, width: view.frame.width * 0.5, height: view.frame.width * 0.5))
		connectToSpotifyImageView.center = CGPoint(x: view.center.x, y: connectToSpotifyImageView.center.y)
		connectToSpotifyImageView.clipsToBounds = true
		connectToSpotifyImageView.contentMode = .scaleAspectFit
		connectToSpotifyImageView.image = UIImage(named: "spotify-connect")
		
		connectToSpotifyButton = UIButton(frame: CGRect(x: 0, y: 0, width: view.frame.width * 0.7, height: 60))
		connectToSpotifyButton.frame.bottom = CGPoint(x: view.center.x, y: view.frame.height - view.frame.width * 0.2)
		connectToSpotifyButton.backgroundColor = UIColor.spotifyGreen
		connectToSpotifyButton.setTitle("Connect to Spotify", for: .normal)
		connectToSpotifyButton.setTitleColor(.white, for: .normal)
		connectToSpotifyButton.layer.cornerRadius = 5
		connectToSpotifyButton.addTarget(self, action: #selector(connectToSpotifyButtonPressed), for: .touchUpInside)
		
		descriptionLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width * 0.8, height: 20))
		descriptionLabel.center = CGPoint(x: view.center.x, y: connectToSpotifyImageView.frame.bottom.y + (connectToSpotifyButton.frame.top.y - connectToSpotifyImageView.frame.bottom.y) / 2)
		descriptionLabel.text = "Add songs to your Spotify library"
		descriptionLabel.textAlignment = .center
		descriptionLabel.textColor = .white
		descriptionLabel.font = UIFont(name: "AvenirNext-Regular", size: 16)

		skipThisStepButton = UIButton(frame: CGRect(x: 0, y: connectToSpotifyButton.frame.bottom.y + 20, width: view.frame.width * 0.7, height: 17))
		skipThisStepButton.center = CGPoint(x: view.center.x, y: skipThisStepButton.center.y)
		skipThisStepButton.setTitle("Skip This Step", for: .normal)
		skipThisStepButton.setTitleColor(.lightGray, for: .normal)
		skipThisStepButton.addTarget(self, action: #selector(skipThisStepButtonPressed), for: .touchUpInside)
		
		view.addSubview(connectToSpotifyLabel)
		view.addSubview(connectToSpotifyImageView)
		view.addSubview(descriptionLabel)
		view.addSubview(connectToSpotifyButton)
		view.addSubview(skipThisStepButton)

	}
	
	func connectToSpotifyButtonPressed() {
		SpotifyController.sharedController.loginToSpotify { (success: Bool) in
			if success {
				self.setSpotifyUserAndContinue()
			}
		}
	}
	
	func skipThisStepButtonPressed() {
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		appDelegate.toggleRootVC()
	}

	func setSpotifyUserAndContinue() {
		if let session = SPTAuth.defaultInstance().session, session.isValid() {
			SpotifyController.sharedController.setSpotifyUser(session.accessToken)

			delegate?.spotifyLoginViewController(spotifyLoginViewController: self, didFinishLoggingInWithAccessToken: session.accessToken)
		}
	}
	
	
}
