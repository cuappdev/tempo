
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
	var newUsernameTextField: TextField!
	var continueButton: UIButton!
	var alertImageView: UIImageView!
	var alertLabel: UILabel!
	
	var fbid: String = ""
	var name: String = "Dennis Fedorko"
	var validUsername: Bool = false
	
	weak var delegate: CreateUsernameViewControllerDelegate?
	
    override func viewDidLoad() {
        super.viewDidLoad()

		view.backgroundColor = .tempoOnboardingGray
        layoutSubviews()
    }

	func layoutSubviews() {
		let contentWidth = view.frame.width * 0.736
		
		createUsernameLabel = UILabel(frame: CGRect(x: 0, y: view.frame.height * 0.093, width: view.frame.width * 0.84, height: 22))
		createUsernameLabel.text = "New user? Create a username!"
		createUsernameLabel.textColor = .tempoGray
		createUsernameLabel.font = UIFont(name: "AvenirNext-Regular", size: 18.0)
		createUsernameLabel.textAlignment = .center
		createUsernameLabel.sizeToFit()
		createUsernameLabel.center.x = view.center.x
		
		profileNameLabel = UILabel(frame: CGRect(x: 0, y: view.frame.height * 0.187, width: contentWidth, height: 22))
		profileNameLabel.text = name
		profileNameLabel.textColor = .white
		profileNameLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 22.0)
		profileNameLabel.textAlignment = .center
		profileNameLabel.sizeToFit()
		profileNameLabel.center.x = view.center.x
		
		profileImageView = UIImageView(frame: CGRect(x: 0, y: view.frame.height * 0.25, width: view.frame.width * 0.384, height: view.frame.width * 0.384))
		profileImageView.center.x = view.center.x
		profileImageView.layer.cornerRadius = profileImageView.frame.width / 2.0
		profileImageView.clipsToBounds = true
		profileImageView.contentMode = .scaleAspectFill
		setProfileImage()
		
		profileUsernameLabel = UILabel(frame: CGRect(x: 0, y: view.frame.height * 0.486, width: contentWidth, height: 22))
		profileUsernameLabel.center.x = view.center.x
		profileUsernameLabel.text = ""
		profileUsernameLabel.textColor = .white
		profileUsernameLabel.font = UIFont(name: "AvenirNext-Regular", size: 16.0)
		profileUsernameLabel.textAlignment = .center
		
		newUsernameLabel = UILabel(frame: CGRect(x: 0, y: view.frame.height * 0.594, width: contentWidth, height: 22))
		newUsernameLabel.center.x = view.center.x
		newUsernameLabel.text = "New Username"
		newUsernameLabel.textColor = .white
		newUsernameLabel.font = UIFont(name: "AvenirNext-Regular", size: 16.0)
		newUsernameLabel.textAlignment = .left
		
		newUsernameTextField = TextField(frame: CGRect(x: 0, y: view.frame.height * 0.64, width: contentWidth, height: view.frame.height * 0.069))
		newUsernameTextField.center.x = view.center.x
		newUsernameTextField.autocorrectionType = .no
		newUsernameTextField.autocapitalizationType = .none
		newUsernameTextField.keyboardType = .alphabet
		newUsernameTextField.placeholder = "@username"
		newUsernameTextField.backgroundColor = .usernameBGGrey
		newUsernameTextField.textColor = UIColor.tempoDarkGray
		newUsernameTextField.font = UIFont(name: "AvenirNext-Regular", size: 17.0)
		newUsernameTextField.textAlignment = .left
		newUsernameTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
		newUsernameTextField.delegate = self
		
		alertImageView = UIImageView(frame: CGRect(x: newUsernameTextField.frame.minX, y: (view.frame.height * 0.73) - 1, width: 22, height: 22))
		
		alertLabel = UILabel(frame: CGRect(x: alertImageView.frame.maxX + 8, y: view.frame.height * 0.73, width: contentWidth - (alertImageView.frame.width + 8), height: 20))
		alertLabel.textColor = .wrongRed
		alertLabel.font = UIFont(name: "AvenirNext-Medium", size: 16.0)
		alertLabel.textAlignment = .left
		alertLabel.numberOfLines = 3

		continueButton = UIButton(frame: CGRect(x: 0, y: view.frame.height * 0.858, width: contentWidth, height: view.frame.height * 0.09))
		continueButton.center.x = view.center.x
		continueButton.backgroundColor = .tempoRed
		continueButton.setTitle("Continue", for: .normal)
		continueButton.setTitleColor(.buttonGrey, for: .normal)
		continueButton.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 17.0)
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
		view.addSubview(alertImageView)
		view.addSubview(alertLabel)
		view.addSubview(continueButton)
		
		checkUsername()
	}
	
	func pressButton(){
		continueButton.alpha = 0.5
	}
	
	func releaseButton(){
		continueButton.alpha = 1.0
	}

	func setProfileImage() {
		guard let imageUrl = URL(string: "http://graph.facebook.com/\(fbid)/picture?type=large") else { return }
		profileImageView.hnk_setImageFromURL(imageUrl)
	}
	
	func updateAlert(correct: Bool, message: String) {
		let alertLabelWidth = alertLabel.frame.width
		alertLabel.text = message
		alertLabel.sizeToFit()
		alertLabel.frame.size.width = alertLabelWidth
		
		alertImageView.image = (message != "") ? (correct ? #imageLiteral(resourceName: "CorrectIcon") : #imageLiteral(resourceName: "WrongIcon")) : nil
		alertLabel.textColor = correct ? .correctGreen : .wrongRed
		continueButton.alpha = correct ? 1.0 : 0.5
		continueButton.isUserInteractionEnabled = correct
	}
	
	func checkUsername() {
		guard let usernameText = newUsernameTextField.text?.lowercased() else { print("No Username"); return}
		let username = usernameText.substring(from: usernameText.startIndex)
		
		let charSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_").inverted
		let invalidChars = username.rangeOfCharacter(from: charSet)
		
		if username == "" {
			updateAlert(correct: false, message: "")
		} else if invalidChars != nil { // Username contains some invalid characters
			updateAlert(correct: false, message: "Username can only contain underscores and alphanumeric characters.")
		} else if username.characters.count > 18 {
			updateAlert(correct: false, message: "Username exceeds 18 characters limit.")
		} else { // Username contains only valid characters
			updateAlert(correct: true, message: "")
		}
	}
	
	func textFieldDidChange(textField: UITextField) {
		if let username = textField.text {
			profileUsernameLabel.text = (username == "") ? "" : "@\(username)"
			checkUsername()
		}
	}
	
	func continueButtonPressed() {
		guard let usernameText = newUsernameTextField.text?.lowercased() else { print("No Username"); return}
		let username = usernameText.substring(from: usernameText.startIndex)
		
		API.sharedAPI.usernameIsValid(username) { success in
			if success { // Username available
				self.updateAlert(correct: true, message: "Username is available.")
				API.sharedAPI.updateCurrentUser(username, didSucceed: { (success) in
					if success {
						self.delegate?.createUsernameViewController(createUsernameViewController: self, didFinishCreatingUsername: username)
					} else {
						self.updateAlert(correct: true, message: "Username could not be created. Please try again.")
					}
				})
			} else { // Username already taken
				self.updateAlert(correct: false, message: "Username is not available.")
			}
		}
	}

}

