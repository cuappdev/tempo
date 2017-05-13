//
//  ProfileTabbedPageViewController.swift
//  Tempo
//
//  Created by Logan Allen on 5/13/17.
//  Copyright © 2017 CUAppDev. All rights reserved.
//

import UIKit

class ProfileTabbedPageViewController: UIViewController, UIPageViewControllerDelegate,UIPageViewControllerDataSource, UnderlineTabBarDelegate {
	
	var viewControllers: [UIViewController]!
	var underlineTabBar: UnderlineTabBarView!
	
	var pageViewController: UIPageViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
		
		view.backgroundColor = .tempoOffBlack
		
		underlineTabBar = UnderlineTabBarView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
		underlineTabBar.setupTabBar()
		underlineTabBar.delegate = self
		view.addSubview(underlineTabBar)
		
		// Page view controller
		pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
		pageViewController.view.backgroundColor = .white
		let pageVCYOffset: CGFloat = underlineTabBar.frame.bottom.y
		let pageVCHeight = view.frame.height - pageVCYOffset - 44 - 20
		pageViewController.view.frame = CGRect(x: 0, y: pageVCYOffset, width: view.frame.width, height: pageVCHeight)
		
		pageViewController.dataSource = self
		pageViewController.delegate = self
		pageViewController.setViewControllers([viewControllers[1]], direction: .forward, animated: false, completion: nil)
		
		addChildViewController(pageViewController)
		view.addSubview(pageViewController.view)
		pageViewController.didMove(toParentViewController: self)
		view.bringSubview(toFront: underlineTabBar)

        // Do any additional setup after loading the view.
    }
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		let index = viewControllers.index(of: viewController)!
		
		guard index != 0 else { return nil }
		
		return viewControllers[index - 1]
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		let index = viewControllers.index(of: viewController)!
		
		guard index != viewControllers.count - 1 else { return nil }
		
		return viewControllers[index + 1]
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
//		let currentViewController = pageViewController.viewControllers!.first! as! MealTableViewController
//		let index = viewControllers.index(of: currentViewController)!
//		tabDelegate?.selectedTabDidChange(index)
//		scrollDelegate?.scrollViewDidChange()
//		
//		updateActiveScrollView(index)
	}
	
	// MARK: - Underline Tab Bar Delegate Method
	func selectedTabBarDidChange(_ newIndex: Int) {
		print("Show new VC for \(newIndex)")

//		let currentViewController = pageViewController.viewControllers!.first! as! MealTableViewController
//		let currentIndex = viewControllers.index(of: currentViewController)!
//		
//		guard newIndex != currentIndex else { return }
//		
//		var direction: UIPageViewControllerNavigationDirection = .forward
//		if newIndex < currentIndex {
//			direction = .reverse
//		}
//		pageViewController.setViewControllers([viewControllers[newIndex]], direction: direction, animated: true, completion: nil)
//		
//		scrollDelegate?.scrollViewDidChange()
	}

}
