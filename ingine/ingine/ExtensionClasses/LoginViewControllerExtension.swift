//
//  LoginViewControllerExtension.swift
//  ingine
//
//  Created by Manish Dadwal on 25/09/20.
//  Copyright © 2020 ingine. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
extension LoginViewController{
    override var supportedInterfaceOrientations:UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    func login( _ email: String, password:String){
        
        Loader.start()
        
        FirebaseUserService.shared.signIn(email, password: password).sink(receiveCompletion: { (completion) in
            switch completion {
            case .finished: print("login finished")
             
                
            case .failure(let error): // Uh-oh, an error occurred!
                Loader.stop()
                if let errCode = AuthErrorCode(rawValue: error._code) {
                    switch errCode {
                    case .userNotFound:
                        self.displayAlert(title: "Email Not Found", message: "Please check your email!")
                    case .invalidEmail:
                        self.displayAlert(title: "Invalid Email", message: "Please check your email format!")
                    case .wrongPassword:
                        self.displayAlert(title: "Wrong Password", message: "Please check your password!")
                    case .networkError:
                        self.displayAlert(title: "Netword Error", message: "No network connection!")
                    default:
                        print("unknown error")
                        print(error)
                    }
                }
            }
        }) { (user) in
           // upload AR image
             guard let imageData = self.arImage.image?.jpegData(compressionQuality: 0.8) else {
                 
                 self.openMainViewController()
                 return
                 
             }
             self.uploadArImage(imageData)
            
        }.store(in: &FirebaseUserService.shared.cancelBag)
    }
    
    // uplod ar asset image
    func uploadArImage(_ imageData:Data){
        // upload image
        FirebaseStorageService.shared.uploadImage(imageData).sink(receiveCompletion: { (completion) in
            switch completion
            {
            case .finished : print("photo uploaded finish")
            case .failure(let error):
                Loader.stop()
                print(error.localizedDescription)
            }
        }) { (url) in
            // update doucment
            self.updateARDataInDocument(url: url)
          

        }.store(in: &FirebaseStorageService.shared.cancelBag)
    }
    
    
    private func updateARDataInDocument(url:String){
        var matchURL = ""
        // update Asset url to pairs document
        let itemName = self.arData?.name ?? ""
        let email = Auth.auth().currentUser?.email ?? ""
        if self.arData?.url?.hasPrefix("https://") ?? false || self.arData?.url?.hasPrefix("http://") ?? false {
            matchURL = self.arData?.url ?? ""
        }else {
            matchURL = "http://\(self.arData?.url ?? "")"
        }
        
        let dict = [
            "name": itemName,
            "refImage": url,
            "matchURL": matchURL,
            "user": email,
            "public": self.arData?.visibilty ?? false,
            "lastupdated":Date()
        ] as [String : Any]
        
        
        FirebaseARService.shared.addDocument("pairs", data: dict).sink(receiveCompletion: { (completion) in
            switch completion
            {
            case .finished : print("ar asesst updated finish")
            case .failure(let error):
                Loader.stop()
                print(error.localizedDescription)
            }
        }, receiveValue: { (ref) in
            
            self.updateUserDocument(ref)
            
        }).store(in: &FirebaseARService.shared.cancelBag)
    }
    
    
  private  func updateUserDocument(_ ref:DocumentReference){
        // update users document with pairs ref
        let email = Auth.auth().currentUser?.email ?? ""
        // Save a reference in users folder
        let documentRefString = self.db.collection("pairs").document(ref.documentID)
        let userRefKey = ref.documentID
        
        let dict = [
            userRefKey: self.db.document(documentRefString.path)
        ]
        FirebaseARService.shared.updateData("users", document: email, data: dict).sink(receiveCompletion: { (completion) in
            Loader.stop()
            switch completion
            {
            case .finished : print("asset in user document finish")
            case .failure(let error):
                
                print(error.localizedDescription)
            }
        }) { (_) in
            // all requests done send to next screen
           
            self.openMainViewController()
        }.store(in: &FirebaseARService.shared.cancelBag )
    }
    
}
