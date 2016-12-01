
import UIKit
import Haneke

protocol CreateUsernameViewControllerDelegate: class {
	
	func createUsernameViewController(createUsernameViewController: CreateUsernameViewController, didFinishCreatingUsername username: String)
}

class CreateUsernameViewController: UIViewController {
	
	var createUsernameLabel: UILabel!
	var profileNameLabel: UILabel!
	var profileImageView: UIImageView!
	var profileUsernameLabel: UILabel!
	var newUsernameLabel: UILabel!
	var newUsernameTextField: UITextField!
	var continueButton: UIButton!
	var alertLabel: UILabel!
	
	var fbid: String = ""
	var name: String = "Dennis Fedorko"
	
	weak var delegate: CreateUsernameViewControllerDelegate?
	
    override func viewDidLoad() {
        super.viewDidLoad()

        layoutSubviews()
    }

	func layoutSubviews() {
		
		createUsernameLabel = UILabel(frame: CGRect(x: 0, y: view.frame.height * 0.1, width: view.frame.width * 0.9, height: 20))
		createUsernameLabel.center = CGPoint(x: view.center.x, y: createUsernameLabel.center.y)
		createUsernameLabel.text = "New user? Create a username!"
		createUsernameLabel.textColor = .white
		createUsernameLabel.font = UIFont(name: "AvenirNext-Regular", size: 16)
		createUsernameLabel.textAlignment = .center
		
		profileNameLabel = UILabel(frame: CGRect(x: 0, y: createUsernameLabel.frame.bottom.y + 40, width: view.frame.width * 0.9, height: 20))
		profileNameLabel.center = CGPoint(x: view.center.x, y: profileNameLabel.center.y)
		profileNameLabel.text = name
		profileNameLabel.textColor = .white
		profileNameLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
		profileNameLabel.textAlignment = .center
		
		profileImageView = UIImageView(frame: CGRect(x: 0, y: profileNameLabel.frame.bottom.y + 15, width: view.frame.height * 0.2, height: view.frame.height * 0.2))
		profileImageView.center = CGPoint(x: view.center.x, y: profileImageView.center.y)
		profileImageView.layer.cornerRadius = profileImageView.frame.width / 2.0
		profileImageView.clipsToBounds = true
		profileImageView.contentMode = .scaleAspectFill
		setProfileImage()
		
		profileUsernameLabel = UILabel(frame: CGRect(x: 0, y: profileImageView.frame.bottom.y + 15, width: view.frame.width * 0.8, height: 16))
		profileUsernameLabel.center = CGPoint(x: view.center.x, y: profileUsernameLabel.center.y)
		profileUsernameLabel.text = ""
		profileUsernameLabel.textColor = .white
		profileUsernameLabel.font = UIFont(name: "AvenirNext-Regular", size: 16)
		profileUsernameLabel.textAlignment = .center
		
		newUsernameLabel = UILabel(frame: CGRect(x: 0, y: profileUsernameLabel.frame.bottom.y + view.frame.height * 0.05, width: view.frame.width * 0.7, height: 16))
		newUsernameLabel.center = CGPoint(x: view.center.x, y: newUsernameLabel.center.y)
		newUsernameLabel.text = "New Username"
		newUsernameLabel.textColor = .white
		newUsernameLabel.font = UIFont(name: "AvenirNext-Regular", size: 16)
		newUsernameLabel.textAlignment = .left
		
		newUsernameTextField = UITextField(frame: CGRect(x: 0, y: newUsernameLabel.frame.bottom.y + 10, width: view.frame.width * 0.7, height: view.frame.height * 0.07))
		newUsernameTextField.autocorrectionType = .no
		newUsernameTextField.autocapitalizationType = .none
		newUsernameTextField.keyboardType = .alphabet
		newUsernameTextField.center = CGPoint(x: view.center.x, y: newUsernameTextField.center.y)
		newUsernameTextField.placeholder = "@username"
		newUsernameTextField.backgroundColor = .lightGray
		newUsernameTextField.textColor = UIColor.tempoDarkGray
		newUsernameTextField.font = UIFont(name: "AvenirNext-Regular", size: 16)
		newUsernameTextField.textAlignment = .left
		newUsernameTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
		newUsernameTextField.delegate = self
		
		alertLabel = UILabel(frame: CGRect(x: 0, y: newUsernameTextField.frame.bottom.y + 10, width: view.frame.width * 0.7, height: 16))
		alertLabel.center = CGPoint(x: view.center.x, y: alertLabel.center.y)
		alertLabel.textColor = .red
		alertLabel.font = UIFont(name: "AvenirNext-Regular", size: 16)
		alertLabel.textAlignment = .center
		alertLabel.lineBreakMode = .byWordWrapping
		alertLabel.numberOfLines = 0

		continueButton = UIButton(frame: CGRect(x: 0, y: 0, width: view.frame.width * 0.7, height: 60))
		continueButton.frame.bottom = CGPoint(x: view.center.x, y: view.frame.height - view.frame.width * 0.15)
		continueButton.backgroundColor = UIColor.tempoLightRed
		continueButton.setTitle("Continue", for: .normal)
		continueButton.setTitleColor(.white, for: .normal)
		continueButton.layer.cornerRadius = 5
		continueButton.addTarget(self, action: #selector(continueButtonPressed), for: .touchUpInside)
		continueButton.addTarget(self, action: #selector(pressButton), for: .touchDown)
		continueButton.addTarget(self, action: #selector(releaseButton), for: .touchDragExit)
		
		view.addSubview(createUsernameLabel)
		view.addSubview(profileNameLabel)
		view.addSubview(profileImageView)
		view.addSubview(profileUsernameLabel)
		view.addSubview(newUsernameLabel)
		view.addSubview(newUsernameTextField)
		view.addSubview(alertLabel)
		view.addSubview(continueButton)
		
	}
	
	func pressButton(){
		continueButton.alpha = 0.8
	}
	
	func releaseButton(){
		continueButton.alpha = 1.0
	}

	func setProfileImage() {
		guard let imageUrl = URL(string: "http://graph.facebook.com/\(fbid)/picture?type=large") else { return }
		profileImageView.hnk_setImageFromURL(imageUrl)
	}
	
	func textFieldDidChange(textField: UITextField) {
		if let username = textField.text {
			if username == ""{
				profileUsernameLabel.text = ""
			}
			else{
				profileUsernameLabel.text = "@\(username)"
			}
		}
	}
	
	func continueButtonPressed() {
		continueButton.alpha = 1.0
		guard let usernameText = newUsernameTextField.text?.lowercased() else { print("No Username"); return}
		let username = usernameText.substring(from: usernameText.startIndex)
		
		let charSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_").inverted
		let invalidChars = username.rangeOfCharacter(from: charSet)
		
		if username == "" {
			alertLabel.text = "Username must have at least one character."
			alertLabel.textColor = UIColor.red
		} else if invalidChars != nil { // Username contains some invalid characters
			alertLabel.text = "Only underscores and alphanumeric characters allowed."
			alertLabel.textColor = UIColor.red
		} else if username.characters.count > 18 {
			alertLabel.text = "Username is too long."
			alertLabel.textColor = UIColor.red
		} else { // Username contains only valid characters
			API.sharedAPI.usernameIsValid(username) { success in
				if success { // Username available
					API.sharedAPI.updateCurrentUser(username, didSucceed: { (success) in
						if success {
							self.delegate?.createUsernameViewController(createUsernameViewController: self, didFinishCreatingUsername: username)
						} else {
							self.alertLabel.text = "Username failed to update. Try again."
							self.alertLabel.textColor = .red
						}
					})
				} else { // Username already taken
					self.alertLabel.text = "Username unavailable."
					self.alertLabel.textColor = .red
				}
			}
		}
	}
}

extension CreateUsernameViewController: UITextFieldDelegate, UINavigationControllerDelegate {
	
	func animateImageView(){
		
		if profileImageView.alpha != 0{
			UIView.animate(withDuration: 1.0) {
				self.profileImageView.alpha = 0
			}
		} else{
			UIView.animate(withDuration: 1.0) {
				self.profileImageView.alpha = 1.0
			}
		}
	}
	
	func keyboardWillShow(sender: NSNotification) {
		animateImageView()
		if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
			let keyboardHeight = keyboardSize.height
			UIView.animate(withDuration: 0.2, animations: { 
				self.view.frame.origin.y = -keyboardHeight
			})
		}
	}
	
	func keyboardWillHide(sender: NSNotification) {
		animateImageView()
		UIView.animate(withDuration: 0.2, animations: {
			self.view.frame.origin.y = 0
		})
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		view.endEditing(true)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: .UIKeyboardWillHide, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: .UIKeyboardWillShow, object: nil)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
		NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
	}
}
