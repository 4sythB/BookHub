//
//  BookListViewController.swift
//  BookHub
//
//  Created by Diego Aguirre on 8/9/16.
//  Copyright © 2016 home. All rights reserved.
//

import UIKit

class BookListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: #selector(booksWereUpdated), name: BookControllerDidRefreshNotification, object: nil)
    }
    
    func booksWereUpdated() {
        self.collectionView.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return BookController.sharedController.books.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let item = collectionView.dequeueReusableCellWithReuseIdentifier("bookItem", forIndexPath: indexPath) as? BookCollectionViewCell else { return BookCollectionViewCell() }
        
        let book = BookController.sharedController.books[indexPath.item]
        
        item.updateItemWithBook(book)
        
        return item
    }
        
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toBookDetail" {
            
            guard let bookDetailVC = segue.destinationViewController as? BookDetailTableViewController,
                indexPath = collectionView.indexPathsForSelectedItems()?.first else { return }
            
            let book = BookController.sharedController.books[indexPath.item]
            
            bookDetailVC.book = book
        }
    }
}
