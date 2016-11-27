
import UIKit

protocol SpotifyLoginViewControllerDelegate: class {
	
	func spotifyLoginViewController(spotifyLoginViewController: SpotifyLoginViewController, didFinishLoggingInWithAccessToken token: String)
	
}

class SpotifyLoginViewController: UIViewController {

    @IBOutlet weak var connectButton: UIButton!
	
	weak var delegate: SpotifyLoginViewControllerDelegate?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		connectButton.layer.cornerRadius = 5
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
	
    @IBAction func connectToSpotify(_ sender: UIButton) {
		SpotifyController.sharedController.loginToSpotify { (success: Bool) in
			if success {
				self.setSpotifyUserAndContinue()
			}
		}
    }

    @IBAction func skipSpotify(_ sender: UIButton) {
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
