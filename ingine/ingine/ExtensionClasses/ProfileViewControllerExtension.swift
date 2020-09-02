//
//  ProfileViewControllerExtension.swift
//  ingine
//
//  Created by Manish Dadwal on 31/08/20.
//  Copyright © 2020 ingine. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

//MARK: Auth Methods
extension ProfileViewController: FirebaseAuthDelegate{
    func auth(_ user: AuthDataResult?, type: FirebaseAuthType, isSuccess: Bool) {
        switch type {
        case .signOut:
            break
        default:
            break
        }
    }
}

//MARK: Database Methods
extension ProfileViewController: FirebaseDatabaseDelegate{
    
    
    
    func databaseDocument(_ snapshot: DocumentSnapshot?, isSuccess: Bool, type:FirebaseDatabaseType) {
        
        switch type {
        case .singleItem:
            if let ref = snapshot, ref.exists {
                var item = IngineeredItem()
                item.id = firebaseSnapshotId
                item.itemName = (ref.data()?["name"] as? String)!
                item.refImage = (ref.data()?["refImage"] as? String)!
                item.itemURL = (ref.data()?["matchURL"] as? String)!
                item.visStatus = (ref.data()?["public"] as? Bool)!
                
                self.itemsArray.append(item)
                self.configureTableView()
                self.ingineeredItemsTableView.reloadData()
            } else {
                // couldn't get document referred to
            }
            break
        case .multipleItem:
            if isSuccess{
                guard let document1 = snapshot else {
                    print("Error fetching snapshots")
                    return
                }
                guard document1.data() != nil else {
                    print("Document data was empty.")
                    return
                }
                
                
                if let document = snapshot, document.exists {
                    // iterate over fields for the logged in user, looking for the field names
                    
                    for k in document.data()!.keys {
                        if k != "fullName" {
                            firebaseSnapshotId = k
                            firebaseManager?.getSingleDocument("pairs", documentName: k, type: .singleItem)
                        } else {
                            print("k is fullName")
                        }
                    }
                    
                }
            }
            
        case .user:
            if let document = snapshot, document.exists {
                // set title of profile page to full name of logged in user
                self.userName.text = document.data()?["fullName"] as? String
                
            } else {
                print("user does not exist")
            }
            default:
            break
        }
        
        
    }
}

