//
//  PlaylistTableViewController.swift
//  IceFishing
//
//  Created by Annie Cheng on 11/1/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit

class PlaylistTableViewController: UITableViewController, UINavigationControllerDelegate {
	
	var playlists: [SPTPartialPlaylist] = []
	var song: Post?
	var savedSongAlertView: SavedSongView!

    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = "Add to Playlists"
		let cancelButton = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "dismissVC")
		navigationItem.leftBarButtonItem = cancelButton
		tableView.registerNib(UINib(nibName: "PlaylistTableViewCell", bundle: nil), forCellReuseIdentifier: "PlaylistCell")
    }
	
	override func viewDidAppear(animated: Bool) {
		SpotifyController.sharedController.getPlaylists { playlists, error in
			guard error == nil else {
				return
			}
			
			self.playlists = playlists!
			self.tableView.reloadData()
		}
	}
	
	func dismissVC() {
		dismissViewControllerAnimated(true, completion: nil)
	}

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PlaylistCell", forIndexPath: indexPath) as! PlaylistTableViewCell
		let numTracks = playlists[indexPath.row].trackCount
		let trackImages = playlists[indexPath.row].images
		
		cell.playlistNameLabel.text = playlists[indexPath.row].name
		cell.playlistNumSongsLabel.text = numTracks == 1 ? "\(numTracks) Song" : "\(numTracks) Songs"
		
		if trackImages.count == 0 {
			cell.playlistImage.image = UIImage(named: "Music-Icon")
		} else {
			if let url = trackImages[0].imageURL {
				if let data = NSData(contentsOfURL: url){
					cell.playlistImage.contentMode = .ScaleAspectFit
					cell.playlistImage.image = UIImage(data: data)
				}
			}
		}

        return cell
    }
	

	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let playlist = playlists[indexPath.row]
		
		SpotifyController.sharedController.addTrackToPlaylist(playlist, track: song!) { success in
			if success {
				self.savedSongAlertView = SavedSongView.instanceFromNib()
				self.savedSongAlertView.showSongStatusPopup(.NotSavedToPlaylist, playlist: playlist.name)
			}
		}
		dismissViewControllerAnimated(true, completion: nil)
	}

}
