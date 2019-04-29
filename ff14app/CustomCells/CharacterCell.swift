//
//  CharacterCell.swift
//  ff14app
//
//  Created by mannyadmin on 4/8/19.
//  Copyright © 2019 Stabbity Style Industries. All rights reserved.
//

import Foundation
import UIKit

class CharacterCell: UITableViewCell {
    @IBOutlet weak var characterName: UILabel!
    @IBOutlet weak var characterServer: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
