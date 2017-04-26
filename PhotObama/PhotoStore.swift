//
//  PhotoStore.swift
//  PhotObama
//
//  Created by Lindsay Pond on 3/28/17.
//  Copyright © 2017 Lindsay Pond. All rights reserved.
//

import UIKit
import CoreData

enum ImageResult {
    case success(UIImage)
    case failure(Error)
}

enum PhotoError: Error {
    case imageCreationError
}

enum PhotoResult {
    case success([Photo])
    case failure(Error)
}

@available(iOS 10.0, *)
class PhotoStore {
    
    let imageStore = ImageStore()
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PhotObama")
        container.loadPersistentStores(completionHandler: {(description, error) in
            if let error = error {
                print("Error setting up core data: \(error)")
            }
        })
        return container
    }()
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    func fetchPhotos(from method: Method, completion: @escaping (PhotoResult) -> Void) {
        
        let apiEndPoint: URL?
        switch method {
        case .interestingPhotos:
            apiEndPoint = FlickrAPI.interestingPhotosURL
        case .recentPhotos:
            apiEndPoint = FlickrAPI.recentPhotosURL
        }
        guard let url = apiEndPoint else { return }
        let interestingPhotoRequest = URLRequest(url: url)
        let task = session.dataTask(with: interestingPhotoRequest, completionHandler: { (data, response, error) in
            var result = self.processPhotosRequest(data: data, method: method, error: error)
            
            if case .success = result {
                do {
                    try self.persistentContainer.viewContext.save()
                } catch let error {
                    result = .failure(error)
                }
            }
            OperationQueue.main.addOperation {
                completion(result)
            }
            if let response = response as? HTTPURLResponse {
                print("Status Code: \(response.statusCode)")
                response.allHeaderFields.forEach { (key, value) in
                    print("\(key as! String): \(value as! String)")
                    }
            }
        })
        task.resume()
        
    }
    
    private func processPhotosRequest(data: Data?, method: Method, error: Error?) -> PhotoResult {
        guard let jsonData = data else {
            return .failure(error!)
        }
        
        return FlickrAPI.photos(fromJSON: jsonData, from: method, into:  persistentContainer.viewContext)
    }
    
    func fetchImage(for photo: Photo, withMethod: Method, completion: @escaping (ImageResult) -> Void ) {
        guard let photoKey = photo.photoID else {
            preconditionFailure("Photo expected to have photoID.")
        }
        if let image = imageStore.imageForKey(key: photoKey) {
            OperationQueue.main.addOperation {
                completion(.success(image))
            }
        }
        guard let photoURL = photo.remoteURL as? URL else {
            preconditionFailure("Photo expected to have a remote URL")
        }
        let request = URLRequest(url: photoURL)
        
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            let result = self.processImageRequest(data: data, error: error)
            if case let .success(image) = result {
                self.imageStore.setImage(image: image, forKey: photoKey, withMethod: withMethod)
            }
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }
    
    func fetchAllPhotos(forMethod method: Method, completion: @escaping (PhotoResult) -> Void) {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortByDateTaken = NSSortDescriptor(key: #keyPath(Photo.dateTaken), ascending: true)
        fetchRequest.sortDescriptors = [sortByDateTaken]
        let predicateByMethod = NSPredicate(format: "\(#keyPath(Photo.method)) == '\(method.rawValue)'")
        fetchRequest.predicate = predicateByMethod
        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            do {
                let allPhotos = try viewContext.fetch(fetchRequest)
                completion(.success(allPhotos))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private func processImageRequest(data: Data?, error: Error?) -> ImageResult {
        guard let imageData = data, let image = UIImage(data: imageData) else {
            if data == nil {
                return .failure(error!)
            } else {
                return .failure(PhotoError.imageCreationError)
            }
        }
        return .success(image)
    }
}
