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

class ProfileHeaderView: UIView, UIGestureRecognizerDelegate {
	
	let profileImageLength: CGFloat = 85
	let profileContainerHeight: CGFloat = 170
	let profileButtonHeight: CGFloat = 30
	
	var profileContainerView: UIView!
	var profileBackgroundImageView: UIImageView!
	var profileImageView: UIImageView!
	var nameLabel: UILabel!
	var usernameLabel: UILabel!
	var profileButton: UIButton!
	
	var wrapperViewSize = CGSize(width: 80.0, height: 40.0)
	var isWrapperInterationEnabled = true
	var followersWrapperView: UIView!
	var followingWrapperView: UIView!
	var hipsterScoreWrapperView: UIView!
	var followersLabel: UILabel!
	var followingLabel: UILabel!
	var hipsterScoreLabel: UILabel!
	
	var tapGestureRecognizer: UITapGestureRecognizer!
	
	var delegate: ProfileHeaderViewDelegate?
	
	let fontSize = iPhone5 ? 11.0 : 13.0
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		setUpProfileContainerView()
	}
	
	func setUpProfileContainerView() {
		profileContainerView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: profileContainerHeight))
		profileContainerView.backgroundColor = .unreadCellColor
		
		profileBackgroundImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: profileContainerView.frame.width, height: profileContainerView.frame.height))
		profileBackgroundImageView.center.x = profileContainerView.bounds.midX
		profileBackgroundImageView.clipsToBounds = true
		profileBackgroundImageView.contentMode = .scaleAspectFill
		profileBackgroundImageView.alpha = 0.05
		
		profileImageView = UIImageView(frame: CGRect(x: 18, y: 18, width: profileImageLength, height: profileImageLength))
		profileImageView.layer.cornerRadius = profileImageLength / 2.0
		profileImageView.clipsToBounds = true
		profileImageView.contentMode = .scaleAspectFill
		
		nameLabel = UILabel(frame: CGRect(x: profileImageLength + 40, y: (profileImageLength / 2.0) - 3, width: bounds.width - 115 - 20, height: 23))
		nameLabel.text = "Name"
		nameLabel.font = UIFont(name: "AvenirNext-Medium", size: 17.0)
		nameLabel.textColor = .redTintedWhite
		nameLabel.textAlignment = .left
		
		usernameLabel = UILabel(frame: CGRect(x: profileImageLength + 40, y: (profileImageLength / 2.0) + 20, width: bounds.width - 115 - 20, height: 23))
		usernameLabel.text = "Name"
		usernameLabel.font = UIFont(name: "AvenirNext-Regular", size: 13.0)
		usernameLabel.textColor = .paleRed
		usernameLabel.textAlignment = .left
		
		profileButton = UIButton(frame: CGRect(x: 23, y: profileImageView.frame.maxY + 18, width: 75, height: profileButtonHeight))
		profileButton.setTitle("-", for: .normal)
		profileButton.setTitleColor(.redTintedWhite, for: .normal)
		profileButton.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 12.0)
		profileButton.layer.borderColor = UIColor.tempoRed.cgColor
		profileButton.layer.borderWidth = 1.5
		profileButton.layer.cornerRadius = 3
		profileButton.clipsToBounds = true
		
		let labelFont = UIFont(name: "AvenirNext-Medium", size: 13.0)
		let descriptionFont = UIFont(name: "AvenirNext-Regular", size: 13.0)
		
		followersWrapperView = UIView(frame: CGRect(origin: CGPoint(x: profileButton.frame.maxX + 20, y: profileImageView.frame.maxY + 10), size: wrapperViewSize))
		followersLabel = UILabel(frame: CGRect(x: 0, y: 0, width: wrapperViewSize.width, height: wrapperViewSize.height / 2.0))
		followersLabel.text = "-"
		followersLabel.font = labelFont
		followersLabel.textColor = .redTintedWhite
		followersLabel.textAlignment = .center
		let followerDescription = UILabel(frame: CGRect(x: 0, y: wrapperViewSize.height / 2.0, width: wrapperViewSize.width, height: wrapperViewSize.height / 2.0))
		followerDescription.text = "Followers"
		followerDescription.font = descriptionFont
		followerDescription.textColor = .paleRed
		followerDescription.textAlignment = .center
		followersWrapperView.addSubview(followersLabel)
		followersWrapperView.addSubview(followerDescription)
		
		followingWrapperView = UIView(frame: CGRect(origin: CGPoint(x: followersWrapperView.frame.maxX, y: profileImageView.frame.maxY + 10), size: wrapperViewSize))
		followingLabel = UILabel(frame: CGRect(x: 0, y: 0, width: wrapperViewSize.width, height: wrapperViewSize.height / 2.0))
		followingLabel.text = "-"
		followingLabel.font = labelFont
		followingLabel.textColor = .redTintedWhite
		followingLabel.textAlignment = .center
		let followingDescription = UILabel(frame: CGRect(x: 0, y: wrapperViewSize.height / 2.0, width: wrapperViewSize.width, height: wrapperViewSize.height / 2.0))
		followingDescription.text = "Following"
		followingDescription.font = descriptionFont
		followingDescription.textColor = .paleRed
		followingDescription.textAlignment = .center
		followingWrapperView.addSubview(followingLabel)
		followingWrapperView.addSubview(followingDescription)
	
		hipsterScoreWrapperView = UIView(frame: CGRect(origin: CGPoint(x: followingWrapperView.frame.maxX, y: profileImageView.frame.maxY + 10), size: wrapperViewSize))
		hipsterScoreLabel = UILabel(frame: CGRect(x: 0, y: 0, width: wrapperViewSize.width, height: wrapperViewSize.height / 2.0))
		hipsterScoreLabel.text = "-"
		hipsterScoreLabel.font = labelFont
		hipsterScoreLabel.textColor = .redTintedWhite
		hipsterScoreLabel.textAlignment = .center
		let hipsterScoreDescription = UILabel(frame: CGRect(x: 0, y: wrapperViewSize.height / 2.0, width: wrapperViewSize.width, height: wrapperViewSize.height / 2.0))
		hipsterScoreDescription.text = "Hipster Cred"
		hipsterScoreDescription.font = descriptionFont
		hipsterScoreDescription.textColor = .paleRed
		hipsterScoreDescription.textAlignment = .center
		hipsterScoreWrapperView.addSubview(hipsterScoreLabel)
		hipsterScoreWrapperView.addSubview(hipsterScoreDescription)
		
		tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(headerViewPressed(sender:)))
		profileContainerView.addGestureRecognizer(tapGestureRecognizer)
		
		profileContainerView.addSubview(profileBackgroundImageView)
		profileContainerView.addSubview(profileImageView)
		profileContainerView.addSubview(nameLabel)
		profileContainerView.addSubview(usernameLabel)
		profileContainerView.addSubview(profileButton)
		profileContainerView.addSubview(followersWrapperView)
		profileContainerView.addSubview(followingWrapperView)
		profileContainerView.addSubview(hipsterScoreWrapperView)
		addSubview(profileContainerView)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Button Action Handling
	func headerViewPressed(sender: UITapGestureRecognizer) {
		guard let delegate = delegate else { return }
		
		let tapPoint = sender.location(in: self)
		let hitView = hitTest(tapPoint, with: nil)
		
		if isWrapperInterationEnabled {
			if hitView == followersWrapperView {
				delegate.followersButtonPressed()
			} else if hitView == followingWrapperView {
				delegate.followingButtonPressed()
			} else if hitView == hipsterScoreWrapperView {
				delegate.hipsterScoreButtonPressed()
			}
		}
	}
	
}
