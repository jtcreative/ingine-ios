//
//  ViewControllerExtension.swift
//  ingine
//
//  Created by Manish Dadwal on 02/09/20.
//  Copyright © 2020 ingine. All rights reserved.
//

import UIKit


//  MARK: Notificaton Binding Protocol
extension ViewController:NotificatoinBindingDelegate{
    func recieve<T>(_ value: T) {
        if let imageStatus = value as? ImageLoadingStatus{
      
            self.statusViewController.showMessage("\(imageStatus.message)\n\(Double((Double(imageStatus.startIndex)/Double(imageStatus.endIndex))*100).rounded(toPlaces: 0))% Complete", autoHide: false)
        }
        if let msg = value as? String{
            self.statusViewController.showMessage(msg, autoHide: true)
        }
    }
}

extension ViewController{
    func renderArAssets(docId: String){
        FirebaseARService.shared.query("pairs", fieldName: "user", isEqualTo: docId)
            .sink(receiveCompletion: { (completion) in
                switch completion
                {
                case .finished : print("finish")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }) { (document) in
                var arAssets = [ARImageAsset]()
                arAssets = document.filter { $0.public ?? false}.map({ (doc) ->  ARImageAsset  in
                    return ARImageAsset(name: doc.matchURL ?? "", imageUrl: doc.refImage ??  "")
                })
                
                
                print("arCount************",self.arCount, docId)
                ARImageDownloadService.main.downloadAssets(imageAssets: arAssets)
                self.isReloading = false
                //We currently no longer run this notification
                //Leaving it here is we want it in the future, but doesn't work well with
                //Loading all of the user followers as well
                //NotificationCenter.default.post(Notification.progressUpdateNotification(message: "Updating notification", fromStartingIndex: 0, toEndingIndex: arAssets.count))
                
                let imgMod = ImageLoadingStatus(message: "Updating notification", startIndex: 0, endIndex: arAssets.count)
                
                NotificationCenter.default.post(name: .progressUpdate, object: imgMod)
        }.store(in: &FirebaseARService.shared.cancelBag)
    }
    
    func getArAssetsFromFollowings() {
        FirebaseUserService.shared.searchFollowings("", collection: "users", limit: 60)
            .sink(receiveCompletion: { (completion) in
                switch completion
                {
                case .finished : print("finish")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }) { [weak self] (snapshot) in
                guard let strongSelf = self else { return }
                for doc in snapshot {
                    strongSelf.renderArAssets(docId: doc.id)
                }
        }.store(in: &FirebaseUserService.shared.cancelBag)
    }
}
