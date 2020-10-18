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
        IFirebase.shared.searchUser(name, collection: "users", limit: 20)
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
                self.users.removeAll()
                for doc in snapshot {
                    var data = doc.data()
                    data["userId"] = doc.documentID
                    self.users.append(data)
                }
                
                self.users.sort { (doc1, doc2) -> Bool in
                    let doc1Str = doc1["fullName"] as! String
                    let doc2Str = doc1["fullName"] as! String
                    
                    return (doc1Str.lowercased() < doc2Str.lowercased())
                }
                
                DispatchQueue.main.async {
                    //self.refreshControl?.endRefreshing()
                    self.isUserSearching = false
                    self.tableView.reloadData()
                }
        }.store(in: &IFirebase.shared.cancelBag)
    }
    
    private func queryFollowers(name:String) {
        IFirebase.shared.searchFollowers(name, collection: "users", limit: 20)
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
                self.users.removeAll()
                for doc in snapshot {
                    self.users.append(doc)
                }
                
                self.users.sort { (doc1, doc2) -> Bool in
                    let doc1Str = doc1["fullName"] as! String
                    let doc2Str = doc1["fullName"] as! String
                    
                    return (doc1Str.lowercased() < doc2Str.lowercased())
                }
                
                DispatchQueue.main.async {
                    //self.refreshControl?.endRefreshing()
                    self.isUserSearching = false
                    self.tableView.reloadData()
                }
        }.store(in: &IFirebase.shared.cancelBag)
    }
    
    private func queryFollowing(name:String) {
        IFirebase.shared.searchFollowings(name, collection: "users", limit: 20)
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
                self.users.removeAll()
                for doc in snapshot {
                    self.users.append(doc)
                }
                
                self.users.sort { (doc1, doc2) -> Bool in
                    let doc1Str = doc1["fullName"] as! String
                    let doc2Str = doc1["fullName"] as! String
                    
                    return (doc1Str.lowercased() < doc2Str.lowercased())
                }
                
                DispatchQueue.main.async {
                    //self.refreshControl?.endRefreshing()
                    self.isUserSearching = false
                    self.tableView.reloadData()
                }
        }.store(in: &IFirebase.shared.cancelBag)
    }
    
}

