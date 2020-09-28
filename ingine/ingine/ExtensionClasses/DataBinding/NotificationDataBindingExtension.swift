//
//  NotificationDataBindingExtension.swift
//  ingine
//
//  Created by Manish Dadwal on 07/09/20.
//  Copyright © 2020 ingine. All rights reserved.
//

import Foundation
import Combine


struct ImageLoadingStatus {
    var message:String
    var startIndex:Int
    var endIndex:Int
}


extension Notification.Name {
    static let progressUpdate = Notification.Name(NotificatioType.ProgressUpdateNofication.rawValue)
    static let progressEnd = Notification.Name(NotificatioType.ProgressCompleteNotification.rawValue)
    static let sendArData = Notification.Name(NotificatioType.SendARDataNotification.rawValue)
}


protocol NotificatoinBindingDelegate:class {
    func recieve<T>(_ value:T)
}


class NotificatonBinding:NSObject{
        var cancellable: AnyCancellable?
    
    static let shared = NotificatonBinding()
    
    weak var delegate: NotificatoinBindingDelegate?
    
    
    func registerPublisher<T>(name: Notification.Name, type: T.Type){
        cancellable = NotificationCenter.default.publisher(for: name).sink(receiveValue: { (notification) in
           if let obj = notification.object as? T{
            self.delegate?.recieve(obj)
            }
        })
    }
    
    
}
