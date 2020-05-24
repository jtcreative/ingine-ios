//
//  ImageLoadingService.swift
//  ingine
//
//  Created by James Timberlake on 5/23/20.
//  Copyright © 2020 ingine. All rights reserved.
//

import Foundation
import EasyStash

class ImageLoadingService {
    
    static private var loadingService:ImageLoadingService?
    
    static var main: ImageLoadingService {
        if loadingService == nil {
            loadingService = ImageLoadingService(folder: "CachedImages")
            loadingService!.storageInstance.cache.countLimit = 50
            loadingService!.storageInstance.cache.evictsObjectsWithDiscardedContent = true
            try? loadingService!.storageInstance.removeAll()
        }
        
        return loadingService!
    }
    
    private let storageInstance: Storage
    
    init(folder:String) {
        var options = Options()
        options.folder = folder
        
        storageInstance = try! Storage(options: options)
    }
    
    private func normalizeKey(url:String) -> String {
        let firstString = String(url.split(separator: "?")[0])
        guard let index = firstString.lastIndex(of: "/")else {
                return url
        }
        
        let newIndex = firstString.index(after:index)
        return String(firstString[newIndex...])
    }
    
    func add(imageData:Data, forKey key:String) {
        do {
            
            try storageInstance.save(object: imageData, forKey: normalizeKey(url:key))
        } catch {
            print("error saving image data: \(error)")
        }
        storageInstance.cache.removeAllObjects()
    }
    
    func get(forKey key:String) -> Data? {
        let imageData : Data?
        
        do {
            imageData = try storageInstance.load(forKey: normalizeKey(url:key))
        } catch {
            print("error retrieving image data: \(error)")
            imageData = nil
        }
        
        return imageData
    }
    
    func exists(forKey key:String) -> Bool {
        return storageInstance.exists(forKey: normalizeKey(url:key))
    }
    
    func remove(forKey key:String) {
       try? storageInstance.remove(forKey: normalizeKey(url:key))
    }
    
    func clearAll() {
        try? storageInstance.removeAll()
    }
}
