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
     func reloadUsers() {
        // get user collection
//        firebaseManager?.getCollection("users",hasLimit: true, limit: 10000 ,type: .snapshotQuery)
        
        IFirebase.shared.getUserList("users", limit: 10000)
            
            .sink(receiveCompletion: { (completion) in
                switch completion
                {
                case .finished : print("finish")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }) { (snapshot) in
                for doc in snapshot {
                    self.users.append(doc)
                }
                
                self.users.sort { (doc1, doc2) -> Bool in
                    return doc1.documentID.lowercased() < doc2.documentID.lowercased()
                }
                
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                }
        }.store(in: &IFirebase.shared.cancelBag)
    }
}

