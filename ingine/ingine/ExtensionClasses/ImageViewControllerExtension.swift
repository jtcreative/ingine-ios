//
//  ImageViewControllerExtension.swift
//  ingine
//
//  Created by Manish Dadwal on 31/08/20.
//  Copyright © 2020 ingine. All rights reserved.
//


import Foundation
import Firebase


//MARK: Auth Methods
extension ImageViewController: FirebaseStorageDelegate{
    func media(_ url: String?, isSuccess: Bool, type: FirebaseStorageType) {
        switch type {
        case .image:
            if !isSuccess{
                return
            }
            self.storageURL = url ?? ""
            var matchURL = ""
            let itemName = self.nameBox.text ?? ""
            let email = Auth.auth().currentUser?.email ?? ""
            if self.urlBox.text?.hasPrefix("https://") ?? false || self.urlBox.text?.hasPrefix("http://") ?? false {
                matchURL = self.urlBox.text ?? ""
            }else {
                matchURL = "http://\(self.urlBox.text ?? "")"
            }
            
            let dict = [
                "name": itemName,
                "refImage": self.storageURL,
                "matchURL": matchURL,
                "user": email,
                "public": self.visibilitySwitch.isOn
                ] as [String : Any]
            firebaseManager?.updateDocument(dict: dict, collectionName: "pairs", type: .docRef)
          
            
            
            
            
            
        default:
            break
        }
    }
   
}

//MARK: Database Methods
extension ImageViewController: FirebaseDatabaseDelegate{
    func databaseUpdate(_ isSuccess: Bool) {
        if isSuccess{
                let st = UIStoryboard.init(name: "Main", bundle: Bundle.main)
            let vc = st.instantiateInitialViewController()
            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = vc
        }
    }
    
    func databaseDocRef(ref: DocumentReference?, isSuccess: Bool, type:FirebaseDatabaseType) {
        switch type {
        case .docRef:
            if !isSuccess{
                return
            }
              let email = Auth.auth().currentUser?.email ?? ""
            // Save a reference in users folder
            let documentRefString = self.db.collection("pairs").document(ref?.documentID ?? "")
            let userRefKey = ref?.documentID
            
              let dict = [
                  userRefKey ?? "" : self.db.document(documentRefString.path)
              ]
              firebaseManager?.updateData(dict: dict, collectionName: "users", documentName: email)
            
        default:
            break
        }
    }
    
}

