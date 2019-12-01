//
//  WeeklyTableViewCell.swift
//  WeatherApplication
//
//  Created by Matthew Robinson on 11/15/19.
//  Copyright © 2019 Matthew Robinson. All rights reserved.
//

import UIKit

class WeeklyTableViewCell: UITableViewCell {

    // MARK: Properties
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var sunriseTime: UILabel!
    @IBOutlet weak var sunsetTime: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
