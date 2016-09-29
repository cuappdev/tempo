//
//  AboutViewController.swift
//  Tempo
//
//  Created by Jesse Chen on 9/28/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
	@IBOutlet weak var aboutLabel: UILabel!
	@IBOutlet weak var teamLabel: UILabel!
    @IBOutlet weak var linksLabel: UITextView!
	
    let aboutText = "Cornell App Development is a project team at Cornell University dedicated to mobile app development. Every year, we take an app from idea to product, culminating with a release on the App Store. We give students the opportunity to work in a startup environment and gain practical experience in software development, design, and product management. Our team is made up of talented designers, developers, and visionaries who collaborate to bring projects to life."
	let teamText = "Leads: Annie Cheng, Andrew Aquino, Dennis Fedorko, Ilan Filonenko, Adam ElShaer \n\n" +
		"Designers: Austin Chan, Mihir Chauhan, Sara Cheong, Eileen Dai, Derrick Ho, Sahil Khoja, Jonathan Lee, Jason Wu, Tiffany Zheng \n\n" +
		"iOS: Logan Allen, Joseph Antonakakis, Natasha Armbrust, Austin Astorga, Matt Barker, Mark Bryan, Jesse Chen, Andrew Dunne, Arman Esmaili, Kevin Greer, Daniel Li, Emily Lien, Monica Ong, Keivan Shahida \n\n" +
		"Backend: Celine Brass, Rishab Gupta, Hong Jeon, Sanjana Kaundinya, Ji Hun Kim, Amit Mizrahi, Shiv Roychowdhury"
	let linksText = "http://www.cuappdev.org/ \n" + "https://github.com/cuappdev/ \n" + "https://twitter.com/cornellappdev/ \n"
		

    override func viewDidLoad() {
        super.viewDidLoad()
		title = "About"
		
		addHamburgerMenu()
		aboutLabel.numberOfLines = 0;
		teamLabel.numberOfLines = 0;
		
		aboutLabel.text = aboutText
		teamLabel.text = teamText
		linksLabel.text = linksText
		
		aboutLabel.adjustsFontSizeToFitWidth = true
		teamLabel.adjustsFontSizeToFitWidth = true
		linksLabel.tintColor = UIColor.tempoLightRed
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func viewDidLayoutSubviews() {
	}
}
