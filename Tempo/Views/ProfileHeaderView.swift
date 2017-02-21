//
//  ProfileHeaderView.swift
//  Tempo
//
//  Created by Annie Cheng on 12/5/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import Foundation
import UIKit

protocol ProfileHeaderViewDelegate {
	func hipsterScoreButtonPressed()
	func followersButtonPressed()
	func followingButtonPressed()
}

class ProfileHeaderView: UIView {
	
	let profileImageLength: CGFloat = 100
	let profileContainerHeight: CGFloat = 255
	let buttonsContainerHeight: CGFloat = 69
	let profileButtonHeight: CGFloat = 32
	let edgePadding: CGFloat = 22
	let buttonPadding: CGFloat = 10
	let dividerSize: CGSize = CGSize(width: 2, height: 44)
	
	var profileContainerView: UIView!
	var profileBackgroundImageView: UIImageView!
	var profileImageView: UIImageView!
	var nameLabel: UILabel!
	var usernameButton: UIButton!
	var profileButton: UIButton!
	
	var buttonsContainerView: UIView!
	var hipsterScoreLabel: UILabel!
	var hipsterScoreButton: UIButton!
	var followersLabel: UILabel!
	var followersButton: UIButton!
	var followingLabel: UILabel!
	var followingButton: UIButton!
	
