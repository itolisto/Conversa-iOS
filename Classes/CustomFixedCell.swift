//
//  CustomFixedCell.swift
//  Conversa
//
//  Created by Edgar Gomez on 1/10/18.
//  Copyright © 2018 Conversa. All rights reserved.
//

import UIKit

class CustomFixedCell : UITableViewCell {

    @IBOutlet weak var mlTitle : UILabel!
    @IBOutlet weak var mlDescription : UILabel!
    @objc public var business : YapContact!

    @objc public func configureCellWith(title : String, description : String, business : YapContact) {
        self.business = business
        if title.count > 0 {
            self.mlTitle.text = title
        }
        if description.count > 0 {
            self.mlDescription.text = description
        }
    }

}
