//
//  Book.swift
//  BookHub
//
//  Created by Diego Aguirre on 8/10/16.
//  Copyright © 2016 home. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class Book: CloudKitSyncable {
    
    static let recordType = "Book"
    static let ratingKey = "Rating"
    static let photoDataKey = "ImageData"
    static let dateKey = "Date" 
    
    var rating: String
    let timeStamp: NSDate
    var photoData: NSData?
    var photo: UIImage? {
        guard let photoData = photoData else { return nil }
        return UIImage(data: photoData)
    }
    var comments: [Comment]
    
    var cloudKitRecordID: CKRecordID?
    var recordType: String { return Book.recordType }
    
    init(rating: String, timestamp: NSDate = NSDate(), photoData: NSData?, comments: [Comment] = []) {
        self.rating = rating
        self.timeStamp = timestamp
        self.photoData = photoData
        self.comments = comments
    }
    
    convenience required init?(record: CKRecord) {
        
        guard let rating = record[Book.ratingKey] as? String,
            timestamp = record.creationDate,
            photoAsset = record[Book.photoDataKey] as? CKAsset else {
                print("Failable initializer Failed.")
                return nil
        }
        
        let photoData = NSData(contentsOfURL: photoAsset.fileURL)
        self.init(rating: rating, timestamp: timestamp, photoData: photoData)
        cloudKitRecordID = record.recordID
    }
    
    private var temporaryPhotoURL: NSURL {
        
        // Must write to temporary directory to be able to pass image file path url to CKAsset
        
        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryDirectoryURL = NSURL(fileURLWithPath: temporaryDirectory)
        let fileURL = temporaryDirectoryURL.URLByAppendingPathComponent(NSUUID().UUIDString).URLByAppendingPathExtension("jpg")
        
        photoData?.writeToURL(fileURL, atomically: true)
        
        return fileURL
    }
}

extension CKRecord {
    convenience init(_ book: Book) {
        let recordID = CKRecordID(recordName: NSUUID().UUIDString)
        self.init(recordType: book.recordType, recordID: recordID)
        
        self[Book.dateKey] = book.timeStamp
        self[Book.ratingKey] = book.rating
        self[Book.photoDataKey] = CKAsset(fileURL: book.temporaryPhotoURL)
    }
}