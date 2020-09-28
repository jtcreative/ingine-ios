//
//  IFirebase.swift
//  ingine
//
//  Created by Manish Dadwal on 11/09/20.
//  Copyright © 2020 ingine. All rights reserved.
//

import Foundation
import FirebaseAuth
import Combine
import FirebaseFirestore
class IFirebase: IUserService{
    
    
    static var shared = IFirebase()
    var cancelBag = Set<AnyCancellable>()
    typealias T = AuthDataResult
    typealias Q = [QueryDocumentSnapshot]
    
    func signIn(_ email: String, password: String) -> AnyPublisher<AuthDataResult, Error> {
        Future<AuthDataResult, Error> { promise in
            Auth.auth().signIn(withEmail: email, password: password) { auth, error in
                if let error = error {
                    promise(.failure(error))
                } else if let auth = auth {
                    promise(.success(auth))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    
    
    func signUp(_ email: String, password: String) -> AnyPublisher<AuthDataResult, Error> {
        Future<AuthDataResult, Error>{ promise in
            Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                
                if let error = error {
                    promise(.failure(error))
                }else{
                    promise(.success(user!))
                }
                
            })
            
        }.eraseToAnyPublisher()
    }
    
    func signOut() -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            do{
                try  Auth.auth().signOut()
                promise(.success(()))
            }catch (let err){
                promise(.failure(err))
            }
            
        }.eraseToAnyPublisher()
    }
    
    func forget(_ email: String) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    
    func getUserList(_ collection:String, limit:Int) -> AnyPublisher<[QueryDocumentSnapshot], Error> {
        Future<[QueryDocumentSnapshot], Error>{ promise in
            Firestore.firestore().collection(collection).limit(to: limit).getDocuments { (querySnapshot, error) in
                if let error = error{
                    print("get collection error \(error)")
                    promise(.failure(error))
                }else{
                    if let document = querySnapshot?.documents{
                        promise(.success(document))
                    }
                }
            }}.eraseToAnyPublisher()
    }
    
    
    
}

 
