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


extension ProfileViewController{
     // Check if user is logged in
        func isLoggedIn() {
            if Auth.auth().currentUser?.uid != nil {
                let id = Auth.auth().currentUser?.email ?? ""
                
                FirebaseARService.shared.getDocument("users", document: id).sink(receiveCompletion: { (completion) in
                    switch completion
                                  {
                                  case .finished : print("finish")
                                  case .failure(let error):
                                      print(error.localizedDescription)
                                  }
                }) { (snapshot) in
                    if snapshot.exists {
                        // set title of profile page to full name of logged in user
//                        self.userName.text = snapshot.data()?["fullName"] as? String
                        
                        
                        // get following
                        let followingArray = snapshot.get("following") as? [Any]
                        
                        // get followers
                        let followerArray = snapshot.get("follower") as? [Any]
                        
                        self.profileHeaderView.followerAndFollowingLabel.text = "Following \(followingArray?.count ?? 0 ) | \(followerArray?.count ?? 0 > 1 ? "Followers" : "Follower") \(followerArray?.count ?? 0)"
                        
                        
                        self.profileHeaderView.userName.text = snapshot.data()?["fullName"] as? String
                        
                        if let userImageUrl = snapshot.data()?["profileImage"] as? String{
                            let imageUrl = URL(string: userImageUrl)!
                            let imageData:NSData = NSData(contentsOf: imageUrl)!
                            self.profileHeaderView.profileImage.image = UIImage(data: imageData as Data)
                        }
                       
                         
                        
                    } else {
                        print("user does not exist")
                    }
                }.store(in: &FirebaseARService.shared.cancelBag)
                
            } else {
                print("not logged in by email")
                // send to login screen
                let login = LoginViewController()
                (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = login
            }
            
        }
    
    // Retrieve ingineered item infro from firebase
       func retrieveItems() {
           print("retrieving data from firebase...")
        if Auth.auth().currentUser?.uid == nil {
            return
        }
           
           // Populate cell elements with data from firebase
            let id = Auth.auth().currentUser?.email ?? ""
           
        //   firebaseManager?.getDocuments("users", documentName: id, type: .multipleItem)
        FirebaseARService.shared.getUser("users", document: id).sink(receiveCompletion: { (completion) in
            switch completion
            {
            case .finished : print("finish")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }) { (snapShot) in
             guard snapShot.data() != nil else {
                              print("Document data was empty.")
                              return
                          }
                          
                          
            if snapShot.exists {
                for k in snapShot.data()!.keys {
                    if k != "fullName" {
                        FirebaseARService.shared.getAssetList("pairs", document: k).sink(receiveCompletion: { (completion) in
                            switch completion
                            {
                            case .finished : print("finish")
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }) { (shot) in
                           
                            var item = IngineeredItem()
                                item.id = k
                            item.itemName = shot.name ?? ""
                            item.refImage = shot.refImage ?? ""
                            item.itemURL = shot.matchURL ?? ""
                            item.visStatus = shot.public ?? false
                            self.itemsArray.append(item)
                           
                            self.itemsArray = self.itemsArray.unique{$0.id}
                            print(self.itemsArray)
                            self.profileHeaderView.arPostCount.text = "\(self.itemsArray.count)"
                            self.configureTableView()
                            DispatchQueue.main.async {
                                self.ingineeredItemsTableView.reloadData()
                            }
                            
                        }.store(in: &FirebaseARService.shared.cancelBag)
                        
                        
                    }else {
                        print("k is fullName")
                    }
                    
                }
            }
        }.store(in: &FirebaseARService.shared.cancelBag)

           
       }
       
}
extension Array {
    func unique<T:Hashable>(map: ((Element) -> (T)))  -> [Element] {
        var set = Set<T>() //the unique list kept in a Set for fast retrieval
        var arrayOrdered = [Element]() //keeping the unique list of elements but ordered
        for value in self {
            if !set.contains(map(value)) {
                set.insert(map(value))
                arrayOrdered.append(value)
            }
        }

        return arrayOrdered
    }
}
