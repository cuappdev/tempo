//
//  Track.swift
//  SpotifySearch
//
//  Created by Austin Chan on 3/11/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import Foundation

struct TrackResult {
    var artists: [[String:String]]
    var album: [String:String]
    var id: String
    var name: String
    var uri: String
    var popularity: Int
    
    init(artists: [AnyObject], album: AnyObject, id: String, name: String, uri: String, andPopularity: Int) {
        self.artists = []
        
        var artists_arr: [[String:String]] = []
        
        for var i = 0; i < artists.count; i++ {
            let artist: AnyObject = artists[i]
            let artist_name = artist["name"] as! String
            let artist_id = artist["id"] as! String
            
            artists_arr.append([
                "id": artist_id,
                "name": artist_name
            ])
        }
        
        self.artists = artists_arr

        self.album = [
            "id": album["id"]as! String,
            "name": album["name"]as! String
        ]
        
        self.id = id
        self.name = name
        self.uri = uri
        self.popularity = andPopularity
    }
}