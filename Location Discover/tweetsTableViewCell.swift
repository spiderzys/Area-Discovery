//
//  tweetsTableViewCell.swift
//  Location Discover
//
//  Created by YANGSHENG ZOU on 2016-06-20.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

import UIKit

class tweetsTableViewCell: UITableViewCell {

    @IBOutlet weak var favouriteNumLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
