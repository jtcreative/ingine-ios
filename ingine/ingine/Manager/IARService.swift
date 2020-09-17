//
//  IARService.swift
//  ingine
//
//  Created by Manish Dadwal on 13/09/20.
//  Copyright © 2020 ingine. All rights reserved.
//

import Foundation
import Combine
protocol IARService {
    associatedtype A
    associatedtype D
    associatedtype Q
    func getUser(_ collection:String, document:String)-> AnyPublisher<A, Error>
    func getAssetList(_ collection:String, document:String)-> AnyPublisher<TestItem, Error>
    func setData(_ collection:String, document:String,data:[String:Any]) -> AnyPublisher<Void, Error>
    func updateData(_ collection:String, document:String,data:[String:Any]) -> AnyPublisher<Void, Error>
    func deleteDocument(_ collection:String, document:String) -> AnyPublisher<Void, Error>
    func addDocument(_ collection:String,data:[String:Any]) -> AnyPublisher<D, Error>
    func query(_ collection:String, fieldName:String, isEqualTo:Any) -> AnyPublisher<[ARImageAssetTest], Error>
    func test (_ collection:String, document:String) -> AnyPublisher<[TestItem], Error>
    func getDocument(_ collection:String, document:String) -> AnyPublisher<A, Error>

    
}
