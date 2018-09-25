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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        icon.image = nil
    }

}
