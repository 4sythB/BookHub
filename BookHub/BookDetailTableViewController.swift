//
//  BookDetailTableViewController.swift
//  BookHub
//
//  Created by Diego Aguirre on 8/9/16.
//  Copyright © 2016 home. All rights reserved.
//

import UIKit

class BookDetailTableViewController: UITableViewController {

    @IBOutlet weak var ratingButtonItem: UIBarButtonItem!
    @IBOutlet weak var bookCoverImageView: UIImageView!
    
    var book: Book?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let book = book {
            bookCoverImageView.image = book.photo
            ratingButtonItem.title = book.rating
        }
        
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: #selector(commentsWereUpdated), name: BookCommentsChangedNotification, object: nil)
    }
    
    // MARK: Update TableView
    func commentsWereUpdated() {
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BookController.sharedController.comments.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("commentCell", forIndexPath: indexPath)
        
        let comment = BookController.sharedController.comments[indexPath.row]
        
        cell.textLabel?.text = comment.text
        
        return cell
    }
    
    // MARK: Actions
    
    @IBAction func commentButtonPressed(sender: AnyObject) {
        alertView()
    }
    
    @IBAction func shareButtonPressed(sender: AnyObject) {
        guard let image = bookCoverImageView.image,
                  rating = ratingButtonItem.title else { return }
        
        let activityController = UIActivityViewController(activityItems: [image, rating], applicationActivities: nil)
        
        presentViewController(activityController, animated: true, completion: nil)
        
        
    }
    
    // MARK: ALERT
    
    func alertView() {
        
        var commentTextField: UITextField!
        
        guard let book = book else { return }
        
        let alertController = UIAlertController(title: "What did you think of this book?", message: nil, preferredStyle: .Alert)
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Enter a comment"
            commentTextField = textField
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .Default) { (_) in
            
            guard let text = commentTextField.text where text.characters.count > 0 else { return }
            
            BookController.sharedController.addCommentToBook(text, book: book)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
}







































