//
//  IFirebaseDatabase.swift
//  ingine
//
//  Created by Manish Dadwal on 14/09/20.
//  Copyright © 2020 ingine. All rights reserved.
//

import Foundation
import Combine
import FirebaseFirestore


class FirebaseARService: IARService{
    
    static var shared = FirebaseARService()
    typealias Q = QuerySnapshot
    var db = Firestore.firestore()
    var cancelBag = Set<AnyCancellable>()
    typealias A = DocumentSnapshot
    typealias D  = DocumentReference
    
    func setData(_ collection: String, document: String, data:[String:Any]) -> AnyPublisher<Void, Error> {
        Future<Void, Error>{ promise in
            Firestore.firestore().collection(collection).document(document).setData(data, completion: { (error) in
                if let error = error{
                    promise(.failure(error))
                }else{
                    promise(.success(()))
                }
            })
            
        }.eraseToAnyPublisher()
    }
    
    
    
    func getAssetList(_ collection: String, document: String) -> AnyPublisher<ARItem, Error> {
        
        let ref = Firestore.firestore().collection(collection).document(document)
        return Publishers.SnapshotPublisher(ref, includeMetadataChanges: true)
            .flatMap { snapshot -> AnyPublisher<ARItem, Error> in
                do{
                    
                    guard let item = try snapshot.data(as:ARItem.self) else{
                        return Fail(error: NSError(domain: "Failed", code: 23, userInfo: nil)).eraseToAnyPublisher()
                    }
                    
                    return Just(item).setFailureType(to: Error.self).eraseToAnyPublisher()
                }catch{
                    return Fail(error: NSError(domain: "Failed", code: 23, userInfo: nil)).eraseToAnyPublisher()
                }
            }.eraseToAnyPublisher()
        
    }
    
    func getUser(_ collection:String, document:String) -> AnyPublisher<DocumentSnapshot, Error> {
        Future<DocumentSnapshot, Error> { promise in
            Firestore.firestore().collection(collection).document(document).getDocument { (snapshot, error) in
                guard let user = snapshot else {
                    promise(.failure(NSError(domain: "400", code: 400, userInfo: [:])))
                    return
                }
                
                promise(.success(user))
            }
            
        }.eraseToAnyPublisher()
    }
    
    func updateData(_ collection: String, document: String, data: [String : Any]) -> AnyPublisher<Void, Error> {
        Future<Void, Error>{ promise in
            Firestore.firestore().collection(collection).document(document).updateData(data) { (error) in
                if let err = error {
                    print("Error writing document: \(err)")
                    promise(.failure(err))
                    
                } else {
                    print("Document successfully written!")
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func deleteDocument(_ collection: String, document: String) -> AnyPublisher<Void, Error> {
        Future<Void, Error>{ promise in
            
            Firestore.firestore().collection(collection).document(document).delete { (error) in
                if let err = error {
                    print("Error removing document: \(err)")
                    promise(.failure(err))
                } else {
                    print("Document successfully removed!")
                    promise(.success(()))
                }
            }
            
        }.eraseToAnyPublisher()
    }
    
    // Add Document
    func addDocument(_ collection: String, data: [String : Any]) -> AnyPublisher<DocumentReference, Error> {
        Future<DocumentReference, Error>{ promise in
            var ref: DocumentReference? = nil
            ref =  Firestore.firestore().collection(collection).addDocument(data: data) { (error) in
                if let err = error {
                    print("Error writing document: \(err)")
                    promise(.failure(err))
                    
                } else {
                    print("Document successfully written!")
                    promise(.success(ref!))
                    
                }
            }
            
        }.eraseToAnyPublisher()
    }
    
    
    func query(_ collection: String, fieldName: String, isEqualTo: Any) -> AnyPublisher<[ARImageAssetTest], Error> {
        Future<[ARImageAssetTest], Error>{ promise in
            Firestore.firestore().collection(collection).whereField(fieldName, isEqualTo: isEqualTo).whereField("public", isEqualTo: true).limit(to: 10000).addSnapshotListener { (queryShort, error)  in
                if let error = error{
                    promise(.failure(error))
                }else{
                    if  let snapshot = queryShort {
                        let items = snapshot.documents.compactMap {
                            return try? $0.data(as: ARImageAssetTest.self)
                        }
                        promise(.success(items))
                    }
                    
                }
            }
            
        }.eraseToAnyPublisher()
    }
    
    func getDocument(_ collection: String, document: String) -> AnyPublisher<DocumentSnapshot, Error> {
        Future<DocumentSnapshot, Error>{ promise in
            Firestore.firestore().collection(collection).document(document).getDocument { (snapshot, error) in
                if let error = error{
                    promise(.failure(error))
                }else{
                    
                    promise(.success(snapshot!))
                }
            }
            
        }.eraseToAnyPublisher()
    }
}
