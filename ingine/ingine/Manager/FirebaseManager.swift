//
//  FirebaseManager.swift
//  ingine
//
//  Created by Manish Dadwal on 31/08/20.
//  Copyright © 2020 ingine. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

//MARK: Firebase Constants

enum FirebaseAuthType{
    case signIn, signUp,signOut,forgotPassword
}


@objc enum FirebaseDatabaseType:Int{
    case singleItem, multipleItem, user, docRef, deleteDoc,query, snapshotQuery
}

@objc enum FirebaseStorageType:Int{
    case image
}

//MARK: Firebase Protocols

// TODO: Firebase Auth

protocol FirebaseAuthDelegate:class {
    func auth(_ user: AuthDataResult?, type: FirebaseAuthType, isSuccess:Bool)
}

// TODO: Firebase Firestore

@objc protocol FirebaseDatabaseDelegate:class {
    @objc optional func databaseUpdate(_ isSuccess:Bool)
    @objc optional func databaseDocument(_ snapshot:DocumentSnapshot?, isSuccess:Bool, type:FirebaseDatabaseType)
    @objc optional func databaseDocRef(ref:DocumentReference?, isSuccess:Bool, type:FirebaseDatabaseType)
     @objc optional func deleteDocument(_ isSuccess:Bool, type:FirebaseDatabaseType)
    @objc optional func query(_ document:[QueryDocumentSnapshot], isSuccess:Bool, type:FirebaseDatabaseType)
    @objc optional func queryWith(_ query:Query?, isSuccess:Bool, type:FirebaseDatabaseType)
   
}


// TODO: Firebase Storage

@objc protocol FirebaseStorageDelegate:class {
    @objc optional func media(_ url:String?, isSuccess:Bool, type:FirebaseStorageType)
   

}

// Firebase manager class
class FirebaseManager:NSObject{
    
    var db : Firestore!
    lazy var storage = Storage.storage()
    
    weak var authDelegate:FirebaseAuthDelegate?
    weak var databaseDelegate:FirebaseDatabaseDelegate?
    weak var storageDelegate:FirebaseStorageDelegate?
    // Init the firebase manager
    init(_ authDelegate:FirebaseAuthDelegate?, databaseDelegate: FirebaseDatabaseDelegate?, storageDelegate:FirebaseStorageDelegate?){
        self.authDelegate = authDelegate
        self.databaseDelegate = databaseDelegate
        self.storageDelegate = storageDelegate
        super.init()
        // add instance firestore
        db = Firestore.firestore()
    }
    
    //MARK: Auth Methods
    
