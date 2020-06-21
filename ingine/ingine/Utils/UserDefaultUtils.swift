//
//  UserDefaultUtils.swift
//  ingine
//
//  Created by James Timberlake on 6/21/20.
//  Copyright © 2020 ingine. All rights reserved.
//

import Foundation

enum UserDefaultSetting : String {
    case DidViewTutorialPage
}

extension UserDefaults {
    
    static func setSetting(setting:UserDefaultSetting, asValue value:Any) {
        UserDefaults.standard.set(value, forKey: setting.rawValue)
    }
    
    static func getValue(forSetting setting:UserDefaultSetting) -> Any? {
        UserDefaults.standard.object(forKey: setting.rawValue)
    }
    
}
