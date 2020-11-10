//
//  ImageViewControllerExtension.swift
//  ingine
//
//  Created by Manish Dadwal on 31/08/20.
//  Copyright © 2020 ingine. All rights reserved.
//


import Foundation
import FirebaseAuth


extension ImageViewController{
    
    func uploadArImage(_ imageData:Data){
        FirebaseStorageService.shared.uploadImage(imageData).sink(receiveCompletion: { (completion) in
            switch completion
            {
            case .finished : print("finish")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }) { (url) in
            self.storageURL = url
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
            
            
            FirebaseARService.shared.addDocument("pairs", data: dict).sink(receiveCompletion: { (completion) in
                switch completion
                {
                case .finished : print("finish")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }, receiveValue: { (ref) in
                let email = Auth.auth().currentUser?.email ?? ""
                // Save a reference in users folder
                let documentRefString = self.db.collection("pairs").document(ref.documentID)
                let userRefKey = ref.documentID
                
                let dict = [
                    userRefKey: self.db.document(documentRefString.path)
                ]
                FirebaseARService.shared.updateData("users", document: email, data: dict).sink(receiveCompletion: { (completion) in
                    switch completion
                    {
                    case .finished : print("finish")
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }) { (_) in
                    let st = UIStoryboard.init(name: "Main", bundle: Bundle.main)
                    let vc = st.instantiateViewController(identifier: "MainViewController")
                    (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = vc
                }.store(in: &FirebaseARService.shared.cancelBag )
            }).store(in: &FirebaseARService.shared.cancelBag)
            
            
        }.store(in: &FirebaseStorageService.shared.cancelBag)
    }
}
 
