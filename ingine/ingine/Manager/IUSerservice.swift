//
//  IUSerservice.swift
//  ingine
//
//  Created by Manish Dadwal on 11/09/20.
//  Copyright © 2020 ingine. All rights reserved.
//1.3

import Foundation
import Combine

protocol IUserService {
    // Auth
    associatedtype T
    associatedtype Q
    func signIn(_ email:String, password:String) -> AnyPublisher<T, Error>
    func signUp(_ email:String, password:String) -> AnyPublisher<T, Error>
    func signOut() -> AnyPublisher<Void, Error>
    func forget(_ email:String) -> AnyPublisher<Void, Error>
    func getUserList(_ collection:String, limit:Int) -> AnyPublisher<Q, Error>
    
}




