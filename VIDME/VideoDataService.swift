//
//  ManagerAPI.swift
//  VIDME
//
//  Created by Hyzhnyak Evgen on 19.04.17.
//  Copyright © 2017 Hyzhnyak Evgen. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import RealmSwift


class VideoDataService {
    
    class func getFeauturedVideoList(limit: Int, offset: Int, completionHandler: @escaping (Error?, [Video]?) -> Void) {
        
        getVideoList(url: "\(BASE_API_URL_STRING)videos/featured?limit=\(limit)&offset=\(offset)", completionHandler: completionHandler)
    }
    
    class func getNewVideoList(limit: Int, offset: Int, completionHandler: @escaping (Error?, [Video]?) -> Void) {
        
        getVideoList(url: "\(BASE_API_URL_STRING)videos/new?limit=\(limit)&offset=\(offset)", completionHandler: completionHandler)
    }
    
    class func getThumbnailForVideo(_ video: Video, completionHandler: @escaping () -> Void) {
        Alamofire.request(video.thumbnailURL!).responseData { response in
            switch response.result {
            case .success:
                if let data = response.result.value {
                    video.thumbnail = data
                    completionHandler()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    fileprivate class func getVideoList(url: String, completionHandler: @escaping (Error?, [Video]?) -> Void) {
        
        Alamofire.request(url).responseObject { (response: DataResponse<ResponseVideos>) in
            
            switch response.result {
            case .success:
                if let responseVideos = response.result.value {
                    completionHandler(nil, responseVideos.videos)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

        
    class func loginUser(with username: String, password: String, completionHandler: @escaping (Error?, User?) -> Void) {
        
        let headers: HTTPHeaders = [
            "\(AUTH_KEY)": "\(APP_KEY)"
        ]
        let parameters: Parameters = ["username": username, "password": password]
        
        Alamofire.request("\(BASE_API_URL_STRING)auth/create", method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).validate(statusCode: 200..<300).responseObject { (response: DataResponse<User>) in
            
            switch response.result {
            case .success:
                if let user = response.result.value {
                    print(user)
                    user.login = username
                    user.password = password
                    
                    let realm = try! Realm()
                    try! realm.write {
                        realm.add(user, update: true)
                    }
                    
                    completionHandler(nil, user)
                }
            case .failure(let error):
                print(error.localizedDescription)
                completionHandler(error, nil)
            }
            
        }
    }
    
    class func isUserLoggedIn() -> Bool {
        let realm = try! Realm()
        if realm.objects(User.self).first != nil {
            return true
        } else {
            return false
        }
    }
    
    class func logoutUser(_ completionHandler: @escaping (Error?) -> Void) {
        
        let realm = try! Realm()
        if let user = realm.objects(User.self).first {
            let headers: HTTPHeaders = [
                "AccessToken": "\(user.auth!.token!)"
            ]
            Alamofire.request("\(BASE_API_URL_STRING)auth/delete", headers: headers).responseJSON(completionHandler: { response in
                switch response.result {
                case .success:
                    try! realm.write {
                        realm.delete(user)
                    }
                    completionHandler(nil)
                case .failure(let error):
                    print(error)
                    completionHandler(error)
                }
            })
        }
    }
    
    
}
