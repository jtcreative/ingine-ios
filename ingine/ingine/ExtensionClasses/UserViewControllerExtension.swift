//
//  UserViewControllerExtension.swift
//  ingine
//
//  Created by Manish Dadwal on 02/09/20.
//  Copyright © 2020 ingine. All rights reserved.
//

import UIKit
import Firebase

extension UserViewController {
    func reloadUsers(name:String, forType searchType:SearchType) {
        // get user collection
         switch searchType {
        case .following:
            queryFollowing(name: name)
        case .follower:
            queryFollowers(name: name)
        default:
            queryAll(name: name)
        }
    }
    
    private func queryAll(name:String) {
        FirebaseUserService.shared.searchUser(name, collection: "users", limit: 20)
            .sink(receiveCompletion: { (completion) in
                switch completion
                {
                case .finished : print("finish")
                case .failure(let error):
                    print(error.localizedDescription)
                    self.users.removeAll()
                    self.tableView.reloadData()
                }
            }) { (snapshot) in
                let users = snapshot.map { (snap) -> User in
                    User().dictToUser(dict: snap.data(), id: snap.documentID)
                }
                self.clearAndResetUserSortedData(users: users)
        }.store(in: &FirebaseUserService.shared.cancelBag)
    }
    
    private func queryFollowers(name:String) {
        FirebaseUserService.shared.searchFollowers(name, collection: "users", limit: 20)
            .sink(receiveCompletion: { (completion) in
                switch completion
                {
                case .finished : print("finish")
                case .failure(let error):
                    print(error.localizedDescription)
                    self.users.removeAll()
                    self.tableView.reloadData()
                }
            }) { (snapshot) in
                self.clearAndResetUserSortedData(users: snapshot)
        }.store(in: &FirebaseUserService.shared.cancelBag)
    }
    
    private func queryFollowing(name:String) {
        FirebaseUserService.shared.searchFollowings(name, collection: "users", limit: 20)
            .sink(receiveCompletion: { (completion) in
                switch completion
                {
                case .finished : print("finish")
                case .failure(let error):
                    print(error.localizedDescription)
                    self.users.removeAll()
                    self.tableView.reloadData()
                }
            }) { (snapshot) in
                self.clearAndResetUserSortedData(users: snapshot)
        }.store(in: &FirebaseUserService.shared.cancelBag)
    }
    
    private func clearAndResetUserSortedData(users:[User]) {
        self.users.removeAll()
        for user in users {
            
            self.users.append(user)
        }
        
        self.users.sort { (user1, user2) -> Bool in
            return (user1.fullName.lowercased() < user2.fullName.lowercased())
        }
        
        DispatchQueue.main.async {
            self.isUserSearching = false
            self.tableView.reloadData()
        }
    }
    
}

