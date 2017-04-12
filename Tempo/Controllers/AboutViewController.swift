//
//  AboutViewController.swift
//  Tempo
//
//  Created by Jesse Chen on 9/28/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController, UIScrollViewDelegate {
	
	static let sharedInstance = AboutViewController()
	
	let aboutText = "Tempo is a music sharing application created by AppDev, a student project team at Cornell University dedicated to mobile app development. Every year, we take apps from idea to product, culminating with releases on the App Store. We give students the opportunity to work in a startup environment and gain practical experience in software development, design, and product management."
	let linksText = "www.cuappdev.org \n" + "www.github.com/cuappdev \n" + "www.twitter.com/cornellappdev"
	let teamText = "Special thanks to all the designers, developers, and dreamers who lost countless hours of sleep to bring this app to life."
	let titleFont = UIFont(name: "AvenirNext-Medium", size: 18.0)!
	let padding: CGFloat = 31
	let sectionSpacing: CGFloat = 30
	let subsectionSpacing: CGFloat = 10
	
	var tempoImage: UIImageView!
	var tempoTitle: UILabel!
	
	var aboutLabel: UILabel!
	var linksLabel: UILabel!
	var teamLabel: UILabel!
	
	var aboutInfoLabel: UILabel!
	var linksInfoTextView: UITextView!
	var teamInfoLabel: UILabel!
	
	var screenWidth: CGFloat!

    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = "About"
		screenWidth = view.frame.width
		
		let scrollViewHeight = view.frame.height - tabBarHeight - miniPlayerHeight
		let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: scrollViewHeight))
		scrollView.delegate = self
		scrollView.backgroundColor = .backgroundDarkGrey
		scrollView.bounces = false
		view = scrollView
		
		setupTopViews()
		setupAbout()
		setupLinks()
		setupTeam()
		
		scrollView.contentSize = CGSize(width: screenWidth, height: teamInfoLabel.frame.bottom.y + tabBarHeight + miniPlayerHeight + 50)
    }
	
	func setupTopViews() {
		let imageSize = view.frame.width * 0.35
		tempoImage = UIImageView(frame: CGRect(x: 0, y: 40, width: imageSize, height: imageSize))
		tempoImage.center.x = view.center.x
		tempoImage.image = UIImage(named: "TempoLogo")
		view.addSubview(tempoImage)
		
		tempoTitle = UILabel(frame: CGRect(x: 20, y: tempoImage.frame.bottom.y + 10, width: screenWidth, height: 50))
		tempoTitle.text = "Tempo"
		tempoTitle.font = UIFont(name: "HelveticaNeue-Bold", size: 50.0)
		tempoTitle.textColor = .white
		tempoTitle.textAlignment = .center
		tempoTitle.sizeToFit()
		tempoTitle.center.x = view.center.x
		view.addSubview(tempoTitle)
	}
	
	func setupAbout() {
		aboutLabel = UILabel(frame: CGRect(x: padding, y: tempoTitle.frame.bottom.y + sectionSpacing, width: 52, height: 22))
		aboutLabel.text = "About"
		aboutLabel.font = titleFont
		aboutLabel.textColor = .white
		aboutLabel.sizeToFit()
		view.addSubview(aboutLabel)
		
		aboutInfoLabel = UILabel(frame: CGRect(x: padding, y: aboutLabel.frame.bottom.y + subsectionSpacing, width: screenWidth - 2*padding, height: 0))
		
		let aboutInfoParagraphStyle = NSMutableParagraphStyle()
		aboutInfoParagraphStyle.lineSpacing = 2.5
		
		let aboutInfoAttrString = NSMutableAttributedString(string: aboutText)
		aboutInfoAttrString.addAttribute(NSParagraphStyleAttributeName, value: aboutInfoParagraphStyle, range: NSMakeRange(0, aboutInfoAttrString.length))
		aboutInfoLabel.attributedText = aboutInfoAttrString
		
		aboutInfoLabel.font = UIFont(name: "AvenirNext-Regular", size: 14.0)
		aboutInfoLabel.textColor = .white
		aboutInfoLabel.layer.opacity = 0.74
		aboutInfoLabel.numberOfLines = 0
		aboutInfoLabel.sizeToFit()
		view.addSubview(aboutInfoLabel)
	}
	
	func setupLinks() {
		linksLabel = UILabel(frame: CGRect(x: padding, y: aboutInfoLabel.frame.bottom.y + sectionSpacing, width: 42, height: 25))
		linksLabel.text = "Links"
		linksLabel.font = titleFont
		linksLabel.textColor = .white
		linksLabel.sizeToFit()
		view.addSubview(linksLabel)
		
		linksInfoTextView = UITextView(frame: CGRect(x: padding, y: linksLabel.frame.bottom.y + subsectionSpacing, width: screenWidth - 2*padding, height: 0))
		
		let linksInfoParagraphStyle = NSMutableParagraphStyle()
		linksInfoParagraphStyle.lineSpacing = 1.5
		
		let linksInfoAttrString = NSMutableAttributedString(string: linksText)
		linksInfoAttrString.addAttribute(NSParagraphStyleAttributeName, value: linksInfoParagraphStyle, range: NSMakeRange(0, linksInfoAttrString.length))
		linksInfoTextView.attributedText = linksInfoAttrString
		
		linksInfoTextView.textContainer.lineFragmentPadding = 0
		linksInfoTextView.textContainerInset = .zero
		
		linksInfoTextView.font = UIFont(name: "AvenirNext-DemiBold", size: 16.0)
		linksInfoTextView.backgroundColor = .clear
		linksInfoTextView.textColor = .tempoRed
		linksInfoTextView.tintColor = .tempoRed
		linksInfoTextView.isEditable = false
		linksInfoTextView.dataDetectorTypes = .link
		linksInfoTextView.sizeToFit()
		view.addSubview(linksInfoTextView)
	}
	
	func setupTeam() {
		teamLabel = UILabel(frame: CGRect(x: padding, y: linksInfoTextView.frame.bottom.y + sectionSpacing, width: 80, height: 25))
		teamLabel.text = "The Team"
		teamLabel.font = titleFont
		teamLabel.textColor = .white
		teamLabel.sizeToFit()
		view.addSubview(teamLabel)
		
		teamInfoLabel = UILabel(frame: CGRect(x: padding, y: teamLabel.frame.bottom.y + subsectionSpacing, width: screenWidth - 2*padding, height: 0))
		
		let teamInfoParagraphStyle = NSMutableParagraphStyle()
		teamInfoParagraphStyle.lineSpacing = 2.5
		
		let teamInfoAttrString = NSMutableAttributedString(string: teamText)
		teamInfoAttrString.addAttribute(NSParagraphStyleAttributeName, value: teamInfoParagraphStyle, range: NSMakeRange(0, teamInfoAttrString.length))
		teamInfoLabel.attributedText = teamInfoAttrString
		
		teamInfoLabel.font = UIFont(name: "AvenirNext-Regular", size: 14.0)
		teamInfoLabel.textColor = .descriptionGrey
		teamInfoLabel.layer.opacity = 0.74
		teamInfoLabel.numberOfLines = 0
		teamInfoLabel.sizeToFit()
		view.addSubview(teamInfoLabel)
	}

}
