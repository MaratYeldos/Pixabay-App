//
//  CustomCollectionCell.swift
//  AlabsProject
//
//  Created by Yeldos Marat on 20.01.2022.
//

import UIKit

class CustomCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var playView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        playView.isHidden = true
        playView.layer.cornerRadius = playView.frame.size.width/2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        img.image = nil
        label.text = nil
    }

}
