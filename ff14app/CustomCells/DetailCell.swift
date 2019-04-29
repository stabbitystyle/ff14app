//
//  DetailCell.swift
//  ff14app
//
//  Created by mannyadmin on 4/28/19.
//  Copyright © 2019 Stabbity Style Industries. All rights reserved.
//

import Foundation
import UIKit

class DetailCell: UITableViewCell {
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
