//
//  OptionsLauncher.swift
//  ingine
//
//  Created by McNels on 8/17/19.
//  Copyright © 2019 ingine. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth

class Option: NSObject {
    // Add buttons here/or uiviews
    
    let name: String
    let imageName: String
    
    init(name: String, imageName: String) {
        self.name = name
        self.imageName = imageName
    }
}

class OptionsLauncher: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

//    var profileController : ProfileViewController?
    var db: Firestore! = Firestore.firestore()
    var itemID : String = ""
    
    let blackView = UIView()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        if #available(iOS 13.0, *) {
            cv.backgroundColor = UIColor.tertiarySystemBackground
        } else {
            // Fallback on earlier versions
            cv.backgroundColor = UIColor.white
        }
        return cv
    }()
    
    let cellId = "cellId"
    let cellHeight: CGFloat = 50
    
    let options: [Option] = {
        return [Option(name: "Edit URL", imageName: "settings"), Option(name: "Change visibility", imageName: "privacy"), Option(name: "Delete item", imageName: "cancel")]
    }()
    
    
    func showOptions(identification: String) {
        itemID = identification
        
        //show menu
        if let window = UIApplication.shared.keyWindow {
            
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            
            window.addSubview(blackView)
            
            window.addSubview(collectionView)
            
            let height: CGFloat = CGFloat(options.count) * cellHeight
            let y = window.frame.height - height
            collectionView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
            
            blackView.frame = window.frame
            blackView.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackView.alpha = 1
                
                self.collectionView.frame = CGRect(x:0, y: y, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
                
            }, completion: nil)
        }
    }
    
    @objc func handleDismiss() {
        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 0
            
            if let window = UIApplication.shared.keyWindow {
                self.collectionView.frame = CGRect(x: 0, y: window.frame.height, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! OptionCell
        
        let option = options[indexPath.item]
        cell.option = option
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    @objc func handleSelection(choice: Option) {
        UIView.animate(withDuration: 0.5, animations: {
            self.blackView.alpha = 0
            
            if let window = UIApplication.shared.keyWindow {
                self.collectionView.frame = CGRect(x: 0, y: window.frame.height, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
            }
        }, completion: { (_) in
            if choice.name != "" {
                self.showAlertForSelectedOption(selection: choice)
            }
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let option = self.options[indexPath.item]
        handleSelection(choice: option)
    }
    
    // handle what happens when one of the "more options" items is selected
    func showAlertForSelectedOption(selection: Option) {
        if selection.name == "Edit URL" {
            print("edit URL button clicked")
            // use itemID to handle bihniss
            let alert = UIAlertController(title: "Edit URL", message: "Insert new URL down below:", preferredStyle: .alert)
            
            alert.addTextField(configurationHandler: { textField in
                textField.placeholder = "Insert new URL here..."
            })
            
            alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { action in
                self.editURL(url: alert.textFields?.first?.text ?? "")
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                self.handleDismiss()
            }))
            
            print("about to display...")
            var topViewController = UIApplication.shared.keyWindow?.rootViewController
            while topViewController?.presentedViewController != nil {
                topViewController = topViewController?.presentedViewController!
            }
            
            topViewController?.present(alert, animated: true)
//            self.profileController?.present(alert, animated: true)
            
        } else if selection.name == "Change visibility" {
            print("change visibility button clicked")
            let alert = UIAlertController(title: "Select new visibility setting", message: "Select new visibility setting", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Public", style: .default, handler: { action in
                self.changeVisTo(vis: action.title ?? "")
            }))
            alert.addAction(UIAlertAction(title: "Private", style: .default, handler: { action in
                self.changeVisTo(vis: action.title ?? "")
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                self.handleDismiss()
            }))
            
            var topViewController = UIApplication.shared.keyWindow?.rootViewController
            while topViewController?.presentedViewController != nil {
                topViewController = topViewController?.presentedViewController!
            }
            
            topViewController?.present(alert, animated: true)
            
        } else if selection.name == "Delete item" {
            print("delete item button clicked")
            let alert = UIAlertController(title: "Delete item", message: "Are you sure?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { action in
                self.deleteItem()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                self.handleDismiss()
            }))
            
            var topViewController = UIApplication.shared.keyWindow?.rootViewController
            while topViewController?.presentedViewController != nil {
                topViewController = topViewController?.presentedViewController!
            }
            
            topViewController?.present(alert, animated: true)
        }
        
    }
    
    
    // EDIT NAME
    func editURL(url: String) {
        print("trying to edit")
        var link : String = ""
        if !url.hasPrefix("https://") || !url.hasPrefix("http://") {
            link = "http://\(url)"
        }else {
            link = url
        }
        
        if Auth.auth().currentUser?.uid != nil {
            let dict = [
                "matchURL" : link
            ]
           // firebaseManager?.updateData(dict: dict, collectionName: "pairs", documentName: itemID)
            IFirebaseDatabase.shared.updateData("pairs", document: itemID, data: dict).sink(receiveCompletion: { (completion) in
                switch completion
                {
                case .finished : print("finish")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }) { (_) in
                 self.handleDismiss()
            }.store(in: &IFirebaseDatabase.shared.cancelBag)
            
            
            
        } else {
            print("not logged in at editing url screen")
        }
        
        
    }
    
    // DELETE ITEM
    func deleteItem() {
        print("trying to delete")
        if Auth.auth().currentUser?.uid != nil {
//            firebaseManager?.deleteDocument("pairs", documentName: itemID, type: .deleteDoc)
            IFirebaseDatabase.shared.deleteDocument("pairs", document: itemID).sink(receiveCompletion: { (completion) in
                           switch completion
                           {
                           case .finished : print("finish")
                           case .failure(let error):
                               print(error.localizedDescription)
                           }
                       }) { (_) in
                            self.handleDismiss()
                       }.store(in: &IFirebaseDatabase.shared.cancelBag)
                       
            
        } else {
            print("not logged in at deleting item screen")
        }
        
      //  self.handleDismiss()
    }
    
    // CHANGE VISIBILITY
    func changeVisTo(vis: String) {
        print("trying to change visibility")
        var status = false
        if vis == "Public" {
            status = true
        } else {
            status = false
        }
        
        if Auth.auth().currentUser?.uid != nil {
            let dict = [
                "public" : status
            ]
//            firebaseManager?.updateData(dict: dict, collectionName: "pairs", documentName: itemID)
          IFirebaseDatabase.shared.updateData("pairs", document: itemID, data: dict).sink(receiveCompletion: { (completion) in
                         switch completion
                         {
                         case .finished : print("finish")
                         case .failure(let error):
                             print(error.localizedDescription)
                         }
                     }) { (_) in
                          self.handleDismiss()
                     }.store(in: &IFirebaseDatabase.shared.cancelBag)
                     
            
        } else {
            print("not logged in at changing visibilty screen")
        }
        
        self.handleDismiss()
    }
    
    override init() {
        super.init()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(OptionCell.self, forCellWithReuseIdentifier: cellId)
    }
    
}
