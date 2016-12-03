//
//  AboutViewController.swift
//  Tempo
//
//  Created by Jesse Chen on 9/28/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController, UIScrollViewDelegate {
	
	let aboutText = "Tempo is a music sharing application created by Cornell App Development, a student project team at Cornell University dedicated to mobile app development. Every year, we take apps from idea to product, culminating with releases on the App Store. We give students the opportunity to work in a startup environment and gain practical experience in software development, design, and product management. Our team is made up of talented designers, iOS developers, and backend developers who collaborate to bring projects to life."
	let linksText = "www.cuappdev.org \n" + "www.github.com/cuappdev \n" + "www.twitter.com/cornellappdev"
	let teamText = "Leads:  Andrew Aquino, Annie Cheng, Adam ElShaer, Dennis Fedorko, Ilan Filonenko \n\n" +
		"Designers:  Austin Chan, Mihir Chauhan, Sara Cheong, Eileen Dai, Derrick Ho, Sahil Khoja, Jonathan Lee, Jason Wu, Tiffany Zheng \n\n" +
		"iOS:  Logan Allen, Natasha Armbrust, Austin Astorga, Matt Barker, Mark Bryan, Jesse Chen, Andrew Dunne, Arman Esmaili, Kevin Greer, Daniel Li, Emily Lien, Monica Ong, Keivan Shahida \n\n" +
	"Backend:  Joseph Antonakakis, Celine Brass, Rishab Gupta, Hong Jeon, Sanjana Kaundinya, Ji Hun Kim, Amit Mizrahi, Shiv Roychowdhury"
	let titleFont = UIFont(name: "AvenirNext-Medium", size: 18.0)!
	let padding: CGFloat = 31
	
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
		
		addHamburgerMenu()
		
		let scrollView = UIScrollView(frame: view.frame)
		scrollView.delegate = self
		scrollView.backgroundColor = .backgroundDarkGrey
		view = scrollView
		
		setupTopViews()
		setupAbout()
		setupLinks()
		setupTeam()
		
		scrollView.contentSize = CGSize(width: screenWidth, height: teamInfoLabel.frame.bottom.y + 100)
    }
	
	func setupTopViews() {
		let imageSize = view.frame.width * 0.45
		tempoImage = UIImageView(frame: CGRect(x: 0, y: 30, width: imageSize, height: imageSize))
		tempoImage.center.x = view.center.x
		tempoImage.image = #imageLiteral(resourceName: "TempoLogo")
		view.addSubview(tempoImage)
		
		tempoTitle = UILabel(frame: CGRect(x: 20, y: tempoImage.frame.bottom.y - 8, width: screenWidth, height: 60))
		tempoTitle.text = "Tempo"
		tempoTitle.font = UIFont(name: "HelveticaNeue-Bold", size: 50.0)
		tempoTitle.textColor = .white
		tempoTitle.textAlignment = .center
		tempoTitle.sizeToFit()
		tempoTitle.center.x = view.center.x
		view.addSubview(tempoTitle)
	}
	
	func setupAbout() {
		aboutLabel = UILabel(frame: CGRect(x: padding, y: tempoTitle.frame.bottom.y + 30, width: 52, height: 22))
		aboutLabel.text = "About"
		aboutLabel.font = titleFont
		aboutLabel.textColor = .white
		aboutLabel.sizeToFit()
		view.addSubview(aboutLabel)
		
		aboutInfoLabel = UILabel(frame: CGRect(x: padding, y: aboutLabel.frame.bottom.y + 10, width: screenWidth - 2*padding, height: 0))
		
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
		linksLabel = UILabel(frame: CGRect(x: padding, y: aboutInfoLabel.frame.bottom.y + 30, width: 42, height: 25))
		linksLabel.text = "Links"
		linksLabel.font = titleFont
		linksLabel.textColor = .white
		linksLabel.sizeToFit()
		view.addSubview(linksLabel)
		
		linksInfoTextView = UITextView(frame: CGRect(x: padding, y: linksLabel.frame.bottom.y + 5, width: screenWidth - 2*padding, height: 0))
		
		let linksInfoParagraphStyle = NSMutableParagraphStyle()
		linksInfoParagraphStyle.lineSpacing = 1.5
		
		let linksInfoAttrString = NSMutableAttributedString(string: linksText)
		linksInfoAttrString.addAttribute(NSParagraphStyleAttributeName, value: linksInfoParagraphStyle, range: NSMakeRange(0, linksInfoAttrString.length))
		linksInfoTextView.attributedText = linksInfoAttrString
		
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
		teamLabel = UILabel(frame: CGRect(x: padding, y: linksInfoTextView.frame.bottom.y + 20, width: 80, height: 25))
		teamLabel.text = "The Team"
		teamLabel.font = titleFont
		teamLabel.textColor = .white
		teamLabel.sizeToFit()
		view.addSubview(teamLabel)
		
		teamInfoLabel = UILabel(frame: CGRect(x: padding, y: teamLabel.frame.bottom.y + 10, width: screenWidth - 2*padding, height: 0))
		
		let teamInfoParagraphStyle = NSMutableParagraphStyle()
		teamInfoParagraphStyle.lineSpacing = 2.5
		
		let teamInfoAttrString = NSMutableAttributedString(string: teamText)
		teamInfoAttrString.addAttribute(NSParagraphStyleAttributeName, value: teamInfoParagraphStyle, range: NSMakeRange(0, teamInfoAttrString.length))
		teamInfoLabel.attributedText = teamInfoAttrString
		
		teamInfoLabel.font = UIFont(name: "AvenirNext-Regular", size: 14.0)
		teamInfoLabel.textColor = .aboutDarkGrey
		teamInfoLabel.layer.opacity = 0.74
		teamInfoLabel.numberOfLines = 0
		teamInfoLabel.sizeToFit()
		view.addSubview(teamInfoLabel)
	}

}
