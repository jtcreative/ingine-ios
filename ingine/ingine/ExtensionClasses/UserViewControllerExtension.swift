//
//  UserViewControllerExtension.swift
//  ingine
//
//  Created by Manish Dadwal on 02/09/20.
//  Copyright © 2020 ingine. All rights reserved.
//

import UIKit
import Firebase
extension UserViewController:FirebaseDatabaseDelegate{
    
    func query(_ document: [QueryDocumentSnapshot], isSuccess: Bool, type: FirebaseDatabaseType) {
        switch type {
        case .snapshotQuery:
            for doc in document {
                self.users.append(doc)
            }
            
            self.users.sort { (doc1, doc2) -> Bool in
                return doc1.documentID.lowercased() < doc2.documentID.lowercased()
            }
            
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        default:
            break
        }
    }
    
    
}
