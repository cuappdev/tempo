//
//  Song.swift
//  IceFishing
//
//  Created by Alexander Zielenski on 4/12/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit
import SwiftyJSON

let spotifyAPIBaseURL = NSURL(string: "https://api.spotify.com/v1/tracks/")
let SongDidDownloadArtworkNotification = "SongDidDownloadArtwork"

class Song: NSObject {
    var title = ""
    var artist = ""
    var album = ""
    var largeArtworkURL: NSURL?
    var smallArtworkURL: NSURL?
    
    private var largeArtwork: UIImage?
    func fetchArtwork() -> UIImage? {
        if (largeArtwork == nil && largeArtworkURL != nil) {
            loadImageAsync(largeArtworkURL!, { [weak self] (image, error) -> () in
                self?.largeArtwork = image
                NSNotificationCenter.defaultCenter().postNotificationName(SongDidDownloadArtworkNotification, object: self)
                })
        }
        return largeArtwork
    }
    
    var spotifyID: String = ""
    var previewURL: NSURL!
    
    init(songID: String) {
        super.init()
        spotifyID = songID
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
    
    init(responseDictionary: NSDictionary) {
        super.init()
        initializeFromResponseDictionary(responseDictionary)
    }
    
    private func initializeFromResponseDictionary(response: NSDictionary) {
        initializeFromResponse(JSON(response))
    }
    
    private func initializeFromResponse(json: JSON) {
        title = json["name"].stringValue
        let preview = json["preview_url"].stringValue
        previewURL = NSURL(string: preview)
        let artists = json["artists"].arrayValue
        if (artists.count > 1) {
            artist = "Various Artists"
        } else if (artists.count == 0) {
            artist = "Unknown Artist"
        } else {
            artist = artists[0]["name"].string ?? "Unknown Artist"
        }
        
        let albums = json["album"].dictionaryValue
        album = albums["name"]?.string ?? "Unknown Album"
        
        let images = albums["images"]?.arrayValue ?? []
        if images.count > 0 {
            var firstImage = images[images.count - 1].dictionaryValue
            smallArtworkURL = NSURL(string: firstImage["url"]?.stringValue ?? "")
            
            firstImage = images[0].dictionaryValue
            largeArtworkURL = NSURL(string: firstImage["url"]?.stringValue ?? "")
        }
        spotifyID = json["id"].stringValue
    }
    
    
    private func setSongID(id: String) {
        //!TODO: Use Spotify SDK
        let request = NSURLRequest(URL: NSURL(string: spotifyID, relativeToURL: spotifyAPIBaseURL)!)
        var error:NSError? = nil
        let data = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: &error)
        if let data = data {
            let json = JSON(data: data, options: NSJSONReadingOptions(0), error: &error)
            initializeFromResponse(json)
        } else {
            println("got error: %@", (error!).description)
        }
    }
    
    override init() {
        assertionFailure("use init(songID:)")
    }
}
