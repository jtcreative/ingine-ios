//
//  User.swift
//  ingine
//
//  Created by Manish Dadwal on 20/10/20.
//  Copyright © 2020 ingine. All rights reserved.
//

import Foundation
import FirebaseAuth
struct User {
    
    var fullName:String = ""
    var id:String = ""
    var profileImage:String = ""
    var followings: [User] = [User]()
    var followers :  [User] = [User]()
    var assetCount = 0
    var assetIDs:[String] = [String]()
    var isFollowing = false
    func dictToUser (dict:[String:Any], id:String, _ completation:@escaping (User)->()){
        
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
            let id = value?["id"] as? String ?? ""
            dispatchGroupe.enter()
            self.getUserUpdatedAssets(userId: id, completion: { user in
                dispatchGroupe.leave()
                followersObjArr.append(user)
            })
            
        }
        
        
        //group.wait()
        let followingArr = dict["following"] as? [Any]
        var followingObjArr = [User]()
        for i in followingArr ?? []{
            let value = i as? [String:Any]
            let id = value?["id"] as? String ?? ""
            dispatchGroupe.enter()
            self.getUserUpdatedAssets(userId: id, completion: { user in
                dispatchGroupe.leave()
                var us = user
                us.isFollowing = true
                followingObjArr.append(us)
            })
            
        }
        
        dispatchGroupe.notify(queue: .main) {
            
            let user = User(fullName: fullname, id: id, profileImage: profileImage, followings: followingObjArr, followers: followersObjArr, assetCount: assests.count, assetIDs: assests, isFollowing: isFollowing)
            completation(user)
            
        }
        
    }
    
    
    private func getUserUpdatedAssets(userId:String,  completion:@escaping ((User)->Void)){
        var asstes = [String]()
        FirebaseARService.shared.getDocument("users", document: userId).sink(receiveCompletion: { (completion) in
            switch completion
            {
            case .finished : break
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }) { (userSnap) in
            
            
            if userSnap.exists{
                let dict = userSnap.data()!
                for k in dict.keys{
                    if k != "fullName" &&  k != "profileImage" && k != "follower" && k != "following"{
                        asstes.append(k)
                    }
                }
                
                let name = userSnap.get("fullName") as? String ?? ""
                let profilePic = userSnap.get("profileImage") as? String ?? ""
                let user = User(fullName: name, id: userSnap.documentID, profileImage: profilePic, followings: [], followers: [], assetCount: asstes.count, assetIDs: [])
                
                
                completion(user)
            }
        }.store(in: &FirebaseARService.shared.cancelBag)
        
    }
}
