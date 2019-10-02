//
//  Post.swift
//  Post-New
//
//  Created by Eric Lanza on 11/28/18.
//  Copyright © 2018 ETLanza. All rights reserved.
//

import Foundation

struct TopLevelDictionary: Codable {
    let post: [Post]
}


struct Post: Codable {
    let text: String
    let timestamp: TimeInterval
    let username: String
    
    init(text: String, timestamp: TimeInterval = Date().timeIntervalSince1970, username: String) {
        
        self.text = text
        self.timestamp = timestamp
        self.username = username
    }
    
}



