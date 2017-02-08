//
//  PlaylistTableViewController.swift
//  Tempo
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
		
		title = "Add to Playlist"
		view.backgroundColor = UIColor.tempoDarkGray
		
		let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(PlaylistTableViewController.dismissVC))
		cancelButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir-Book", size: 14)!], for: UIControlState())
		navigationItem.leftBarButtonItem = cancelButton
		
		tableView.rowHeight = 72
		tableView.showsVerticalScrollIndicator = false
		tableView.register(UINib(nibName: "PlaylistTableViewCell", bundle: nil), forCellReuseIdentifier: "PlaylistCell")
    }
	
	override func viewDidAppear(_ animated: Bool) {
		SpotifyController.sharedController.getPlaylists { playlists, error in
			guard error == nil else {
				return
			}
			
			self.playlists = playlists!
			self.tableView.reloadData()
		}
	}
	
	func dismissVC() {
		dismiss(animated: true, completion: nil)
	}

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistCell", for: indexPath) as! PlaylistTableViewCell
		let numTracks = playlists[indexPath.row].trackCount
		let trackImages = playlists[indexPath.row].images
		
		cell.playlistImage.image = nil
		cell.playlistNameLabel.text = playlists[indexPath.row].name
		cell.playlistNumSongsLabel.text = numTracks == 1 ? "\(numTracks) Song" : "\(numTracks) Songs"
		
		if trackImages?.count == 0 {
			cell.playlistImage.image = #imageLiteral(resourceName: "PlaylistImage")
		} else {
			if let url = (trackImages?[0] as AnyObject).imageURL {
				if let data = try? Data(contentsOf: url){
					cell.playlistImage.contentMode = .scaleAspectFit
					cell.playlistImage.image = UIImage(data: data)
				}
			}
		}

        return cell
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let playlist = playlists[indexPath.row]
		
		SpotifyController.sharedController.addTrackToPlaylist(playlist, track: song!) { success in
			if success {
				self.savedSongAlertView = SavedSongView.instanceFromNib()
				self.savedSongAlertView.showSongStatusPopup(.notSavedToPlaylist, playlist: playlist.name)
			}
		}
		dismiss(animated: true, completion: nil)
	}

}
