//
//  PhotoAPIs.swift
//  PhotObama
//
//  Created by Lindsay Pond on 3/28/17.
//  Copyright © 2017 Lindsay Pond. All rights reserved.
//

import Foundation
import CoreData

enum Method: String {
    case interestingPhotos = "flickr.interestingness.getList"
    case recentPhotos = "flickr.photos.getRecent"
}

enum FlickrError: Error {
    case invalidJSONData
}

struct FlickrAPI {
    private enum Constants {
        static let baseURLString = "https://api.flickr.com/services/rest"
        static let apiKey = "a6d819499131071f158fd740860a5a88"
        static let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return formatter
        }()
    }
   
    
    static func flickrURL(method: Method, parameters: [String:String]?) -> URL {
        var components = URLComponents(string: Constants.baseURLString)!
        
        var queryItems = [URLQueryItem]()
        
        let baseParams = [
            "method": method.rawValue,
            "format": "json",
            "nojsoncallback": "1",
            "api_key": Constants.apiKey
        ]
        
        baseParams.forEach { (key, value) in
            let item = URLQueryItem(name: key, value: value)
            queryItems.append(item)
            
        }
        
        if let additionalParams = parameters {
            additionalParams.forEach { (key, value) in
                let item = URLQueryItem(name: key, value: value)
                queryItems.append(item)
                
            }
        }
        components.queryItems = queryItems
        return components.url!
    }
    
    static var interestingPhotosURL: URL {
        return flickrURL(method: .interestingPhotos, parameters: ["extras": "url_h,date_taken"])
    }
    
    static var recentPhotosURL: URL {
        return flickrURL(method: .recentPhotos, parameters: ["extras": "url_h,date_taken"])
    }
    
    static func photos(fromJSON data: Data, from method: Method, into context:NSManagedObjectContext) -> PhotoResult {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard let jsonDictionary = jsonObject as? [AnyHashable: Any], let photos = jsonDictionary["photos"] as? [String: Any], let photosArray = photos["photo"] as? [[String: Any]] else {
                return .failure(FlickrError.invalidJSONData)
            }
            var finalPhotos = [Photo]()
            photosArray.forEach { photoJSON in
                if let photo = photo(fromJSON: photoJSON, from: method, into: context) {
                    finalPhotos.append(photo)
                }
            }
            if finalPhotos.isEmpty && !photosArray.isEmpty {
                return .failure(FlickrError.invalidJSONData)
            }
            return .success(finalPhotos)
        } catch let error {
            return .failure(error)
        }
    }

    
    private static func photo(fromJSON json: [String: Any], from method: Method, into context: NSManagedObjectContext) -> Photo? {
        guard let photoID = json["id"] as? String, let title = json["title"] as? String, let dateString = json["datetaken"] as? String, let photoURLString = json["url_h"] as? String, let url = URL(string: photoURLString), let dateTaken = Constants.dateFormatter.date(from: dateString) else {
            return nil
        }
        let fetchRequest : NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "\(#keyPath(Photo.photoID)) == \(photoID)")
        var fetchedPhotos: [Photo]?
        context.performAndWait {
            if #available(iOS 10.0, *) {
                fetchedPhotos = try? fetchRequest.execute()
            } else {
                // Fallback on earlier versions
            }
        }
        if let existingPhoto = fetchedPhotos?.first {
            return existingPhoto
        }
        var photo: Photo!
        context.performAndWait {
            if #available(iOS 10.0, *) {
                photo = Photo(context: context)
            } else {
                // Fallback on earlier versions
            }
            photo.title = title
            photo.photoID = photoID
            photo.remoteURL = url as NSURL
            photo.dateTaken = dateTaken as NSDate
            photo.method = method.rawValue
        }
        return photo
    }
}

struct InstagramAPI {
    
}

