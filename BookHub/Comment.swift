//
//  Comment.swift
//  BookHub
//
//  Created by Diego Aguirre on 8/11/16.
//  Copyright © 2016 home. All rights reserved.
//

import Foundation
import CloudKit

class Comment: CloudKitSyncable {
    
    static let recordTypeKey = "Comment"
    static let textKey = "Text"
    static let bookKey = "Book"
    static let dateKey = "Date"
    
    let timeStamp: NSDate
    let text: String
    var book: Book?
    
    init(book: Book?, text: String, timestamp: NSDate = NSDate()) {
        self.book = book
        self.text = text
        self.timeStamp = timestamp
    }
    
    convenience required init?(record: CKRecord) {
        guard let timeStamp = record.creationDate,
            let text = record[Comment.textKey] as? String else { return nil }
        
        self.init(book: nil, text: text, timestamp: timeStamp)
        cloudKitRecordID = record.recordID
    }
    
    var cloudKitRecordID: CKRecordID?
    var recordType: String { return Comment.recordTypeKey }
}

extension CKRecord {
    convenience init(_ comment: Comment) {
        guard let book = comment.book else { fatalError("Comment does not have a Book relationship") }
        let bookRecordID = book.cloudKitRecordID ?? CKRecord(book).recordID
        let recordID = CKRecordID(recordName: NSUUID().UUIDString)
        self.init(recordType: comment.recordType, recordID: recordID)
        
        self[Comment.dateKey] = comment.timeStamp
        self[Comment.textKey] = comment.text
        self[Comment.bookKey] = CKReference(recordID: bookRecordID, action: .DeleteSelf)
    }
}