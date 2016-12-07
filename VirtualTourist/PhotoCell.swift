//
//  PhotoCell.swift
//  VirtualTourist
//
//  Created by Joel on 12/1/16.
//  Copyright © 2016 Joel Pratt. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    @IBOutlet var cellImageView: UIImageView!
    @IBOutlet var indicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // indicator.hidesWhenStopped = true
        indicator.startAnimating()
        cellImageView.image = nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        indicator.startAnimating()
    }
}
