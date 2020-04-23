//
//  ProfileViewController.swift
//  ingine
//
//  Created by McNels on 6/3/19.
//  Copyright © 2019 ingine. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SafariServices

//class Setting: NSObject {
//    let name: String
//    let imageName: String
//
//    init(name: String, imageName: String) {
//        self.name = name
//        self.imageName = imageName
//    }
//}

class IngineeredItemViewCell: UITableViewCell {

    @IBOutlet weak var refImage: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemURL: UILabel!
    @IBOutlet weak var visibilityStatus: UILabel!
    @IBOutlet weak var timeStamp: UILabel!
    var id : String = ""

    let optionsLauncher = OptionsLauncher()
    @IBAction func showOptions(_ sender: UIButton) {
        optionsLauncher.showOptions(identification: id)

    }
    

    
}

struct IngineeredItem {
    var id = ""
    var refImage = ""
    var itemName = ""
    var itemURL = ""
    var visStatus = false
}

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var itemsArray : [IngineeredItem] = [IngineeredItem]()
    var db : Firestore!
    @IBOutlet weak var ingineeredItemsTableView: UITableView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var header: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)
        
        // Set delegate and data source
        ingineeredItemsTableView.delegate = self
        ingineeredItemsTableView.dataSource = self
        
        // Configure table view
        configureTableView()
        
        // Check if user logged in by email
        isLoggedIn()
        
        // retrieve ingineered items
        retrieveItems()
        
        // ingineeredItemsTableView.separatorStyle = .none
        
    }
    
    // Check if user is logged in
    func isLoggedIn() {
        if Auth.auth().currentUser?.uid != nil {
            let id = Auth.auth().currentUser?.email ?? ""
            db.collection("users").document(id).getDocument { (document, error) in
                if let document = document, document.exists {
                    // set title of profile page to full name of logged in user
                    self.userName.text = document.data()?["fullName"] as? String
    
                } else {
                    print("user does not exist")
                }
            }
        } else {
            print("not logged in by email")
            // send to login screen
            let login = AccountViewController()
            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = login
        }
        
    }
    
    // Configure table view height
    func configureTableView() {
        ingineeredItemsTableView.rowHeight = UITableView.automaticDimension
        ingineeredItemsTableView.estimatedRowHeight = 120
    }
    
    // Set cells data in table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "igItemCell", for: indexPath) as! IngineeredItemViewCell
        
        // set cell fields info from firebase
        cell.id = itemsArray[indexPath.row].id
        let imageUrl = URL(string: itemsArray[indexPath.row].refImage)!
        let imageData:NSData = NSData(contentsOf: imageUrl)!
        cell.refImage.image = UIImage(data: imageData as Data)
        cell.itemName.text = itemsArray[indexPath.row].itemName
        cell.itemURL.text = itemsArray[indexPath.row].itemURL
        if itemsArray[indexPath.row].visStatus {
            cell.visibilityStatus.text = "Public"
        } else {
            cell.visibilityStatus.text = "Private"
        }

        return cell
    }
    
    // Set number of rows in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsArray.count
    }
    
    // show url on cell clicked
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("row selected: \(indexPath.row)")
        guard let url = URL(string: itemsArray[indexPath.row].itemURL) else {
            //Show an invalid URL error alert
            return
        }
        

        // Show the associated link in the in-app browser
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
        
    }
    
    // Retrieve ingineered item infro from firebase
    func retrieveItems() {
        print("retrieving data from firebase...")
        
        // Populate cell elements with data from firebase
        if Auth.auth().currentUser?.uid != nil {
            let id = Auth.auth().currentUser?.email ?? ""
            let itemsDB = db.collection("users").document(id)
            
            itemsDB.addSnapshotListener { documentSnapshot, error in
                guard let document1 = documentSnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                guard document1.data() != nil else {
                    print("Document data was empty.")
                    return
                }
                
                if let document = documentSnapshot, document.exists {
                    // iterate over fields for the logged in user, looking for the field names
                    for k in document.data()!.keys {
                        if k != "fullName" {
                            self.db.collection("pairs").document(k).getDocument { (reference, error) in
                                if let ref = reference, ref.exists {
                                    var item = IngineeredItem()
                                    item.id = k
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
                            }
                            
                        } else {
                            print("k is fullName")
                        }
                    }

                }

            }
                
        }
        
    }
    
    /////////////////////////////////////////////////////////////////////////////
    
    // handle swipe gestures from home screen
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        if (sender.direction == .right) {
            print("Swipe Right")
            // go back home
            performSegue(withIdentifier: "toHome", sender: nil)
        }
    }
    
    
    @IBAction func signOut(_ sender: Any) {
        print("sign out button pressed")
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
//            performSegue(withIdentifier: "toHome", sender: nil)
//            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
    }

    
}

extension ProfileViewController {
    override var supportedInterfaceOrientations:UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
}
