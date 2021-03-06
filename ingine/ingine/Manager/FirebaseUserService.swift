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
class FirebaseUserService: IUserService {
    
    
    static var shared = FirebaseUserService()
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
    
    
    
    func searchUser(_ query: String, collection: String, limit: Int) -> AnyPublisher<[QueryDocumentSnapshot], Error> {
        Future<[QueryDocumentSnapshot], Error>{ promise in
            Firestore.firestore().collection(collection).limit(to: limit).order(by: "fullName").start(at: [query]).end(at: ["\(query)uf8ff"]).getDocuments { (querySnapshot, error) in
                if let error = error{
                    print("get collection error \(error)")
                    promise(.failure(error))
                }else{
                    if let document = querySnapshot?.documents {
                        promise(.success(document))
                    }
                }
            }
            
        }.eraseToAnyPublisher()
        
    }
    
    func searchFollowers(_ query: String, collection: String, limit: Int)-> AnyPublisher<[User], Error> {
           // Populate cell elements with data from firebase
        let id = Auth.auth().currentUser?.email ?? ""
        return Future<[User], Error>{ promise in
            FirebaseARService.shared.getUser("users", document: id).sink(receiveCompletion: { (completion) in
                switch completion
                {
                case .finished : print("finish")
                case .failure(let error):
                    print(error.localizedDescription)
                    promise(.failure(error))
                }
            }) { (snapShot) in
                 guard snapShot.data() != nil else {
                    print("Document data was empty.")
                    promise(.failure(NSError(domain: "404", code: 404, userInfo: [:])))
                    return
                }
                              
                
                if snapShot.exists {
                    User().dictToUser(dict: snapShot.data()!, id: snapShot.documentID, {
                        user in
                        if query.isEmpty{
                            promise(.success(user.followers))
                            return
                        }
                        let filterA = user.followers.filter({$0.fullName.lowercased().contains(query.lowercased())})
                        
                        promise(.success(filterA))
                        
                    })
                  
                    
                }else{
                    promise(.failure(NSError(domain: "500", code: 500, userInfo: [:])))
                }
                
               
            }.store(in: &FirebaseARService.shared.cancelBag)
            
        }.eraseToAnyPublisher()
    }
    
    func searchFollowings(_ query: String, collection: String, limit: Int) -> AnyPublisher<[User], Error> {
        let id = Auth.auth().currentUser?.email ?? ""
        return Future<[User], Error>{ promise in
            FirebaseARService.shared.getUser("users", document: id).sink(receiveCompletion: { (completion) in
                switch completion
                {
                case .finished : print("finish")
                case .failure(let error):
                    print(error.localizedDescription)
                    promise(.failure(error))
                }
            }) { (snapShot) in
                 guard snapShot.data() != nil else {
                    print("Document data was empty.")
                    promise(.failure(NSError(domain: "404", code: 404, userInfo: [:])))
                    return
                }
                              
                
                if snapShot.exists {
                    
                    User().dictToUser(dict: snapShot.data()!, id: snapShot.documentID, {
                        user in
                        if query.isEmpty{
                            promise(.success(user.followings))
                            return
                        }
                        let filterA = user.followings.filter({$0.fullName.lowercased().contains(query.lowercased())})
                        
                        promise(.success(filterA))
                        
                
                    })
                    
                  

                }else{
                    promise(.failure(NSError(domain: "500", code: 500, userInfo: [:])))
                }
                
              
            }.store(in: &FirebaseARService.shared.cancelBag)
            
        }.eraseToAnyPublisher()
    }
    
}

 
