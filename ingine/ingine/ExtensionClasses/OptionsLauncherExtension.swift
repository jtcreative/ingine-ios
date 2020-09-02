//
//  OptionsLauncherExtension.swift
//  ingine
//
//  Created by Manish Dadwal on 01/09/20.
//  Copyright © 2020 ingine. All rights reserved.
//

import Foundation
import Firebase


extension OptionsLauncher:FirebaseDatabaseDelegate{
    
    func deleteDocument(_ isSuccess: Bool, type: FirebaseDatabaseType) {
        switch type {
        case .deleteDoc:
             if isSuccess{
                       self.handleDismiss()
                   }
        default:
            break
        }
    }
    
    func databaseUpdate(_ isSuccess: Bool) {
        if isSuccess{
            self.handleDismiss()
        }
    }
}
