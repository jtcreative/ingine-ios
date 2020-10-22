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
    var followings: [Following] = [Following]()
    var followers :  [Following] = [Following]()
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
        var followersObjArr = [Following]()
        for i in followersArr ?? []{
            let value = i as? [String:Any]
            let fullNameF = value?["fullName"] as? String ?? ""
            let id = value?["id"] as? String ?? ""
            let profileImage = value?["profileImage"] as? String ?? ""
            let follower = Following(fullName: fullNameF, id: id, profileImage: profileImage, assetCount: 0)
            followersObjArr.append(follower)
        }
        
        let followingArr = dict["following"] as? [Any]
        var followingObjArr = [Following]()
        for i in followingArr ?? []{
            let value = i as? [String:Any]
            let fullNameF = value?["fullName"] as? String ?? ""
            let id = value?["id"] as? String ?? ""
            let profileImage = value?["profileImage"] as? String ?? ""
            let following = Following(fullName: fullNameF, id: id, profileImage: profileImage, assetCount: 0)
            followingObjArr.append(following)
        }
        
        return User(fullName: fullname, id: id, profileImage: profileImage, followings: followingObjArr, followers: followersObjArr, assetCount: assests.count, assetIDs: assests)
    }
    
    

}
