//
//  tweetsTableViewCell.swift
//  Location Discover
//
//  Created by YANGSHENG ZOU on 2016-06-20.
//  Copyright © 2016 YANGSHENG ZOU. All rights reserved.
//

import UIKit

class TweetsTableViewCell: UITableViewCell {

    @IBOutlet weak var favouriteNumLabel: UILabel!  // show the number of favorites of this tweets
    @IBOutlet weak var userImageView: UIImageView!  // show the poster photo
    @IBOutlet weak var usernameLabel: UILabel!      // show the poster name
    @IBOutlet weak var tweetLabel: UILabel!         // show the content of the tweets
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
