//
//  ProfileViewController.swift
//  ingine
//
//  Created by McNels on 6/3/19.
//  Copyright © 2019 ingine. All rights reserved.
//

import Foundation
import UIKit
import SafariServices
import FirebaseAuth
import FirebaseFirestore

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
struct TestItem:Codable {
    var id :String?
    var name:String?
    var refImage:String?
    var matchURL:String?
    var `public` :Bool?
}



class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var itemsArray : [IngineeredItem] = [IngineeredItem]()
 
    @IBOutlet weak var ingineeredItemsTableView: UITableView!
    
    @IBOutlet weak var profileHeaderView: ProfileViewHeader!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var header: UIView!
    var userImage = ""
     var firebaseSnapshotId = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // init firebase manager
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)
        
        // Set delegate and data source
        ingineeredItemsTableView.delegate = self
        ingineeredItemsTableView.dataSource = self
        
        // Configure table view
        configureTableView()
        addFollowers()
        // Check if user logged in by email
        isLoggedIn()
        
        // retrieve ingineered items
        retrieveItems()
        setupProfileHeader()
        // ingineeredItemsTableView.separatorStyle = .none
        
        
        
    }
    
    
    func addFollowers()
    {
         let id = Auth.auth().currentUser?.email ?? ""
        
        let dict = ["follower":[["userId":"userid1234","username":"Mike"],["userId":"userid89ds","username":"John"]]]
        Firestore.firestore().collection("users").document(id).updateData(dict) { (error) in
            if let error = error{
                 print("Document error:\(error)")
            }else{
                print("Document is written successfully")
            }
        }
    }
    
    // setup profile header view
    private func setupProfileHeader(){
        profileHeaderView.profileView.setRadius(profileHeaderView.profileView.frame.height / 2)
        profileHeaderView.settingButton.addTarget(self, action: #selector(openProfileSetting), for: .touchUpInside)
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
        
        DispatchQueue.global().async {
            let imageData:NSData = NSData(contentsOf: imageUrl)! //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            DispatchQueue.main.async {
                cell.refImage.image = UIImage(data: imageData as Data)
            }
        }
        
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
    
    
    
    @objc func openProfileSetting(){
         performSegue(withIdentifier: "profileSettings", sender: nil)
    }
    
   
    @IBAction func goBackHome() {
        //performSegue(withIdentifier: "toHome", sender: nil)
        if let mainViewController = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController as? MainViewController {
            //performSegue(withIdentifier: "toProfile", sender: nil)
            mainViewController.backPage()
     }
        //
        
        
      
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "profileSettings" {
            if let controller = segue.destination as? ProfileSettingsViewController{
//                controller.userImageStr = userImage
            }
        }
    }
    
    
    /////////////////////////////////////////////////////////////////////////////
    
    // handle swipe gestures from home screen
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        /*if (sender.direction == .right) {
            print("Swipe Right")
            // go back home
            goBackHome()
        }*/
    }
    
    
    @IBAction func signOut(_ sender: Any) {
       
//        firebaseManager?.signOut()
        IFirebase.shared.signOut().sink(receiveCompletion: { (completion) in
            switch completion{
            case .finished: print("fnished")
            case .failure(let error) : print(error.localizedDescription)
            }
        }) { (_) in
            print("Sign out pressed")
            let login = AccountViewController()
            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = login
        }.store(in: &IFirebase.shared.cancelBag)
    
        
    }

    
}

extension ProfileViewController {
    override var supportedInterfaceOrientations:UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
}
