//
//  AccountViewControllerExtension.swift
//  ingine
//
//  Created by Manish Dadwal on 31/08/20.
//  Copyright © 2020 ingine. All rights reserved.
//

import UIKit
import FirebaseAuth


//MARK: Auth Methods
extension AccountViewController: FirebaseAuthDelegate{
    func auth(_ user: AuthDataResult?, type: FirebaseAuthType, isSuccess: Bool) {
               switch type {
         case .signIn:
              self.spinnerView.stopAnimating()
                self.loginRegisterButton.isUserInteractionEnabled = true
              // if respone is success
              if isSuccess{
                  self.openMainViewController()
              }
        
             break
         case .signUp:
            self.spinnerView.stopAnimating()
            self.loginRegisterButton.isUserInteractionEnabled = true
            if isSuccess{
                guard user != nil else {
                    return
                }
                guard let email = emailTextField.text,
                    let username = nameTextField.text else { return }
                    
                let userDict = ["fullName": username]
                self.firebaseManager?.setDatabase(dict: userDict, collectionName: "users", documentName: email)
            }
             break
         case .forgotPassword:
            if isSuccess{
                self.emailTextField.text = ""
                self.displayAlert(title: "Success", message: "Password reset email sent!")
            }
             break
                
               default:
                break
         }
    }
    
}

//MARK: Firestore Methods
extension AccountViewController: FirebaseDatabaseDelegate{
    func databaseUpdate(_ isSuccess: Bool) {
        if isSuccess{
             DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
                self.openMainViewController()
            }
        }else{
             self.loginRegisterButton.isUserInteractionEnabled = false
        }
    }
}
