//
//  CacheImage.swift
//  SearchPhoto
//
//  Created by Andrey Alhimchenkov on 11/3/19.
//  Copyright © 2019 Andrey Alhimchenkov. All rights reserved.
//

import Foundation
import UIKit

class CacheImage: NSObject {
    static var shared: CacheImage {
        let instance = CacheImage();
        return instance;
    };
    
    private override init() {}
    
    func getCacheDirectoryPath() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
    }
    
    func createDirectory(pathDirectory:String) -> Bool {
        if !FileManager.default.fileExists(atPath: pathDirectory){
            try! FileManager.default.createDirectory(atPath: pathDirectory,
                                                     withIntermediateDirectories: true,
                                                     attributes: nil);
        }
        return true;
    }
    
    func isImageSave(url:String) -> Bool {
        let nameImage = String(format: "%@.jpg", url.sha1!);
        let cachePathFile = String(format: "%@/Cache/%@", self.getCacheDirectoryPath(), nameImage);
        return FileManager.default.fileExists(atPath: cachePathFile);
    }
    
    
    func imageFromCache(path:String) -> UIImage {
        
        let nameImage = String(format: "%@.jpg", path.sha1! );
        let cachePathDir = String(format: "%@/Cache", self.getCacheDirectoryPath() );
        let cachePathFile = String(format: "%@/Cache/%@", self.getCacheDirectoryPath(), nameImage);
        
        if (self.createDirectory(pathDirectory: cachePathDir)){
            if !FileManager.default.fileExists(atPath: cachePathFile){
                let imageData = UIImage(data:try! Data(contentsOf: URL(fileURLWithPath: path)))?.pngData();
                try! imageData!.write(to: URL(fileURLWithPath: cachePathFile), options: .atomic);
            }
        }
        return UIImage(contentsOfFile:cachePathFile)!;
    }
    
    
    func imageToCacheData(path:String, imageData:NSData) {
        
        let nameImage = String(format: "%@.jpg", path.sha1! );
        let cachePathDir = String(format: "%@/Cache", self.getCacheDirectoryPath() );
        let cachePathFile = String(format: "%@/Cache/%@", self.getCacheDirectoryPath(), nameImage);
        
        if (self.createDirectory(pathDirectory: cachePathDir)){
            if !FileManager.default.fileExists(atPath: cachePathFile){
                try! imageData.write(to: URL(fileURLWithPath: cachePathFile), options: .atomic);
            }
        }
    }
}

// Singleton don't must clone
extension CacheImage: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        return self
    }
}
