//
//  String+Extension.swift
//  ingine
//
//  Created by Manish Dadwal on 18/09/20.
//  Copyright © 2020 ingine. All rights reserved.
//

import UIKit
extension String{
    
    func toArributedString(alignment:NSTextAlignment) -> NSAttributedString{
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        return toAttributed(attributes: [.paragraphStyle:paragraphStyle])
    }
    
    
    func toAttributed(attributes:[NSAttributedString.Key:Any]? = nil) -> NSAttributedString{
        return NSAttributedString(string: self, attributes: attributes)
    }
}
