//
//  TodayTabController.swift
//  WeatherApp
//
//  Created by Matthew Robinson on 11/16/19.
//  Copyright © 2019 Matthew Robinson. All rights reserved.
//

import UIKit
import Foundation

class TodayTabController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource
{
    struct WeatherDataModel
    {
        let propertyImage: UIImage?
        let propertyValue: String
        let propertyName: String
    }

    // Today Properties
    var windSpeed = 0.0
    var pressure = 0.0
    var precipitation = 0.0
    var temperature = 0.0
    var summary = ""
    var humidity = 0.0
    var visibility = 0.0
    var cloudCover = 0.0
    var ozone = 0.0
    var iconName = ""
    var wIcon : UIImage!

    // Daily Data Array
    var detailData = [WeatherDataModel]()
    
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: Initialization
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Set Collection View Connectors
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;

        // Load Data
        getWeatherIcon()
        populateData()
    }
    
    //
    // populateData
    //
    func populateData()
    {
        // Wind Speed Data
        let windSpeedIcon = UIImage(named: "weather-windy")!
        let windSpeedData = WeatherDataModel(propertyImage: windSpeedIcon, propertyValue: "\(self.windSpeed) mph", propertyName: "Wind Speed")
        
        // Pressure Data
        let pressureIcon = UIImage(named: "gauge")!
        let pressureData = WeatherDataModel(propertyImage: pressureIcon, propertyValue: "\(self.pressure) mb", propertyName: "Pressure")
        
        // Precipitation
        let precipIcon = UIImage(named: "weather-pouring")!
        let precipData = WeatherDataModel(propertyImage: precipIcon, propertyValue: "\(self.precipitation) mmph", propertyName: "Precipitation")
        
        // Temperature
        let tempIcon = UIImage(named: "thermometer")!
        let tempData = WeatherDataModel(propertyImage: tempIcon, propertyValue: "\(Int(round(self.temperature)))°F", propertyName: "Temperature")
        
        // Summary
        let summaryIcon = self.wIcon
        let summaryData = WeatherDataModel(propertyImage: summaryIcon, propertyValue: "", propertyName: "\(self.summary)")
        
        // Humidity
        let humidityIcon = UIImage(named: "water-percent")!
        let humidityData = WeatherDataModel(propertyImage: humidityIcon, propertyValue: "\(round(self.humidity * 100)) %", propertyName: "Humidity")
        
        // Visibility
        let visibilityIcon = UIImage(named: "eye-outline")!
        let visibilityData = WeatherDataModel(propertyImage: visibilityIcon, propertyValue: "\(self.visibility) km", propertyName: "Visibility")
        
        // Cloud Cover
        let cloudCoverIcon = UIImage(named: "weather-fog")!
        let cloudCoverData = WeatherDataModel(propertyImage: cloudCoverIcon, propertyValue: "\(round(self.cloudCover * 100)) %", propertyName: "Cloud Cover")
        
        // Ozone
        let ozoneIcon = UIImage(named: "earth")!
        let ozoneData = WeatherDataModel(propertyImage: ozoneIcon, propertyValue: "\(ozone) DU", propertyName: "Ozone")

        // Add data
        detailData.append(windSpeedData)
        detailData.append(pressureData)
        detailData.append(precipData)
        detailData.append(tempData)
        detailData.append(summaryData)
        detailData.append(humidityData)
        detailData.append(visibilityData)
        detailData.append(cloudCoverData)
        detailData.append(ozoneData)
    }
    
    //
    // getWeatherIcon
    //
    func getWeatherIcon()
    {
        // Get Icons
        if("clear-day" == self.iconName){ self.wIcon = UIImage(named: "weather-sunny")! }
        if("clear-night" == self.iconName){ self.wIcon = UIImage(named: "weather-night")! }
        if("rain" == self.iconName){ self.wIcon = UIImage(named: "weather-rainy")! }
        if("snow" == self.iconName){ self.wIcon = UIImage(named: "weather-snowy")! }
        if("sleet" == self.iconName){ self.wIcon = UIImage(named: "weather-snowy-rainy")! }
        if("wind" == self.iconName){ self.wIcon = UIImage(named: "weather-windy")! }
        if("fog" == iconName) { self.wIcon = UIImage(named: "weather-fog")! }
        if("cloudy" == iconName) { self.wIcon = UIImage(named: "weather-cloudy")! }
        if("partly-cloudy-day" == iconName) { self.wIcon = UIImage(named: "weather-partly-cloudy")! }
        if("partly-cloudy-night" == iconName) { self.wIcon = UIImage(named: "weather-night-partly-cloudy")! }
    }
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return detailData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "WeatherDetailCell"
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? WeatherDetailCell  else {
            fatalError("The dequeued cell is not an instance of WeatherDetailCell.")
        }
        
        // Fetches the appropriate day for the data source layout.
        let detail = detailData[indexPath.row]
        
        // Set Values
        cell.propertyValue.text = detail.propertyValue
        cell.propertyName.text = detail.propertyName
        cell.propertyImage.image = detail.propertyImage
        
        // Style of Cell
        cell.backgroundColor = UIColor(red:255/255, green:255/255, blue:255/255, alpha: 0.3)
        cell.layer.cornerRadius = 10;
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor(red:255/255, green:255/255, blue:255/255, alpha: 1).cgColor

        return cell
    }
}


extension TodayTabController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 110, height: 175)
    }
}
