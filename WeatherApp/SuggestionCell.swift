//
//  SuggestionCell.swift
//  WeatherApp
//
//  Created by Matthew Robinson on 11/15/19.
//  Copyright © 2019 Matthew Robinson. All rights reserved.
//

import UIKit

class SuggestionCell: UITableViewCell
{
    // MARK: Properties
    @IBOutlet weak var locationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
