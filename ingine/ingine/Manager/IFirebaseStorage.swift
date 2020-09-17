//
//  IFirebaseStorage.swift
//  ingine
//
//  Created by Manish Dadwal on 14/09/20.
//  Copyright © 2020 ingine. All rights reserved.
//

import Foundation
import Combine
import Firebase

class IFirebaseStorage:IArUploadService{
    
        typealias T = String
       var cancelBag = Set<AnyCancellable>()
       static var shared = IFirebaseStorage()
    
    func uploadImage(_ imageData: Data) -> AnyPublisher<String, Error> {
        Future<String, Error>{ promise in
            
            let imagePath = "/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            
            let storageRef =
                Storage.storage().reference(withPath: imagePath)
                     storageRef.putData(imageData, metadata: metadata) { (metadata, error) in
                         if let error = error {
                             print("Error uploading: \(error)")
                             return
                         }
                         print("no error")
                         // Get download url from firestore storage
                         storageRef.downloadURL { (url, error) in
                            if let error = error{
                              //  self.storageDelegate?.media?(nil, isSuccess: false, type: type)
                                promise(.failure(error))
                            }else{
                                promise(.success(url?.absoluteString ?? ""))
//                                s//elf.storageDelegate?.media?(url?.absoluteString, isSuccess: true, type: type)
                            }
                        }}

        }.eraseToAnyPublisher()
    }
    
   
    
    
    
    
}
