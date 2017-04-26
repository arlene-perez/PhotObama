//
//  PhotosViewController.swift
//  PhotObama
//
//  Created by Lindsay Pond on 3/28/17.
//  Copyright © 2017 Lindsay Pond. All rights reserved.
//

import UIKit

@available(iOS 10.0, *)
class PhotosViewController: UIViewController {


    @IBOutlet weak var photoCollectionView: UICollectionView!
    var store: PhotoStore!
    let photoDataSource = PhotoDataSource()
    var selectedPhotos = Method.interestingPhotos {
        didSet {
            updateSelectedPhotos()
        }
    }
    
    @IBAction func updateSelectedPhotos(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            selectedPhotos = .interestingPhotos
        } else {
            selectedPhotos = .recentPhotos
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateSelectedPhotos()
        photoCollectionView.dataSource = photoDataSource
        photoCollectionView.delegate = self
        updateDataSource()
        store.fetchPhotos(from: selectedPhotos) { photoResult in
            self.updateDataSource()
        }
    }
    
    private func updateDataSource() {
        store.fetchAllPhotos(forMethod: selectedPhotos) { photoResult in
            switch photoResult {
            case let .success(photos):
                self.photoDataSource.photos = photos
            case .failure:
                self.photoDataSource.photos.removeAll()
            }
        }
    }

    func updateSelectedPhotos() {
        photoDataSource.photos.removeAll()
        store.fetchPhotos(from: selectedPhotos) {photoResult in
            switch photoResult {
            case let .success(photos):
                self.photoDataSource.photos = photos
                self.photoCollectionView.reloadData()
            case let .failure(error):
                print("Error fetching interesting photos: \(error)")
            }
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation

    */
    // MARK: CollectionViewDelegate Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showPhoto"?:
            if let selectedIndexPath = photoCollectionView.indexPathsForSelectedItems?.first {
                let photo = photoDataSource.photos[selectedIndexPath.item]
                if let destinationVC = segue.destination as? PhotoInfoViewController {
                    destinationVC.photo = photo
                    destinationVC.store = store
                    destinationVC.method = self.selectedPhotos
                }
            }
        default:
            preconditionFailure("Unknown segue attempted: \(segue.identifier ?? "")")
        }
    }
   }

@available(iOS 10.0, *)
extension PhotosViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let photo = photoDataSource.photos[indexPath.row]
        store.fetchImage(for: photo, withMethod: selectedPhotos) { photoResult in
            guard let photoIndex = self.photoDataSource.photos.index(where: {$0 === photo}), case let .success(image) = photoResult else {
                return
            }
            let photoIndexPath = IndexPath(item: photoIndex, section: 0)
            
            if let cell = self.photoCollectionView.cellForItem (at: photoIndexPath) as? PhotoCollectionViewCell {
                cell.update(with: image)
            }
        }
    }

}