    // user sign in
    func signIn(_ withEmail: String?, password: String?){
        guard let email = withEmail  else {return}
        guard let password = password  else {return}
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            
            if let error = error {
                if let errCode = AuthErrorCode(rawValue: error._code) {
                    switch errCode {
                    case .userNotFound:
                        self.showAlert(title: "Email Not Found", message: "Please check your email!")
                    case .invalidEmail:
                        self.showAlert(title: "Invalid Email", message: "Please check your email format!")
                    case .wrongPassword:
                        self.showAlert(title: "Wrong Password", message: "Please check your password!")
                    case .networkError:
                        self.showAlert(title: "Netword Error", message: "No network connection!")
                    default:
                        print("unknown error")
                        print(error)
                    }
                }
                self.authDelegate?.auth(nil, type: .signIn, isSuccess: false)
                return
            } else {
                self.authDelegate?.auth(user, type: .signIn, isSuccess: true)
            }
            
        })
    }
    
    // user sign up
    func signUp(_ withEmail: String?, password: String?){
        guard let email = withEmail  else {return}
        guard let password = password  else {return}
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
        
            if let error = error {
                // self.loginRegisterButton.isUserInteractionEnabled = true
                if let errCode = AuthErrorCode(rawValue: error._code) {
                    switch errCode {
                    case .invalidEmail:
                        self.showAlert(title: "Invalid Email", message: "Please check your email format!")
                    case .emailAlreadyInUse:
                        self.showAlert(title: "Email Already Registered", message: "Please use another email!")
                    case .weakPassword:
                        self.showAlert(title: "Weak Password", message: "Your password is too weak!")
                    case .networkError:
                        self.showAlert(title: "Netword Error", message: "No network connection!")
                    default:
                        self.showAlert(title: "Netword Error", message: "Unknown error")
                        print("unknown error")
                        print(error)
                    }
                }
                 self.authDelegate?.auth(nil, type: .signUp, isSuccess: false)
                return
            }else{
                self.authDelegate?.auth(user, type: .signUp, isSuccess: true)
            }
            
        })
    }
    // forgot password
    
    func forgotPassword(_ withEmail:String?){
        guard let email = withEmail  else {return}
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            
            if let error = error {
                if let errCode = AuthErrorCode(rawValue: error._code) {
                    switch errCode {
                    case .invalidEmail:
                        self.showAlert(title: "Invalid Email", message: "Please check your email format!")
                    case .networkError:
                        self.showAlert(title: "Netword Error", message: "No network connection!")
                    case .userNotFound:
                        self.showAlert(title: "No User Found", message: "No user record found!")
                    default:
                        print("unknown error")
                        print(error)
                    }
                }
                self.authDelegate?.auth(nil, type: .forgotPassword, isSuccess: false)
                return
            }else{
                self.authDelegate?.auth(nil, type: .forgotPassword, isSuccess: true)
            }
           
        }
    }
    
    //TODO: sign out
    
    func signOut(){
        do {
            try Auth.auth().signOut()
          
            let login = AccountViewController()
            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = login
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
             self.authDelegate?.auth(nil, type: .signOut, isSuccess: false)
        }
    }
    
    //MARK: Firestore Storage Methods
    
    func uploadImage(_ imageData:Data, type:FirebaseStorageType){
        let imagePath = "/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        
        let storageRef =
            storage.reference(withPath: imagePath)
                 storageRef.putData(imageData, metadata: metadata) { (metadata, error) in
                     if let error = error {
                         print("Error uploading: \(error)")
                         return
                     }
                     print("no error")
                     // Get download url from firestore storage
                     storageRef.downloadURL { (url, error) in
                        if let _ = error{
                            self.storageDelegate?.media?(nil, isSuccess: false, type: type)
                        }else{
                            self.storageDelegate?.media?(url?.absoluteString, isSuccess: true, type: type)
                        }
                    }}
    }
    
    
    
    //MARK: Firestore Database Methods
    // set document data
    func setDatabase(dict:[String:Any], collectionName:String, documentName:String){
        db.collection(collectionName).document(documentName).setData(dict) { (error) in
            if let err = error {
                print("Error writing document: \(err)")
                self.databaseDelegate?.databaseUpdate?(false)
                
            } else {
                print("Document successfully written!")
                self.databaseDelegate?.databaseUpdate?(true)
            }
        }
    }
    
    // update document data
    func updateData(dict:[String:Any], collectionName:String, documentName:String){
        self.db.collection(collectionName).document(documentName).updateData(dict) { (error) in
            if let err = error {
                print("Error writing document: \(err)")
                self.databaseDelegate?.databaseUpdate?(false)
                
            } else {
                print("Document successfully written!")
                self.databaseDelegate?.databaseUpdate?(true)
            }
        }
    }
    
    // update document
    func updateDocument(dict:[String:Any], collectionName:String, type:FirebaseDatabaseType){
         var ref: DocumentReference? = nil
        ref =  db.collection(collectionName).addDocument(data: dict) { (error) in
            if let err = error {
                print("Error writing document: \(err)")
                self.databaseDelegate?.databaseDocRef?(ref: nil, isSuccess: false, type: type)
                
            } else {
                print("Document successfully written!")
                self.databaseDelegate?.databaseDocRef?(ref: ref, isSuccess: true, type: type)
            }
        }
     }
    
    // get single document
    func getSingleDocument(_ collectionName:String, documentName:String, type: FirebaseDatabaseType){
        db.collection(collectionName).document(documentName).getDocument { (snapshot, error) in
            if error != nil{
                self.databaseDelegate?.databaseDocument?(nil, isSuccess: false, type: type)
            }else{
                self.databaseDelegate?.databaseDocument?(snapshot, isSuccess: true, type: type)
                
            }
        }
    }
    
    // get all documents
    func getDocuments(_ collectionName:String, documentName:String, type: FirebaseDatabaseType){
        db.collection(collectionName).document(documentName).addSnapshotListener { (snapshot, error) in
            if error != nil{
                self.databaseDelegate?.databaseDocument?(nil, isSuccess: false, type: type)
            }else{
                self.databaseDelegate?.databaseDocument?(snapshot, isSuccess: true, type: type)
                
            }
        }
    }
    
    
    // get collection with limit
    func getCollection(_ collectionName:String, hasLimit:Bool = false, limit:Int = 0, type:FirebaseDatabaseType){
        
        
        db.collection(collectionName).limit(to: limit).getDocuments { (querySnapshot, error) in
            if let error = error{
               print("get collection error \(error)")
                self.databaseDelegate?.query?([], isSuccess: false, type: type)
            }else{
                if let document = querySnapshot?.documents{
                self.databaseDelegate?.query?(document, isSuccess: true, type: type)
                }
            }
        }
    }
    
    // query
    func query(_ collectionName:String, fieldName:String, isEqualTo:Any, hasLimit:Bool = false, limit:Int = 0, type:FirebaseDatabaseType){
        var query : Query?
        if hasLimit{
            query = db.collection(collectionName).whereField(fieldName, isEqualTo: isEqualTo).limit(to: limit)
        }else{
            query = db.collection(collectionName).whereField(fieldName, isEqualTo: isEqualTo)
        }
        self.databaseDelegate?.queryWith?(query, isSuccess: true, type: type)
        
        
        
        
    }
    
    // already have query
    
    func queryWith(_ query:Query, fieldName:String,isEqualTo:Any, type:FirebaseDatabaseType ){
        query.whereField(fieldName, isEqualTo: isEqualTo)
        query.getDocuments(completion: { (querySnapshot, error) in
             guard error == nil,
                           let documents = querySnapshot?.documents else {
                            self.databaseDelegate?.query?([], isSuccess: false, type: type)
                           return
                }
            self.databaseDelegate?.query?(documents, isSuccess: true, type: type)
            
        })
    }
    
    // delete document data
    func deleteDocument(_ collectionName:String, documentName:String, type:FirebaseDatabaseType){
        db.collection(collectionName).document(documentName).delete { (error) in
            if let err = error {
                print("Error removing document: \(err)")
                self.databaseDelegate?.deleteDocument?(false, type: type)
            } else {
                print("Document successfully removed!")
                 self.databaseDelegate?.deleteDocument?(true, type: type)
            }
        }
    }
    
    //MARK: Alert
    
    //show normal message
    func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction((UIAlertAction(title: "OK", style: .default, handler: {(action) -> Void in
        })))
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        var topController: UIViewController = appDelegate.window!.rootViewController!
        while (topController.presentedViewController != nil) {
            topController = topController.presentedViewController!
        }
        DispatchQueue.main.async {
               topController.present(alert, animated: true, completion: nil)
        }
     
    }
    
    
}

