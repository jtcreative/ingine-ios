//
//  User.swift
//  ingine
//
//  Created by Manish Dadwal on 20/10/20.
//  Copyright © 2020 ingine. All rights reserved.
//

import Foundation

struct User {
    
    var fullName:String = ""
    var id:String = ""
    var profileImage:String = ""
    var followings: [User] = [User]()
    var followers :  [User] = [User]()
    var assetCount = 0
    var assetIDs:[String] = [String]()
    var isFollowing = false
    
    func dictToUser (dict:[String:Any], id:String) -> User {
        
        
       let fullname = dict["fullName"] as? String ?? ""
        let profileImage = dict["profileImage"] as? String ?? ""
        
        let keys = dict.keys
        var assests = [String]()
        for k in keys{
            if k != "fullName" &&  k != "profileImage" && k != "follower" && k != "following"{
                assests.append(k)
            }
           
        }
       
        let followersArr = dict["follower"] as? [Any]
        var followersObjArr = [User]()
        for i in followersArr ?? []{
            let value = i as? [String:Any]
            let fullNameF = value?["fullName"] as? String ?? ""
            let id = value?["id"] as? String ?? ""
            let profileImage = value?["profileImage"] as? String ?? ""
            let assetCount = value?["assetCount"] as? Int ?? 0
            let follower = User(fullName: fullNameF, id: id, profileImage: profileImage, assetCount: assetCount)
            followersObjArr.append(follower)
        }
        
        let followingArr = dict["following"] as? [Any]
        var followingObjArr = [User]()
        for i in followingArr ?? []{
            let value = i as? [String:Any]
            let fullNameF = value?["fullName"] as? String ?? ""
            let id = value?["id"] as? String ?? ""
            let profileImage = value?["profileImage"] as? String ?? ""
            let assetCount = value?["assetCount"] as? Int ?? 0
            let following = User(fullName: fullNameF, id: id, profileImage: profileImage, assetCount:assetCount)
            followingObjArr.append(following)
        }
        
        return User(fullName: fullname, id: id, profileImage: profileImage, followings: followingObjArr, followers: followersObjArr, assetCount: assests.count, assetIDs: assests)
    }
    
    

}
