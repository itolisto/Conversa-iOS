//
//  FavoriteCollectionCell.swift
//  Conversa
//
//  Created by Edgar Gomez on 11/30/17.
//  Copyright © 2017 Conversa. All rights reserved.
//

import UIKit

class FavoriteCollectionCell : UICollectionViewCell {

    var favorite : Favorite!
    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var lblBusinessName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.autoresizingMask.insert(.flexibleHeight)
        self.contentView.autoresizingMask.insert(.flexibleWidth)
        self.ivAvatar.layer.cornerRadius = self.ivAvatar.frame.size.width / 2
        self.ivAvatar.layer.masksToBounds = true
        self.ivAvatar.layer.borderWidth = 1
        self.ivAvatar.layer.borderColor = UIColor.gray.cgColor
    }

    func configureCellWith(_ favorite: Favorite) -> Void {
        self.favorite = favorite;

        if (!favorite.avatarUrl.isEmpty) {
            self.ivAvatar.sd_setImage(with: NSURL(string: favorite.avatarUrl) as URL?, placeholderImage: UIImage(named: "ic_business_default"))
        }

        self.lblBusinessName.text = favorite.name
    }

}
