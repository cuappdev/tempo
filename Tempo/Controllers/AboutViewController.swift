//
//  AboutViewController.swift
//  Tempo
//
//  Created by Jesse Chen on 9/28/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController, UIScrollViewDelegate {
	
	var tempoImage: UIImageView!
	var tempoTitle: UILabel!
	
	var aboutLabel: UILabel!
	var linksLabel: UILabel!
	var teamLabel:  UILabel!
	
	var aboutInfo:  UILabel!
	var linksInfo:  UILabel!
	var teamInfo:   UILabel!
	
	let aboutText = "Cornell App Development is a project team at Cornell University dedicated to mobile app development. Every year, we take an app from idea to product, culminating with a release on the App Store. We give students the opportunity to work in a startup environment and gain practical experience in software development, design, and product management. Our team is made up of talented designers, developers, and visionaries who collaborate to bring projects to life."
	
	let linksText = "http://www.cuappdev.org \n" + "https://github.com/cuappdev \n" + "https://twitter.com/cornellappdev"
	
	let teamText = "Leads:  Andrew Aquino, Annie Cheng, Adam ElShaer, Dennis Fedorko, Ilan Filonenko \n\n" +
		"Designers:  Austin Chan, Mihir Chauhan, Sara Cheong, Eileen Dai, Derrick Ho, Sahil Khoja, Jonathan Lee, Jason Wu, Tiffany Zheng \n\n" +
		"iOS:  Logan Allen, Natasha Armbrust, Austin Astorga, Matt Barker, Mark Bryan, Jesse Chen, Andrew Dunne, Arman Esmaili, Kevin Greer, Daniel Li, Emily Lien, Monica Ong, Keivan Shahida \n\n" +
		"Backend:  Joseph Antonakakis, Celine Brass, Rishab Gupta, Hong Jeon, Sanjana Kaundinya, Ji Hun Kim, Amit Mizrahi, Shiv Roychowdhury"
	
	let labelFont = UIFont(name: "AvenirNext-Medium", size: 18)
	var screenWidth: CGFloat!

    override func viewDidLoad() {
        super.viewDidLoad()
		title = "About"
		screenWidth = view.frame.width
		
		addHamburgerMenu()
		
		let scrollView = UIScrollView(frame: view.frame)
		scrollView.delegate = self
		view = scrollView
		
		setupTopViews()
		setupAbout()
		setupLinks()
		setupTeam()
		
		scrollView.contentSize = CGSize(width: screenWidth, height: teamInfo.frame.bottom.y + 100)
    }
	
	func setupTopViews() {
		let imageSize = screenWidth*2/5
		tempoImage = UIImageView(frame: CGRect(x: screenWidth/2 - imageSize/2, y: 36, width: imageSize, height: imageSize))
		tempoImage.image = UIImage(named: "tempoCircle")
		view.addSubview(tempoImage)
		
		tempoTitle = UILabel(frame: CGRect(x: 20, y: tempoImage.frame.bottom.y, width: screenWidth-40, height: 50))
		tempoTitle.font = UIFont(name: "HelveticaNeue-Bold", size: 46)
		tempoTitle.textColor = UIColor.white
		tempoTitle.textAlignment = .center
		tempoTitle.text = "Tempo"
		view.addSubview(tempoTitle)
	}
	
	func setupAbout() {
		aboutLabel = UILabel(frame: CGRect(x: 32, y: tempoTitle.frame.bottom.y + 30, width: 100, height: 22))
		aboutLabel.font = labelFont
		aboutLabel.textColor = UIColor.white
		aboutLabel.text = "About"
		view.addSubview(aboutLabel)
		
		aboutInfo = UILabel(frame: CGRect(x: 32, y: aboutLabel.frame.bottom.y + 10, width: screenWidth - 64, height: 0))
		aboutInfo.font = UIFont(name: "AvenirNext-Regular", size: 14)
		aboutInfo.textColor = UIColor.white
		aboutInfo.layer.opacity = 0.75
		aboutInfo.numberOfLines = 15
		aboutInfo.text = aboutText
		aboutInfo.sizeToFit()
		view.addSubview(aboutInfo)
	}
	
	func setupLinks() {
		linksLabel = UILabel(frame: CGRect(x: 32, y: aboutInfo.frame.bottom.y + 30, width: 100, height: 22))
		linksLabel.font = labelFont
		linksLabel.textColor = UIColor.white
		linksLabel.text = "Links"
		view.addSubview(linksLabel)
		
		linksInfo = UILabel(frame: CGRect(x: 32, y: linksLabel.frame.bottom.y + 10, width: screenWidth - 64, height: 0))
		linksInfo.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
		linksInfo.textColor = UIColor.tempoLightRed
		linksInfo.numberOfLines = 3
		linksInfo.text = linksText
		linksInfo.sizeToFit()
		view.addSubview(linksInfo)
	}
	
	func setupTeam() {
		teamLabel = UILabel(frame: CGRect(x: 32, y: linksInfo.frame.bottom.y + 30, width: 100, height: 22))
		teamLabel.font = labelFont
		teamLabel.textColor = UIColor.white
		teamLabel.text = "Team"
		view.addSubview(teamLabel)
		
		teamInfo = UILabel(frame: CGRect(x: 32, y: teamLabel.frame.bottom.y + 10, width: screenWidth - 64, height: 0))
		teamInfo.font = UIFont(name: "AvenirNext-Regular", size: 14)
		teamInfo.textColor = UIColor.white
		teamInfo.layer.opacity = 0.6
		teamInfo.numberOfLines = 20
		teamInfo.text = teamText
		teamInfo.sizeToFit()
		view.addSubview(teamInfo)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
}
