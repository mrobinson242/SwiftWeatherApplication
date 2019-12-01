//
//  DailyWeatherData.swift
//  WeatherApplication
//
//  Created by Matthew Robinson on 11/15/19.
//  Copyright © 2019 Matthew Robinson. All rights reserved.
//

import UIKit

class DailyWeatherData
{
    // MARK: Properties
    var date: String
    var weatherIcon: UIImage?
    var sunrise: String
    var sunset: String
    
    // MARK: Initialization
    init?(date: String, weatherIcon: UIImage?, sunrise: String, sunset: String)
    {
        // The name must not be empty
        guard !date.isEmpty else {
            return nil
        }
        
        // Initialize stored properties.
        self.date = date
        self.weatherIcon = weatherIcon
        self.sunrise = sunrise
        self.sunset = sunset
    }
}
