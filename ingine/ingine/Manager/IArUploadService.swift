//
//  IArUploadService.swift
//  ingine
//
//  Created by Manish Dadwal on 14/09/20.
//  Copyright © 2020 ingine. All rights reserved.
//

import Foundation
import Combine
protocol IArUploadService{
    associatedtype T
    func uploadImage(_ imageData:Data) -> AnyPublisher<T, Error>
}
