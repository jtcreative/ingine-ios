//
//  DocumentSnapshotPublisher.swift
//  ingine
//
//  Created by Manish Dadwal on 14/09/20.
//  Copyright © 2020 ingine. All rights reserved.
//

import Foundation
import Combine
import Firebase
//extension DocumentReference{
//    struct DocumentSnapshotPublisher: Combine.Publisher {
//
//        typealias Output = DocumentSnapshot
//        typealias Failure = Error
//        private let documentReference: DocumentReference
//        private let includeMetadataChanges: Bool
//        init(_ documentReference: DocumentReference,includeMetadataChanges: Bool) {
//            self.documentReference = documentReference
//             self.includeMetadataChanges = includeMetadataChanges
//        }
//        func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
//            let subscription = DocumentSnapshot.Subscription(subscriber: subscriber, documentReference: documentReference, includeMetadataChanges: includeMetadataChanges)
//            subscriber.receive(subscription: subscription)
//        }
//
//    }
//
//    public func publisher(includeMetadataChanges : Bool = true) -> AnyPublisher<DocumentSnapshot, Error> {
//           DocumentSnapshotPublisher(self, includeMetadataChanges: true)
//           .eraseToAnyPublisher()
//       }
//
//       public func publisher<D: Decodable>(includeMetadataChanges: Bool = true, as type: D.Type, documentSnapshotMapper: @escaping (DocumentSnapshot) throws -> D?) -> AnyPublisher<D?, Error> {
//           publisher(includeMetadataChanges: includeMetadataChanges)
//               .map {
//                   do {
//                       return try documentSnapshotMapper($0)
//                   } catch {
//                       print("Document snapshot mapper error for \(self.path): \(error)")
//                       return nil
//                   }
//               }
//               .eraseToAnyPublisher()
//       }
//
//}
//
//extension DocumentSnapshot {
//    fileprivate final class Subscription<SubscriberType: Subscriber>: Combine.Subscription where SubscriberType.Input == DocumentSnapshot, SubscriberType.Failure == Error {
//        private var registration: ListenerRegistration?
//
//        init(subscriber: SubscriberType, documentReference: DocumentReference, includeMetadataChanges: Bool) {
//            registration = documentReference.addSnapshotListener (includeMetadataChanges: includeMetadataChanges) { (snapshot, error) in
//                if let error = error {
//                    subscriber.receive(completion: .failure(error))
//                } else if let snapshot = snapshot {
//                    _ = subscriber.receive(snapshot)
//                } else {
//                    subscriber.receive(completion: .failure(error!))
//                }
//            }
//        }
//
//        func request(_ demand: Subscribers.Demand) {
//            // We do nothing here as we only want to send events when they occur.
//            // See, for more info: https://developer.apple.com/documentation/combine/subscribers/demand
//        }
//
//        func cancel() {
//            registration?.remove()
//            registration = nil
//        }
//    }
//
//
//
//}
extension Publishers{
    
    
    
    
    struct SnapshotPublisher:Combine.Publisher {
        
        
        typealias Output = DocumentSnapshot
        
        typealias Failure = Error
        
        private let documentReference: DocumentReference
        private let includeMetadataChanges: Bool
        init(_ documentReference: DocumentReference,includeMetadataChanges: Bool) {
            self.documentReference = documentReference
            self.includeMetadataChanges = includeMetadataChanges
        }
        
        func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
            let subscriptionSnapshot = SubscriptionSnapshot(subscriber: subscriber, snapshot: documentReference)
            subscriber.receive(subscription: subscriptionSnapshot)
            
        }
    }
    
    
     class SubscriptionSnapshot<SubscriberType: Subscriber>: Combine.Subscription where SubscriberType.Input == DocumentSnapshot, SubscriberType.Failure == Error {
               private var registration: ListenerRegistration?

               init(subscriber: SubscriberType, snapshot: DocumentReference) {
                registration = snapshot.addSnapshotListener(includeMetadataChanges: true, listener: { (snapshot, error) in
                    if let error = error {
                        subscriber.receive(completion: .failure(error))
                    } else if let snapshot = snapshot {
                        _ = subscriber.receive(snapshot)
                    } else {
                        subscriber.receive(completion: .failure(error!))
                    }
                })
               }

               func request(_ demand: Subscribers.Demand) {
                   // We do nothing here as we only want to send events when they occur.
                   // See, for more info: https://developer.apple.com/documentation/combine/subscribers/demand
               }

               func cancel() {
                   registration?.remove()
                   registration = nil
               }
           }
    
    
    
    
    
    
    
     struct QueryPublisher: Combine.Publisher {
            
            typealias Output = QuerySnapshot
            typealias Failure = Error
        private var query :Query
        init(_ query:Query){
            self.query = query
        }
        
            func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
                let subscription = Subscription(subscriber: subscriber, query: query)
                subscriber.receive(subscription: subscription)
            }
            
        }



    class Subscription<SubscriberType: Subscriber>: Combine.Subscription where SubscriberType.Input == QuerySnapshot, SubscriberType.Failure == Error {
            private var registration: ListenerRegistration?

            init(subscriber: SubscriberType, query: Query) {
                registration = query.addSnapshotListener { (snapshot, error) in
                    if let error = error {
                        subscriber.receive(completion: .failure(error))
                    } else if let snapshot = snapshot {
                        _ = subscriber.receive(snapshot)
                    } else {
                        subscriber.receive(completion: .failure(error!))
                    }
                }
            }

            func request(_ demand: Subscribers.Demand) {
                // We do nothing here as we only want to send events when they occur.
                // See, for more info: https://developer.apple.com/documentation/combine/subscribers/demand
            }

            func cancel() {
                registration?.remove()
                registration = nil
            }
        }
        
        
       

}
 
