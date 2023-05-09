//
//  GlassesCollecitonViewCell.swift
//  ARFaceTrackDemo
//
//  Created by Mayank Mangukiya on 27/03/23.
//  Copyright © 2023 Blue Mango Global. All rights reserved.
//

import UIKit

class GlassesCollecitonViewCell: UICollectionViewCell {
     
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var glassesImageView: UIImageView!
    
    private let cornerRadius: CGFloat = 10
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backView.layer.cornerRadius = cornerRadius
    }
    
    func setup(with imageName: String){
        glassesImageView.image = UIImage(named: imageName)
    }
    
}
