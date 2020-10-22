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
                    let user = User().dictToUser(dict: doc.data(), id: doc.documentID)
                    self.users.append(user)
                }
                
                self.users.sort { (doc1, doc2) -> Bool in
                    return doc1.id.lowercased() < doc2.id.lowercased()
                }
                
//                DispatchQueue.main.async {
//                    //self.refreshControl?.endRefreshing()
//                    self.tableView.reloadData()
//                }
        }.store(in: &IFirebase.shared.cancelBag)
    }
}

