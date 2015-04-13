//
//  Song.swift
//  IceFishing
//
//  Created by Alexander Zielenski on 4/12/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit

let spotifyAPIBaseURL = NSURL(string: "https://api.spotify.com/v1/tracks/")
class Song: NSObject {
    var title = ""
    var artist = ""
    var album = ""
    var spotifyID:String = "" {
        didSet {
            //!TODO: Use Spotify SDK
            let request = NSURLRequest(URL: NSURL(string: spotifyID, relativeToURL: spotifyAPIBaseURL)!)
            var error:NSError? = nil
            let data = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: &error)
            if let data = data {
                let json = JSON(data: data, options: NSJSONReadingOptions(0), error: &error)
                title = json["name"].stringValue
                let preview = json["preview_url"].stringValue
                previewURL = NSURL(string: preview)
                let artists = json["artists"].arrayValue
                if (artists.count > 1) {
                    artist = "Various Artists"
                } else if (artists.count == 0) {
                    artist = "Unknown Artist"
                } else {
                    artist = artists[0]["name"].stringValue
                }
                
                let albums = json["name"].arrayValue
                if (albums.count == 0) {
                    album = "Unknown Album"
                } else {
                    album = albums[0]["name"].stringValue
                }
            } else {
                println("got error: %@", (error!).description)
            }
        }
    }
    var previewURL: NSURL!
    
    init(songID: String) {
        super.init()
        self.setSongID(songID)
    }
    
    convenience init(spotifyURI: String) {
        let components = spotifyURI.componentsSeparatedByString(":") as [String]
        var id = ""
        if components.count > 0 {
            id = components.last!
        }
        self.init(songID: id)
    }

    private func setSongID(id: String) {
        spotifyID = id;
    }
    
    override init() {
        assertionFailure("use init(songID:)")
    }
}
