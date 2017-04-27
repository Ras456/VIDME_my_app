//
//  Video.swift
//  VIDME
//
//  Created by Hyzhnyak Evgen on 19.04.17.
//  Copyright © 2017 Hyzhnyak Evgen. All rights reserved.
//

import Foundation
import ObjectMapper

class Video: Mappable {
    var dateAdded: String?
    var dateFeatured: String?
    var isNew = 0
    var likesCount = 0
    var title: String?
    var thumbnail: Data?
    var thumbnailURL: String?
    var height = 0.0
    var width = 0.0
    var videoURL: String?
    var userFollowing = 0
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        dateAdded <- map["date_stored"]
        dateFeatured <- map["date_featured"]
        likesCount <- map["likes_count"]
        title <- map["title"]
        thumbnailURL <- map["thumbnail_url"]
        height <- map["height"]
        width <- map["width"]
        videoURL <- map["complete_url"]
    }
}

class ResponseVideos: Mappable {
    var videos: [Video] = []
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        videos <- map["videos"]
    }
}
