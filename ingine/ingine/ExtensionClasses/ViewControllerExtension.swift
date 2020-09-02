//
//  ViewControllerExtension.swift
//  ingine
//
//  Created by Manish Dadwal on 02/09/20.
//  Copyright © 2020 ingine. All rights reserved.
//

import UIKit
import Firebase

extension ViewController:FirebaseDatabaseDelegate{
    
    func queryWith(_ query: Query?, isSuccess: Bool, type: FirebaseDatabaseType) {
        if type == .query{

            firebaseManager?.queryWith(query!, fieldName: "public", isEqualTo: true, type: .snapshotQuery)
        }
    }
    func query(_ document: [QueryDocumentSnapshot], isSuccess: Bool, type: FirebaseDatabaseType) {
        switch type {
        case .snapshotQuery:
            var arAssets = [ARImageAsset]()
                       
                       arAssets = document.filter { (doc) -> Bool in
                           (doc.get("public") as? Bool) == true
                       }.filter { (doc) -> Bool in
                           ((doc.get("matchURL") as? String) != nil &&
                               (doc.get("refImage") as? String) != nil)
                       }.map({ (doc) -> ARImageAsset in
                           let name = (doc.get("matchURL") as! String)
                           let url = (doc.get("refImage") as! String)
                           return ARImageAsset(name: name, imageUrl: url)
                       })
                       
                       ARImageDownloadService.main.beginDownloadOperation(imageAssets: arAssets, delegate: self)
                       self.isReloading = false
                       NotificationCenter.default.post(Notification.progressUpdateNotification(message: "Updating notification", fromStartingIndex: 0, toEndingIndex: arAssets.count))
     
            
           
        default:
            break
        }
    }
}
