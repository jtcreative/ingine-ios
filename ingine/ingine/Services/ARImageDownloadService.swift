//
//  ARImageDownloadService.swift
//  ingine
//
//  Created by James Timberlake on 5/10/20.
//  Copyright © 2020 ingine. All rights reserved.
//

import Foundation
import ARKit

enum ARImageDownloadStatus {
    case Success
    case Error
}

struct ARImageAsset: Equatable {
    let name:String
    let imageUrl:String
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return (lhs.name == rhs.name && lhs.imageUrl == rhs.imageUrl)
    }
}

class ARImageDownloadService {
    
    static private var downloadService:ARImageDownloadService?
    
    static var main : ARImageDownloadService {
        if downloadService == nil  {
            downloadService = ARImageDownloadService()
            downloadService?.downloadOperation.maxConcurrentOperationCount = 50
        }
        return downloadService!
    }
    
    var serviceDelegate:ARImageDownloadServiceDelegate?
    var downloadOperation = OperationQueue()
    var count:Int = 0
    var total:Int = 0
    
    func beginDownloadOperation(imageAssets:[ARImageAsset], delegate:ARImageDownloadServiceDelegate?)  {
        stopDownloadOperation()
        
        count = 0
        total = imageAssets.count
        serviceDelegate = delegate
        
        let completionOperation = BlockOperation {
            self.serviceDelegate?.onOperationCompleted(status: .Success)
            self.stopDownloadOperation()
        }
        
        for (asset) in imageAssets {
            let operation = BlockOperation(block: { [weak self] in
                self?.downloadImage(asset: asset)
            })
            completionOperation.addDependency(operation)
            downloadOperation.addOperation(operation)
        }
        
        downloadOperation.addOperation(completionOperation)
    }
    
    func stopDownloadOperation() {
        downloadOperation.cancelAllOperations()
        serviceDelegate = nil
    }
    
    func downloadImage(asset:ARImageAsset) {
        let myCount = count
        count = count + 1
        
        guard ImageLoadingService.main.exists(forKey: asset.imageUrl) == false,
            let imageUrl = URL(string: asset.imageUrl),
            let imageData:NSData = NSData(contentsOf: imageUrl) else {
                serviceDelegate?.onImageDownloaded(status: .Error, asset: nil, index: myCount, total: total)
                return
        }
            
        ImageLoadingService.main.add(imageData: imageData as Data, forKey: asset.imageUrl)
        serviceDelegate?.onImageDownloaded(status: .Success, asset:asset, index: myCount, total: self.total)
    }
}

protocol ARImageDownloadServiceDelegate {
    func onImageDownloaded(status:ARImageDownloadStatus, asset:ARImageAsset?, index:Int, total:Int)
    func onOperationCompleted(status:ARImageDownloadStatus)
}
