//
//  PhotoCollectionViewCell.swift
//  PhotObama
//
//  Created by Lindsay Pond on 4/10/17.
//  Copyright © 2017 Lindsay Pond. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    
    func update(with image: UIImage?) {
        if let image = image {
            loadingIndicator.stopAnimating()
            imageView.image = image
        } else {
            loadingIndicator.startAnimating()
            imageView.image = nil
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        update(with: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        update(with: nil)
    }
}
