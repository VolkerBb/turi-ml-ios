//
//  DetectedObjectTableViewCell.swift
//  TuriML
//
//  Created by Volker Bublitz on 25.09.18.
//  Copyright © 2018 vobu. All rights reserved.
//

import UIKit

class DetectedObjectTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var icon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
