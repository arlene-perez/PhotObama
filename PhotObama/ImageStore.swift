
//  ImageStore.swift
//  Homepwner
//
//  Created by Angela Park on 2/24/16.
//  Copyright © 2016 Angela Park. All rights reserved.
//

import UIKit

class ImageStore {
    let cache = [Method:NSCache<AnyObject, AnyObject>]()
    var selectedMethod = Method.interestingPhotos
    
    func imageURLForKey(key: String) -> NSURL {
        let documentsDirectories = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = documentsDirectories.first!
        return documentDirectory.appendingPathComponent(key) as NSURL
    }
    
    func setImage(image: UIImage, forKey key: String, withMethod: Method) {
        // Set it in our cache
        let selectedCache = cache[withMethod] ?? NSCache<AnyObject, AnyObject>()
        selectedCache.setObject(image, forKey: key as AnyObject)
        
        let imageURL = imageURLForKey(key: key)
        
        // Write it to disk
        //var data = UIImageJPEGRepresentation(image, 0.5)
        let data = UIImagePNGRepresentation(image)
        if let data = data {
            do {
                try data.write(to: imageURL as URL)
            }
            catch {
                print("Error setting image")
            }
        }
    }
    
    func imageForKey(key: String) -> UIImage? {
        let selectedCache = cache[selectedMethod]
        // Is it in our cache, if so return the cached image
        if let existingImage = selectedCache?.object(forKey: key as AnyObject) as? UIImage {
            return existingImage
        }
        
        // See if its on the disk
        let imageURL = imageURLForKey(key: key)
        guard let imageFromDisk = UIImage(contentsOfFile: imageURL.path!) else {
            return nil
        }
        selectedCache?.setObject(imageFromDisk, forKey: key as AnyObject)
        return imageFromDisk
    }
    
    func deletImageForKey(key: String) {
        let selectedCache = cache[selectedMethod]
        selectedCache?.removeObject(forKey: key as AnyObject)
        let imageURL = imageURLForKey(key: key)
        do {
            try FileManager.default.removeItem(at: imageURL as URL)
        }
        catch {
            print("Error removing the image from disk: \(error)")
        }
    }
    
    
}
