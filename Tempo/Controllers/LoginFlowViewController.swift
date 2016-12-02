
import UIKit

protocol LoginFlowViewControllerDelegate: class {
	func didFinishLoggingIn()
}

class LoginFlowViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
	
	let pageVCOffset: CGFloat = 40
	
	var pageViewController: UIPageViewController!
	
	var facebookLoginViewController: FacebookLoginViewController!
	var createUsernameViewController: CreateUsernameViewController!
	var spotifyLoginViewController: SpotifyLoginViewController!
	
	var pages = [UIViewController]()
	var pageControl: UIPageControl?
	
	weak var delegate: LoginFlowViewControllerDelegate?
	
	var currentlyDisplayingPageIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
		
		view.backgroundColor = .clear

		pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
		pageViewController.dataSource = self
		pageViewController.delegate = self
		
		facebookLoginViewController = FacebookLoginViewController()
		facebookLoginViewController.delegate = self
		
		createUsernameViewController = CreateUsernameViewController()
		createUsernameViewController.delegate = self
		
		spotifyLoginViewController = SpotifyLoginViewController()
		spotifyLoginViewController.delegate = self
		
		pages = [facebookLoginViewController, createUsernameViewController, spotifyLoginViewController]
		
		pageViewController.setViewControllers([facebookLoginViewController], direction: .forward, animated: false, completion: nil)
		
		// Disable swiping and hide page control
		pageViewController.disablePageViewControllerSwipeGesture()
		pageViewController.view.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height + pageVCOffset)
		pageViewController.hidePageControl()
		
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
		return currentlyDisplayingPageIndex
	}
}

extension LoginFlowViewController: FacebookLoginViewControllerDelegate {
	
	func facebookLoginViewController(facebookLoginViewController: FacebookLoginViewController, didFinishLoggingInWithNewUserNamed name: String, withFacebookID fbid: String) {
		
		createUsernameViewController.name = name
		createUsernameViewController.fbid = fbid
		currentlyDisplayingPageIndex += 1
		pageViewController.setViewControllers([createUsernameViewController], direction: .forward, animated: true, completion: nil)
		
	}
	
	func facebookLoginViewController(facebookLoginViewController: FacebookLoginViewController, didFinishLoggingInWithPreviouslyRegisteredUserNamed name: String, withFacebookID fbid: String) {
		delegate?.didFinishLoggingIn()
	}
}

extension LoginFlowViewController: CreateUsernameViewControllerDelegate {
	
	func createUsernameViewController(createUsernameViewController: CreateUsernameViewController, didFinishCreatingUsername username: String) {
		currentlyDisplayingPageIndex += 1
		pageViewController.setViewControllers([spotifyLoginViewController], direction: .forward, animated: true, completion: nil)
	}
	
}

extension LoginFlowViewController: SpotifyLoginViewControllerDelegate {
	
	func spotifyLoginViewController(spotifyLoginViewController: SpotifyLoginViewController, didFinishLoggingIntoSpotifyWithAccessToken token: String?) {
		delegate?.didFinishLoggingIn()
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
	
	func hidePageControl() {
		for subview in view.subviews {
			if subview is UIPageControl {
				subview.isHidden = true
			}
		}
	}

}
