//
//  PhotoInfoViewController.swift
//  PhotObama
//
//  Created by Lindsay Pond on 4/18/17.
//  Copyright © 2017 Lindsay Pond. All rights reserved.
//

import UIKit

@available(iOS 10.0, *)
class PhotoInfoViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    
    var photo: Photo! {
        didSet {
            navigationItem.title = photo.title
        }
    }
    
    var store: PhotoStore!
    
    var method: Method!
    override func viewDidLoad() {
        super.viewDidLoad()
        store.fetchImage(for: photo, withMethod: method) { result in
            switch result {
            case let .success(image):
                self.imageView.image = image
            case let .failure(error):
                print("Error fetching image for photo: \(error)")
            }
        }
    }
}
