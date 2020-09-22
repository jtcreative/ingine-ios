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
//extension AccountViewController: FirebaseAuthDelegate{
//    func auth(_ user: AuthDataResult?, type: FirebaseAuthType, isSuccess: Bool) {
//               switch type {
//         case .signIn:
//              self.spinnerView.stopAnimating()
//                self.loginRegisterButton.isUserInteractionEnabled = true
//              // if respone is success
//              if isSuccess{
//                  self.openMainViewController()
//              }
//
//             break
//         case .signUp:
//            self.spinnerView.stopAnimating()
//            self.loginRegisterButton.isUserInteractionEnabled = true
//            if isSuccess{
//                guard user != nil else {
//                    return
//                }
//                guard let email = emailTextField.text,
//                    let username = nameTextField.text else { return }
//
//                let userDict = ["fullName": username]
//                self.firebaseManager?.setDatabase(dict: userDict, collectionName: "users", documentName: email)
//            }
//             break
//         case .forgotPassword:
//            if isSuccess{
//                self.emailTextField.text = ""
//                self.displayAlert(title: "Success", message: "Password reset email sent!")
//            }
//             break
//
//               default:
//                break
//         }
//    }
//
//}

//MARK: Firestore Methods
//extension AccountViewController: FirebaseDatabaseDelegate{
//    func databaseUpdate(_ isSuccess: Bool) {
//        if isSuccess{
//             DispatchQueue.main.async {
//                self.dismiss(animated: true, completion: nil)
//                self.openMainViewController()
//            }
//        }else{
//             self.loginRegisterButton.isUserInteractionEnabled = false
//        }
//    }
//}




extension AccountViewController{
    
    
    func login( _ email: String, password:String){
        IFirebase.shared.signIn(email, password: password).sink(receiveCompletion: { (completion) in
            self.spinnerView.stopAnimating()
            self.loginRegisterButton.isUserInteractionEnabled = true
                   switch completion {
                   case .finished: print("finished")
                     self.openMainViewController()
                 
                   case .failure(let error): // Uh-oh, an error occurred!
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
                  print("User", user.user.email as Any)
              }.store(in: &IFirebase.shared.cancelBag)
    }
    
    
    func signUp( _ email: String, password:String){
        IFirebase.shared.signUp(email, password: password).sink(receiveCompletion: { (completion) in
            self.spinnerView.stopAnimating()
            self.loginRegisterButton.isUserInteractionEnabled = true
                   switch completion {
                    
                   case .finished: print("finished")
                  
                    
                     
                   case .failure(let error): // Uh-oh, an error occurred!
                    if let errCode = AuthErrorCode(rawValue: error._code) {
                        switch errCode {
                        case .invalidEmail:
                            self.displayAlert(title: "Invalid Email", message: "Please check your email format!")
                        case .emailAlreadyInUse:
                            self.displayAlert(title: "Email Already Registered", message: "Please use another email!")
                        case .weakPassword:
                            self.displayAlert(title: "Weak Password", message: "Your password is too weak!")
                        case .networkError:
                            self.displayAlert(title: "Netword Error", message: "No network connection!")
                        default:
                            print("unknown error")
                            print(error)
                        }
                    }
                         }
              }) { (user) in
                   guard let email = self.emailTextField.text,
                                         let username = self.nameTextField.text else { return }
                 let userDict = ["fullName": username]
                IFirebaseDatabase.shared.setData("users", document: email, data: userDict).sink(receiveCompletion: { (completion) in
                    switch completion {
                     
                    case .finished: print("finished")
                    case .failure(_): break
                    }
                }) { (_) in
                    
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                        self.openMainViewController()
                    }
                }.store(in: &IFirebaseDatabase.shared.cancelBag)
        }.store(in: &IFirebaseDatabase.shared.cancelBag)
    }
    
    //
    func forgotPassword( _ email: String){
        IFirebase.shared.forget(email).sink(receiveCompletion: { (completion) in
            switch completion {
            case .finished: print("finished")
            self.emailTextField.text = ""
            self.displayAlert(title: "Success", message: "Password reset email sent!")
            case .failure(let error): // Uh-oh, an error occurred!
                if let errCode = AuthErrorCode(rawValue: error._code) {
                    switch errCode {
                    case .invalidEmail:
                        self.displayAlert(title: "Invalid Email", message: "Please check your email format!")
                    case .networkError:
                        self.displayAlert(title: "Netword Error", message: "No network connection!")
                    case .userNotFound:
                        self.displayAlert(title: "No User Found", message: "No user record found!")
                    default:
                        print("unknown error")
                        print(error)
                    }
                }
            }
        }) { (_) in
        }.store(in: &IFirebase.shared.cancelBag)
    }
}
