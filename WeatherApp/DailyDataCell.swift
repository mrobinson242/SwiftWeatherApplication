//
//  DailyDataCell.swift
//  WeatherApp
//
//  Created by Matthew Robinson on 11/17/19.
//  Copyright © 2019 Matthew Robinson. All rights reserved.
//

import UIKit

class DailyDataCell: UITableViewCell
{
    // MARK: Properties
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var sunriseTime: UILabel!
    @IBOutlet weak var sunsetTime: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
