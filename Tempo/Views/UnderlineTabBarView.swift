//
//  UnderlineTabBarView.swift
//  Tempo
//
//  Created by Logan Allen on 5/13/17.
//  Copyright © 2017 CUAppDev. All rights reserved.
//

import UIKit

protocol UnderlineTabBarDelegate {
	func selectedTabBarDidChange(_ newIndex: Int)
}

class UnderlineTabBarView: UIView {
	
	var delegate: UnderlineTabBarDelegate?
	var tabBarHeight: CGFloat = 50
	
	var buttons: [UIButton]!
	var underlineView: UIView!
	
	var currentIndex = 0 {
		didSet {
			if currentIndex != oldValue {
				updateTabBarButtons()
				delegate?.selectedTabBarDidChange(currentIndex)
			}
		}
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		backgroundColor = .tempoOffBlack
		setupTabBar()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setupTabBar() {
		
		let fontSize = iPhone5 ? 11.0 : 13.0
			
		// Buttons Container View
//		buttonsContainerView = UIView(frame: CGRect(x: 0, y: profileContainerView.frame.maxY, width: bounds.width, height: tabBarHeight))
		
		let buttonWidth = bounds.width / 3.0
		let buttonFont = UIFont(name: "AvenirNext-Medium", size: CGFloat(fontSize))
		
		let postsButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: tabBarHeight))
		postsButton.setTitle("POSTS", for: .normal)
		postsButton.setTitleColor(.redTintedWhite, for: .normal)
		postsButton.setTitleColor(.tempoRed, for: .selected)
		postsButton.titleLabel?.font = buttonFont
		postsButton.titleLabel?.textAlignment = .center
		postsButton.addTarget(self, action: #selector(tabBarButtonPressed(_:)), for: .touchUpInside)
		
		let calendarButton = UIButton(frame: CGRect(x: buttonWidth, y: 0, width: buttonWidth, height: tabBarHeight))
		calendarButton.setTitle("CALENDAR", for: .normal)
		calendarButton.setTitleColor(.redTintedWhite, for: .normal)
		calendarButton.setTitleColor(.tempoRed, for: .selected)
		calendarButton.titleLabel?.font = buttonFont
		calendarButton.titleLabel?.textAlignment = .center
		calendarButton.addTarget(self, action: #selector(tabBarButtonPressed(_:)), for: .touchUpInside)
		
		let likesButton = UIButton(frame: CGRect(x: 2 * buttonWidth, y: 0, width: buttonWidth, height: tabBarHeight))
		likesButton.setTitle("LIKES", for: .normal)
		likesButton.setTitleColor(.redTintedWhite, for: .normal)
		likesButton.setTitleColor(.tempoRed, for: .selected)
		likesButton.titleLabel?.font = buttonFont
		likesButton.titleLabel?.textAlignment = .center
		likesButton.addTarget(self, action: #selector(tabBarButtonPressed(_:)), for: .touchUpInside)
		
		underlineView = UIView(frame: CGRect(x: 0, y: tabBarHeight - 12.0, width: buttonWidth * 2.0 / 3.0, height: 2.0))
		underlineView.center.x = center.x
		underlineView.backgroundColor = .tempoRed
		
		buttons = [postsButton, calendarButton, likesButton]
		addSubview(postsButton)
		addSubview(calendarButton)
		addSubview(likesButton)
		addSubview(underlineView)
		
		currentIndex = 1
	}
	
	func tabBarButtonPressed(_ sender: UIButton) {
		if let index = buttons.index(of: sender) {
			currentIndex = index
		}
	}
	
	func updateTabBarButtons() {
		for i in 0...2 {
			buttons[i].isSelected = (currentIndex == i)
		}
		
		UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
			self.underlineView.center.x = self.buttons[self.currentIndex].center.x
		}, completion: nil)
	}

}
