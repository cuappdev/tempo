
import UIKit

protocol LoginFlowViewControllerDelegate: class {
	func didFinishLoggingIn()
}

class LoginFlowViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
	
	var pageViewController: UIPageViewController!
	
	var facebookLoginViewController: FacebookLoginViewController!
	var createUsernameViewController: CreateUsernameViewController!
	var spotifyLoginViewController: SpotifyLoginViewController!
	
	var pages = [UIViewController]()
	
	weak var delegate: LoginFlowViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

		pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
		pageViewController.dataSource = self
		pageViewController.delegate = self
		
		facebookLoginViewController = FacebookLoginViewController()
		facebookLoginViewController.delegate = self
		
		createUsernameViewController = CreateUsernameViewController()
		createUsernameViewController.delegate = self
		
		spotifyLoginViewController = SpotifyLoginViewController(nibName: "SpotifyLoginViewController", bundle: nil)
		spotifyLoginViewController.delegate = self
		
		pages = [facebookLoginViewController, createUsernameViewController, spotifyLoginViewController]
		
		pageViewController.setViewControllers([facebookLoginViewController], direction: .forward, animated: false, completion: nil)
		pageViewController.disablePageViewControllerSwipeGesture()
		
		addChildViewController(pageViewController)
		view.addSubview(pageViewController.view)
		pageViewController.didMove(toParentViewController: self)
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		return nil
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		
		if let index = pages.index(of: viewController), index < pages.count - 1 {
			return pages[index + 1]
		}
		
		return nil
	}

	func presentationCount(for pageViewController: UIPageViewController) -> Int {
		return pages.count
	}
	
	func presentationIndex(for pageViewController: UIPageViewController) -> Int {
		return 0
	}
}

extension LoginFlowViewController: FacebookLoginViewControllerDelegate {
	
	func facebookLoginViewController(facebookLoginViewController: FacebookLoginViewController, didFinishLoggingInWithNewUserNamed name: String, withFacebookID fbid: String) {
		
		createUsernameViewController.name = name
		createUsernameViewController.fbid = fbid
		pageViewController.setViewControllers([createUsernameViewController], direction: .forward, animated: true, completion: nil)
		
	}
	
	func facebookLoginViewController(facebookLoginViewController: FacebookLoginViewController, didFinishLoggingInWithPreviouslyRegisteredUserNamed name: String, withFacebookID fbid: String) {
		delegate?.didFinishLoggingIn()
	}
}

extension LoginFlowViewController: CreateUsernameViewControllerDelegate {
	
	func createUsernameViewController(createUsernameViewController: CreateUsernameViewController, didFinishCreatingUsername username: String) {
		pageViewController.setViewControllers([spotifyLoginViewController], direction: .forward, animated: true, completion: nil)
	}
	
}

extension LoginFlowViewController: SpotifyLoginViewControllerDelegate {
	
	func spotifyLoginViewController(spotifyLoginViewController: SpotifyLoginViewController, didFinishLoggingInWithAccessToken token: String) {
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
		appDelegate.toggleRootVC()
	}
	
}

extension UIPageViewController {
	
	func disablePageViewControllerSwipeGesture() {
		for subview in view.subviews {
			if let scrollView = subview as? UIScrollView {
				scrollView.isScrollEnabled = false
			}
		}
	}
}
