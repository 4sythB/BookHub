//
//  BookController.swift
//  BookHub
//
//  Created by Diego Aguirre on 8/10/16.
//  Copyright © 2016 home. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

public let BookControllerDidRefreshNotification = "BookControllerDidRefreshNotification"
public let BookCommentsChangedNotification = "PostCommentsChangedNotification"

class BookController {
    
    static let sharedController = BookController()
    private let cloudKitManager = CloudKitManager()
    
    init() {
        refresh(Book.recordType)
        refresh(Comment.recordTypeKey)
    }
    
    private(set) var books: [Book] = [] {
        
        didSet {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let nc = NSNotificationCenter.defaultCenter()
                nc.postNotificationName(BookControllerDidRefreshNotification, object: self)
            })
        }
    }
    
//    private(set) var comments: [Comment] = [] {
//        didSet {
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                <#code#>
//            })
//        }
//    }
    
    var sortedBooks: [Book] {
        return books.sort { return $0.timeStamp.compare($1.timeStamp) == .OrderedAscending }
    }
    
    var comments: [Comment] {
        return books.flatMap { $0.comments }
    }
    
   
    
    func postNewBook(rating: String, image: UIImage, date: NSDate, completion: ((Book) -> Void)?) {
       guard let data = UIImageJPEGRepresentation(image, 0.8) else { return }
        
        let book = Book(rating: rating, timestamp: NSDate(), photoData: data)
        books.append(book)
        // add book comment
        
        cloudKitManager.saveRecord(CKRecord(book)) { (record, error) in
            guard let record = record else {
                if let error = error {
                    print("Error saving new book to CloudKit \(error.localizedDescription)")
                    return
                }
                completion?(book)
                return
            }
            book.cloudKitRecordID = record.recordID
        }
       
    }
    
    func addCommentToBook(text: String, book: Book, completion: ((Comment) -> Void)? = nil) -> Comment {
        
        let comment = Comment(book: book, text: text)
        book.comments.append(comment)
        
        cloudKitManager.saveRecord(CKRecord(comment)) { (record, error) in
            if let error = error {
                print("Error saving new comment to CloudKit: \(error.localizedDescription)")
                return
            }
            comment.cloudKitRecordID = record?.recordID
            completion?(comment)
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let nc = NSNotificationCenter.defaultCenter()
            nc.postNotificationName(BookCommentsChangedNotification, object: book)
        })
        
        return comment
    }
    
    private func recordsOfType(type: String) -> [CloudKitSyncable] {
        switch type {
        case "Book":
            return books.flatMap { $0 as CloudKitSyncable }
        case "Comment":
            return comments.flatMap { $0 as CloudKitSyncable }
        default:
            return []
        }
    }
    
    func refresh(type: String, completion: (() -> Void)? = nil) {
        
       let predicate = NSPredicate(value: true)
        
        cloudKitManager.fetchRecordsWithType(type, predicate: predicate, recordFetchedBlock: { (record) in
            
            switch type {
            case Book.recordType:
                if let book = Book(record: record) {
                    self.books.append(book)
                }
            case Comment.recordTypeKey:
                guard let bookReference = record[Comment.bookKey] as? CKReference,
                    bookIndex = self.books.indexOf({ $0.cloudKitRecordID == bookReference.recordID }),
                    comment = Comment(record: record) else { return }
                let book = self.books[bookIndex]
                book.comments.append(comment)
                comment.book = book
            default:
                return
            }
            }) { (records, error) in
                
                if let error = error {
                    print("Error fetching CloudKit records of type \(type): \(error.localizedFailureReason)")
                }
                completion?()
        }
    }
}