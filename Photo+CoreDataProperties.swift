//
//  Photo+CoreDataProperties.swift
//  PhotObama
//
//  Created by Lindsay Pond on 4/24/17.
//  Copyright © 2017 Lindsay Pond. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }

    @NSManaged public var dateTaken: NSDate?
    @NSManaged public var photoID: String?
    @NSManaged public var remoteURL: NSObject?
    @NSManaged public var title: String?
    @NSManaged public var method: String?
    @NSManaged public var views: Int16

}
