//
//  NotificationTypes.swift
//  ingine
//
//  Created by James Timberlake on 4/23/20.
//  Copyright © 2020 ingine. All rights reserved.
//
import NotificationCenter

public enum NotificatioType : String {
    case ProgressUpdateNofication
    case ProgressCompleteNotification
    case UserProfileSelectedNotification
}

public enum NotificationProgressUserInfoType : String {
    case StartingIndex
    case EndingIndex
    case Message
    case UserDocumentId
}

extension Notification {
    
    static func progressUpdateNotification(message:String, fromStartingIndex startIndex:Int, toEndingIndex endIndex:Int) -> Notification {
        return Notification(name: Notification.Name.init(rawValue: NotificatioType.ProgressUpdateNofication.rawValue), object: nil, userInfo: [NotificationProgressUserInfoType.StartingIndex.rawValue : startIndex,
            NotificationProgressUserInfoType.EndingIndex.rawValue : endIndex,
            NotificationProgressUserInfoType.Message.rawValue : message])
    }
    
    static func progressEndNotification(message:String) -> Notification {
        return Notification(name: Notification.Name.init(rawValue: NotificatioType.ProgressCompleteNotification.rawValue), object: nil, userInfo: [NotificationProgressUserInfoType.Message.rawValue : message])
    }
    
    static func selectedUserProfileNotification(userId:String) -> Notification {
        return Notification(name: Notification.Name.init(rawValue: NotificatioType.UserProfileSelectedNotification.rawValue), object: nil, userInfo: [NotificationProgressUserInfoType.UserDocumentId.rawValue : userId])
    }
}
