import UIKit
import SafariServices

class SettingsViewController: UIViewController {
	
	let buttonHeight: CGFloat = 50

	@IBOutlet weak var loginToSpotifyButton: UIButton!
	@IBOutlet weak var goToSpotifyButton: UIButton!
	@IBOutlet weak var logOutSpotifyButton: UIButton!
	@IBOutlet weak var toggleNotifications: UISwitch!
	@IBOutlet weak var useLabel: UILabel!
	@IBOutlet weak var logOutButtonHeight: NSLayoutConstraint!
	@IBOutlet weak var toggleMusicOnExit: UISwitch!
	
	static let registeredForRemotePushNotificationsKey = "SettingsViewController.registeredForRemotePushNotificationsKey"
	static let presentedAlertForRemotePushNotificationsKey = "SettingsViewController.presentedAlertForRemotePushNotificationsKey"
	var shouldAddHamburger = true

	var safariViewController: SFSafariViewController?

	override func viewDidLoad() {
		super.viewDidLoad()

		toggleNotifications.onTintColor = .tempoRed
		toggleMusicOnExit.onTintColor = .tempoRed
		
		updateSpotifyState()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		updateSpotifyState()
		toggleNotifications.setOn(User.currentUser.remotePushNotificationsEnabled, animated: false)
		toggleMusicOnExit.setOn(UserDefaults.standard.bool(forKey: "music_on_off"), animated: false)
		
		if shouldAddHamburger {
			addHamburgerMenu()
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		title = "Settings"
		view.backgroundColor = .readCellColor
		
		updateSpotifyState()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		//add HamburgerMenu by default, unless shouldAddHamburger is explicitly changed
		shouldAddHamburger = true
	}
	
	// Can be called after successful login to Spotify SDK
	func updateSpotifyState() {

		safariViewController?.dismiss(animated: true, completion: nil)

		if UserDefaults.standard.bool(forKey: "spotify-connected") {
			self.loggedInToSpotify(true)
		}

	}
	
	func loggedInToSpotify(_ loggedIn: Bool) {
		loginToSpotifyButton?.isHidden = loggedIn
		useLabel.text = loggedIn ? "Logged in to Spotify" : "Login in to allow Tempo to add songs you find to your Spotify"
		goToSpotifyButton?.isHidden = !loggedIn
		logOutButtonHeight.constant = loggedIn ? 50 : 0
		logOutSpotifyButton?.isHidden = !loggedIn
	}
	
	@IBAction func loginToSpotify() {
		GetSpotifyLoginURI().make()
			.then { uri -> Void in
				if let url = URL(string: uri) {
					let safariViewController = SFSafariViewController(url: url)
					self.present(safariViewController, animated: true, completion: nil)
					self.safariViewController = safariViewController
				}
			}
			.catch { error in
				print(error)
			}
	}
	
	func showPromptIfPushNotificationsDisabled() {
		let alertController = UIAlertController(title: "Push Notifications Disabled", message: "Please enable push notifications for Tempo in the Settings app", preferredStyle: .alert)
		
		let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
			if let url = URL(string:UIApplicationOpenSettingsURLString) {
				UIApplication.shared.openURL(url)
			}
		})
		
		alertController.addAction(okAction)
		
		present(alertController, animated: true, completion: nil)
	}
	
	@IBAction func toggledNotifications(_ sender: UISwitch) {
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let didRegisterForPushNotifications = UserDefaults.standard.bool(forKey: SettingsViewController.registeredForRemotePushNotificationsKey)
		let didPresentAlertForPushNotifications = UserDefaults.standard.bool(forKey: SettingsViewController.presentedAlertForRemotePushNotificationsKey)

		if didPresentAlertForPushNotifications && !UIApplication.shared.isRegisteredForRemoteNotifications && sender.isOn {
			sender.setOn(false, animated: false)
			showPromptIfPushNotificationsDisabled()
			return
		}
		
		if sender.isOn && UserDefaults.standard.data(forKey: AppDelegate.remotePushNotificationsDeviceTokenKey) == nil {
			appDelegate.registerForRemotePushNotifications()
			return
		}
		
		if let deviceToken = UserDefaults.standard.data(forKey: AppDelegate.remotePushNotificationsDeviceTokenKey), !didRegisterForPushNotifications {
			API.sharedAPI.registerForRemotePushNotificationsWithDeviceToken(deviceToken, completion: { _ in })
			return
		}
		
		let enabled = sender.isOn
		
		API.sharedAPI.toggleRemotePushNotifications(userID: User.currentUser.id, enabled: enabled, completion: { (success: Bool) in
			
			if !success {
				sender.setOn(!enabled, animated: true)
			}
		})
	}
	
	@IBAction func toggledMusicOnExit(_ sender: UISwitch) {
		let enabled = UserDefaults.standard.bool(forKey: "music_on_off")
		UserDefaults.standard.set(!enabled, forKey: "music_on_off")
		sender.setOn(UserDefaults.standard.bool(forKey: "music_on_off"), animated: true)
		//add logic to appdelegate to meet user's desired settings
	}
	
	@IBAction func goToSpotify(_ sender: UIButton) {
//		SpotifyController.sharedController.openSpotifyURL()
	}
	
	@IBAction func logOutSpotify(_ sender: UIButton) {
//		SpotifyController.sharedController.closeCurrentSpotifySession()
//		User.currentUser.currentSpotifyUser = nil
//		updateSpotifyState()
	}
}
