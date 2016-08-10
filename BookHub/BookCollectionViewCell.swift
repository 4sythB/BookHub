//
//  BookCollectionViewCell.swift
//  BookHub
//
//  Created by Diego Aguirre on 8/9/16.
//  Copyright © 2016 home. All rights reserved.
//

import UIKit

class BookCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var bookRatingLabel: UILabel!
    
    func updateItemWithBook(book: Book) {
        self.bookImageView.image = book.photo
        self.bookRatingLabel.text = book.rating
    }
    
}
