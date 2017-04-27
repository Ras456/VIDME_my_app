//
//  ManagerAPI.swift
//  VIDME
//
//  Created by Hyzhnyak Evgen on 19.04.17.
//  Copyright © 2017 Hyzhnyak Evgen. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class User: Object, Mappable {
    dynamic var auth: Auth?
    dynamic var login = ""
    dynamic var password = ""
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override class func primaryKey() -> String? {
        return "login"
    }
    
    func mapping(map: Map) {
        auth <- map["auth"]
        
    }
}

class Auth: Object, Mappable {
    
    dynamic var token: String?
    dynamic var expires: String?
    dynamic var userId: String?
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        token <- map["token"]
        expires <- map["expires"]
        userId <- map["user_id"]
        
    }
}