	var delegate: ProfileHeaderViewDelegate?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		setUpProfileContainerView()
		setUpButtonsContainerView()
	}
	
	override func layoutSubviews() {
		
	}
	
	func setUpProfileContainerView() {
		profileContainerView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: profileContainerHeight))
		profileContainerView.backgroundColor = .unreadCellColor
		
		// TODO: Add initials view
		profileBackgroundImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: profileContainerView.frame.width, height: profileContainerView.frame.height))
		profileBackgroundImageView.center.x = profileContainerView.bounds.midX
		profileBackgroundImageView.clipsToBounds = true
		profileBackgroundImageView.contentMode = .scaleAspectFill
		profileBackgroundImageView.alpha = 0.05
		
		profileImageView = UIImageView(frame: CGRect(x: 0, y: 30, width: profileImageLength, height: profileImageLength))
		profileImageView.center.x = profileContainerView.bounds.midX
		profileImageView.layer.cornerRadius = profileImageView.frame.width / 2.0
		profileImageView.clipsToBounds = true
		profileImageView.contentMode = .scaleAspectFill
		
		nameLabel = UILabel(frame: CGRect(x: 0, y: profileImageView.frame.maxY + 16, width: bounds.width - 2*edgePadding, height: 23))
		nameLabel.center.x = profileContainerView.bounds.midX
		nameLabel.text = "Name"
		nameLabel.font = UIFont(name: "AvenirNext-Medium", size: 17.0)
		nameLabel.textColor = .redTintedWhite
		nameLabel.textAlignment = .center
		
		usernameButton = UIButton(frame: CGRect(x: 0, y: nameLabel.frame.maxY + 2, width: bounds.width - 2*edgePadding, height: 22))
		usernameButton.center.x = profileContainerView.bounds.midX
		usernameButton.setTitle("@username", for: .normal)
		usernameButton.setTitleColor(.paleRed, for: .normal)
		usernameButton.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 14.0)
		usernameButton.titleLabel?.textAlignment = .center
		usernameButton.addTarget(self, action: #selector(usernameButtonPressed(sender:)), for: .touchUpInside)
		
		profileButton = UIButton(frame: CGRect(x: 0, y: usernameButton.frame.maxY + 8, width: 90, height: profileButtonHeight))
		profileButton.center.x = profileContainerView.bounds.midX
		profileButton.setTitle("EDIT", for: .normal)
		profileButton.setTitleColor(.profileButtonGrey, for: .normal)
		profileButton.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 13.0)
		profileButton.layer.borderColor = UIColor.tempoRed.cgColor
		profileButton.layer.borderWidth = 1.5
		profileButton.layer.cornerRadius = 3
		profileButton.clipsToBounds = true
		
		profileContainerView.addSubview(profileBackgroundImageView)
		profileContainerView.addSubview(profileImageView)
		profileContainerView.addSubview(nameLabel)
		profileContainerView.addSubview(usernameButton)
		profileContainerView.addSubview(profileButton)
		addSubview(profileContainerView)
	}
	
	func setUpButtonsContainerView() {
		
		let fontSize = iPhone5 ? 11.0 : 13.0
		
		// Buttons Container View
		buttonsContainerView = UIView(frame: CGRect(x: 0, y: profileContainerView.frame.maxY, width: bounds.width, height: buttonsContainerHeight))
		buttonsContainerView.backgroundColor = .readCellColor
		
		let buttonWidth: CGFloat = (bounds.width - 2*dividerSize.width) / 3.0
		let labelHeight: CGFloat = 22
		let labelWidth: CGFloat = buttonWidth - 2*buttonPadding
		
		// Hipster Score Button
		hipsterScoreButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: buttonsContainerHeight))
		hipsterScoreButton.backgroundColor = .clear
		hipsterScoreButton.addTarget(self, action: #selector(hipsterScoreButtonPressed(sender:)), for: .touchUpInside)
		
		hipsterScoreLabel = UILabel(frame: CGRect(x: 0, y: 13, width: labelWidth, height: labelHeight))
		hipsterScoreLabel.center.x = hipsterScoreButton.bounds.midX
		hipsterScoreLabel.text = "-"
		hipsterScoreLabel.font = UIFont(name: "AvenirNext-Medium", size: 13.0)
		hipsterScoreLabel.textColor = .white
		hipsterScoreLabel.textAlignment = .center
		
		let hipsterSectionLabel = UILabel(frame: CGRect(x: 0, y: hipsterScoreLabel.frame.maxY, width: labelWidth, height: labelHeight))
		hipsterSectionLabel.center.x = hipsterScoreButton.bounds.midX
		
		hipsterSectionLabel.text = "HIPSTER CRED"
		hipsterSectionLabel.font = UIFont(name: "Avenir-Book", size: CGFloat(fontSize))
		hipsterSectionLabel.textColor = UIColor.white.withAlphaComponent(0.5)
		hipsterSectionLabel.textAlignment = .center
		
		hipsterScoreButton.addSubview(hipsterScoreLabel)
		hipsterScoreButton.addSubview(hipsterSectionLabel)
		
		// Left Divider
		let leftDivider = UIView(frame: CGRect(origin: CGPoint(x: hipsterScoreButton.frame.maxX, y: 0), size: dividerSize))
		leftDivider.center.y = hipsterScoreButton.bounds.midY
		leftDivider.backgroundColor = UIColor.white.withAlphaComponent(0.07)
		
		// Followers Button
		followersButton = UIButton(frame: CGRect(x: leftDivider.frame.maxX, y: 0, width: buttonWidth, height: buttonsContainerHeight))
		followersButton.backgroundColor = .clear
		followersButton.addTarget(self, action: #selector(followersButtonPressed(sender:)), for: .touchUpInside)
		
		followersLabel = UILabel(frame: CGRect(x: 0, y: 13, width: labelWidth, height: labelHeight))
		followersLabel.center.x = followersButton.bounds.midX
		followersLabel.text = "-"
		followersLabel.font = UIFont(name: "AvenirNext-Medium", size: 13.0)
		followersLabel.textColor = .white
		followersLabel.textAlignment = .center
		
		let followersSectionLabel = UILabel(frame: CGRect(x: 0, y: followersLabel.frame.maxY, width: labelWidth, height: labelHeight))
		followersSectionLabel.center.x = followersButton.bounds.midX
		followersSectionLabel.text = "FOLLOWERS"
		followersSectionLabel.font = UIFont(name: "Avenir-Book", size: CGFloat(fontSize))
		followersSectionLabel.textColor = UIColor.white.withAlphaComponent(0.5)
		followersSectionLabel.textAlignment = .center
		
		followersButton.addSubview(followersLabel)
		followersButton.addSubview(followersSectionLabel)

		// Right Divider
		let rightDivider = UIView(frame: CGRect(origin: CGPoint(x: followersButton.frame.maxX, y: 0), size: dividerSize))
		rightDivider.center.y = followersButton.bounds.midY
		rightDivider.backgroundColor = UIColor.white.withAlphaComponent(0.07)
		
		// Following Button
		followingButton = UIButton(frame: CGRect(x: rightDivider.frame.maxX, y: 0, width: buttonWidth, height: buttonsContainerHeight))
		followingButton.backgroundColor = .clear
		followingButton.addTarget(self, action: #selector(followingButtonPressed(sender:)), for: .touchUpInside)
		
		followingLabel = UILabel(frame: CGRect(x: 0, y: 13, width: labelWidth, height: labelHeight))
		followingLabel.center.x = followingButton.bounds.midX
		followingLabel.text = "-"
		followingLabel.font = UIFont(name: "AvenirNext-Medium", size: 13.0)
		followingLabel.textColor = .white
		followingLabel.textAlignment = .center
		
		let followingSectionLabel = UILabel(frame: CGRect(x: 0, y: followingLabel.frame.maxY, width: labelWidth, height: labelHeight))
		followingSectionLabel.center.x = followingButton.bounds.midX
		followingSectionLabel.text = "FOLLOWING"
		followingSectionLabel.font = UIFont(name: "Avenir-Book", size: CGFloat(fontSize))
		followingSectionLabel.textColor = UIColor.white.withAlphaComponent(0.5)
		followingSectionLabel.textAlignment = .center
		
		followingButton.addSubview(followingLabel)
		followingButton.addSubview(followingSectionLabel)
		
		// Add subviews
		buttonsContainerView.addSubview(hipsterScoreButton)
		buttonsContainerView.addSubview(leftDivider)
		buttonsContainerView.addSubview(followersButton)
		buttonsContainerView.addSubview(rightDivider)
		buttonsContainerView.addSubview(followingButton)
		addSubview(buttonsContainerView)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	// MARK: - Button Action Methods
	
	func usernameButtonPressed(sender: UIButton) {
		print("username button pressed")
	}
	
	func hipsterScoreButtonPressed(sender: UIButton) {
		guard let delegate = delegate else { return }
		delegate.hipsterScoreButtonPressed()
	}
	
	func followersButtonPressed(sender: UIButton) {
		guard let delegate = delegate else { return }
		delegate.followersButtonPressed()
	}
	
	func followingButtonPressed(sender: UIButton) {
		guard let delegate = delegate else { return }
		delegate.followingButtonPressed()
	}
	
}
