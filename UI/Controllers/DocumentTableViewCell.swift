//
//  DocumentCellTableViewCell.swift
//  efbware
//
//  Created by Pouriya Zarbafian on 29/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//

import UIKit

class DocumentTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var labelCell: UILabel!
    @IBOutlet weak var iconCell: UIImageView!
    
}