extension CreateUsernameViewController: UITextFieldDelegate, UINavigationControllerDelegate {
	
	func animateImageView(hidden: Bool) {
		if hidden {
			UIView.animate(withDuration: 1.0) {
				self.profileImageView.alpha = 0
			}
		} else {
			UIView.animate(withDuration: 1.0) {
				self.profileImageView.alpha = 1.0
			}
		}
	}
	
	func keyboardWillShow(sender: NSNotification) {
		animateImageView(hidden: true)
		if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
			let keyboardHeight = keyboardSize.height
			UIView.animate(withDuration: 0.2, animations: { 
				self.view.frame.origin.y = -keyboardHeight
			})
		}
	}
	
	func keyboardWillHide(sender: NSNotification) {
		animateImageView(hidden: false)
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

class TextField: UITextField {
	
	let padding = UIEdgeInsets(top: 0, left: 7.5, bottom: 0, right: 10);
	
	override func textRect(forBounds bounds: CGRect) -> CGRect {
		return UIEdgeInsetsInsetRect(bounds, padding)
	}
	
	override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
		return UIEdgeInsetsInsetRect(bounds, padding)
	}
	
	override func editingRect(forBounds bounds: CGRect) -> CGRect {
		return UIEdgeInsetsInsetRect(bounds, padding)
	}
}
