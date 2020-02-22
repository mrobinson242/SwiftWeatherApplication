//
//  WeatherCard.swift
//  
//
//  Created by Matthew Robinson on 11/17/19.
//

import UIKit
import SwiftyJSON
import Toast_Swift
import Alamofire

class WeatherCard: UIView, UITableViewDelegate, UITableViewDataSource, NSCopying
{
    // Days Array
    var days = [DailyWeatherData]()
    
    // Daily Data Array
    var dailyData = [JSON]()
    
    // Favorite Indication
    var isFavorite = false
    
    // Current View Controller
    var currentViewController:CurrentViewController?
    var resultViewController:ResultViewController?

    // User Defaults
    var defaults = UserDefaults.standard

    // City/Location associated with Weather Card
    var city = ""
    var state = ""
    var location = ""
    
    // 1st Sub-View
    var temperature = 0.0
    var summary = ""
    var iconName = ""
    
    // Weather Values
    var humidity = 0.0
    var windSpeed = 0.0
    var visibility = 0.0
    var pressure = 0.0
    var ozone = 0.0
    var cloudCover = 0.0
    var precipitation = 0.0

    // Weekly Data
    var weeklySummary = ""
    var weeklyIconName = ""
    var weeklyTempMinData = [Double]()
    var weeklyTempMaxData = [Double]()
    
    // Link to Favorite Button
    @IBOutlet weak var favButton: UIButton!

    // Links to 1st Subview values
    @IBOutlet weak var firstSubView: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var tempValue: UILabel!
    @IBOutlet weak var summaryValue: UILabel!
    @IBOutlet weak var cityValue: UILabel!
    
    // Link to 2nd Subview values
    @IBOutlet weak var humidityValue: UILabel!
    @IBOutlet weak var windSpeedValue: UILabel!
    @IBOutlet weak var visibilityValue: UILabel!
    @IBOutlet weak var pressureValue: UILabel!
    
    // Link to 3rd Subview values
    @IBOutlet var dailyDataView: UITableView!
    
    //
    // draw - Custom Drawing
    //
    override func draw(_ rect: CGRect)
    {
        // Styling of First Sub View
        firstSubView.layer.cornerRadius = 10
        firstSubView.layer.masksToBounds = true
        firstSubView.layer.borderWidth = 1
        firstSubView.layer.borderColor = UIColor(red:255/255, green:255/255, blue:255/255, alpha: 0.5).cgColor

        // Styling of Third Sub View
        dailyDataView.layer.cornerRadius = 10;
        dailyDataView.layer.masksToBounds = true;
        dailyDataView.backgroundColor = UIColor(red:255/255, green:255/255, blue:255/255, alpha: 0.3)

        // Set 3rd Subview table sources
        dailyDataView.delegate = self;
        dailyDataView.dataSource = self;

        // Register cell type for Daily Data View
        dailyDataView.register(UINib(nibName: "DailyDataCell", bundle: nil), forCellReuseIdentifier: "DailyDataCell")
        
        // Add action for Favorite Button
        favButton.addTarget(self, action: #selector(handleFavButton), for: .touchUpInside)
        
        // Initialize Button Click for Info View
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.infoClick(recognizer:)))
        singleTap.numberOfTapsRequired = 1
        firstSubView.addGestureRecognizer(singleTap)
    }

    // Setters for controllers
    func setMainViewController(view: CurrentViewController) { currentViewController = view }
    func setResultViewController(view: ResultViewController) { resultViewController = view }

    // Getter for City
    func getCity() -> String {return self.city }

    // Setter/Getter for Location
    func setLocation(location: String) { self.location = location}
    func getLocation() -> String { return self.location }
    
    //
    //  updateFirstSubView - Updates First Subview values
    //
    func updateFirstSubView(city: String, temp: Double, summary: String, iconName: String)
    {
        // Update Globals
        self.city = city
        self.temperature = temp
        self.summary = summary
        self.iconName = iconName
        
        // Update display values
        self.cityValue.text = "\(city)"
        self.tempValue.text = "\(Int(round(temp)))° F"
        self.summaryValue.text = "\(summary)"
        
        // Update Weather Icon
        if("clear-day" == iconName){ self.icon.image = UIImage(named: "weather-sunny")! }
        if("clear-night" == iconName){ self.icon.image = UIImage(named: "weather-night")! }
        if("rain" == iconName){ self.icon.image = UIImage(named: "weather-rainy")! }
        if("snow" == iconName){ self.icon.image = UIImage(named: "weather-snowy")! }
        if("sleet" == iconName){ self.icon.image = UIImage(named: "weather-snowy-rainy")! }
        if("wind" == iconName){ self.icon.image = UIImage(named: "weather-windy-variant")! }
        if("fog" == iconName) { self.icon.image = UIImage(named: "weather-fog")! }
        if("cloudy" == iconName) { self.icon.image = UIImage(named: "weather-cloudy")! }
        if("partly-cloudy-day" == iconName) { self.icon.image = UIImage(named: "weather-partly-cloudy")! }
        if("partly-cloudy-night" == iconName) { self.icon.image = UIImage(named: "weather-night-partly-cloudy")! }
    }
    
    //
    // updateSecondSubView - Updates Second Subview values
    //
    func updateSecondSubView(humidity: Double, windSpeed: Double, visibility: Double, pressure: Double)
    {
        // Update Globals
        self.humidity = humidity
        self.windSpeed = windSpeed
        self.visibility = visibility
        self.pressure = pressure

        // Update Second Sub View Values
        humidityValue.text = "\(humidity * 100)%"
        windSpeedValue.text = "\(windSpeed) mph"
        visibilityValue.text = "\(visibility) mi"
        pressureValue.text = "\(pressure) mb"
    }
    
    //
    // updateWeatherValues
    //
    func updateWeatherValues(precipitation: Double, cloudCover: Double, ozone: Double )
    {
        // Update Globals
        self.precipitation = precipitation
        self.cloudCover = cloudCover
        self.ozone = ozone
    }
    
    //
    // updateDailyData
    //
    func updateDailyData(dailyData: [JSON])
    {
        // Clear arrays
        self.dailyData.removeAll();
        self.weeklyTempMinData.removeAll();
        self.weeklyTempMaxData.removeAll();
        self.days.removeAll();
        
        // Set Daily Data
        self.dailyData = dailyData
        
        // Iterate over daily data
        for item in dailyData
        {
           // Get Min/Max Temperature Data
           self.weeklyTempMinData.append(round(item["temperatureMin"].doubleValue))
           self.weeklyTempMaxData.append(round(item["temperatureMax"].doubleValue))

           // Get Weather Icon Name
           let iconName = item["icon"].stringValue;

           // Get Sunrise/Sunset Times
           let time = Date(timeIntervalSince1970:item["time"].doubleValue)
           let startTime = Date(timeIntervalSince1970:item["sunriseTime"].doubleValue)
           let endTime = Date(timeIntervalSince1970:item["sunsetTime"].doubleValue)

           // Date Formatter
           let dateFormatter = DateFormatter()
           dateFormatter.timeZone = TimeZone(abbreviation: "PST")
           dateFormatter.dateFormat = "MM/dd/YYYY"
           let date = dateFormatter.string(from: time)
           
           // Sunrise/Sunset Date Formatter
           let sunDateFormatter = DateFormatter()
           sunDateFormatter.timeZone = TimeZone(abbreviation: "PST")
           sunDateFormatter.dateFormat = "HH:mm"
           sunDateFormatter.locale = NSLocale.current

           // Get Sunrise Time
           let sunriseTime = sunDateFormatter.string(from: startTime)
           
           // Get Sunset Time
           let sunsetTime = sunDateFormatter.string(from: endTime)

           // Add Day to Table
           loadDay(date: date, iconName: iconName, sunrise: sunriseTime, sunset: sunsetTime)
       }
       
       // Refresh Table
       self.dailyDataView.reloadData()
    }
    
    //
    // loadDay
    //
    func loadDay(date: String, iconName: String, sunrise: String, sunset: String)
    {
        // Create Weather Icon
        var wIcon: UIImage = UIImage(named: "weather-sunny")!

        // Get Icons
        if("clear-day" == iconName) { wIcon = UIImage(named: "weather-sunny")! }
        if("clear-night" == iconName) { wIcon = UIImage(named: "weather-night")! }
        if("rain" == iconName) { wIcon = UIImage(named: "weather-rainy")! }
        if("snow" == iconName) { wIcon = UIImage(named: "weather-snowy")! }
        if("sleet" == iconName) { wIcon = UIImage(named: "weather-snowy-rainy")! }
        if("wind" == iconName) { wIcon = UIImage(named: "weather-windy-variant")! }
        if("fog" == iconName) { wIcon = UIImage(named: "weather-fog")! }
        if("cloudy" == iconName) { wIcon = UIImage(named: "weather-cloudy")! }
        if("partly-cloudy-day" == iconName) { wIcon = UIImage(named: "weather-partly-cloudy")! }
        if("partly-cloudy-night" == iconName) { wIcon = UIImage(named: "weather-night-partly-cloudy")! }
        
        guard let day = DailyWeatherData(date: date, weatherIcon: wIcon, sunrise: sunrise, sunset: sunset) else {
                   fatalError("Unable to instantiate Day")
        }

        days += [day]
    }
    
    //
    // hideFavButton
    //
    func hideFavButton(isHidden: Bool)
    {
        favButton.isHidden = isHidden
    }
    
    //
    // tableView
    //
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
         // Table view cells are reused and should be dequeued using a cell identifier.
         let cellIdentifier = "DailyDataCell"
         
          let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as!  DailyDataCell

         // Fetches the appropriate day for the data source layout.
         let day = days[indexPath.row]
         
         // Set Values
         cell.dateLabel.text = day.date
         cell.weatherIcon.image = day.weatherIcon
         cell.sunriseTime.text = day.sunrise
         cell.sunsetTime.text = day.sunset
         
         // Style of Cell Color
         cell.backgroundColor = UIColor.clear
         
         return cell
     }
    
    //
    // tableView - Return number of Rows
    //
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return days.count
    }
    
    //
    // updateFavoriteStatus
    //
    func updateFavoriteStatus(isFavorite: Bool)
    {
        if(isFavorite)
        {
            // Update image of Favorite Button
            favButton.setImage(UIImage(named: "trash-can"), for: .normal)
        }
        else
        {
            // Update image of Favorite Button
            favButton.setImage(UIImage(named: "plus-circle"), for: .normal)
        }
        
        // Update Favorite Status
        self.isFavorite = isFavorite
    }

    //
    // handleFavButton
    //
    @objc func handleFavButton()
    {        
        // Check Favorite Status
        if(!isFavorite)
        {
            // Update Favorite Status
            updateFavoriteStatus(isFavorite: true)

            // Make deep copy of card
            let dCard = self.copy() as! WeatherCard

            // Add Favorite to application
            currentViewController!.addFavorite(card: dCard)

            // Show Toast-Swift Message
            makeToast("\(self.city) was added to the Favorite List")
        }
        else
        {
            // Update Favorite Status
            updateFavoriteStatus(isFavorite: false)
            
            // Make deep copy of card
            let dCard = self.copy() as! WeatherCard

            // Remove Favorite from application
            currentViewController!.removeFavorite(card: dCard)
            
            // Show Toast-Swift Message
            makeToast("\(self.city) was removed from the Favorite List")
        }
    }
    // MARK: Copy
    func copy(with zone: NSZone? = nil) -> Any
    {
        // Create Copy Card
        let card:WeatherCard = Bundle.main.loadNibNamed("WeatherCard", owner: self, options: nil)?.first as! WeatherCard
        
        // Set Location
        card.location = self.getLocation()

        // Update Subviews
        card.updateFirstSubView(city: self.city, temp: self.temperature, summary: self.summary, iconName: self.iconName)
        card.updateSecondSubView(humidity: self.humidity, windSpeed: self.windSpeed, visibility: self.visibility, pressure: self.pressure)
        card.updateWeatherValues(precipitation: self.precipitation, cloudCover: self.cloudCover, ozone: self.ozone)
        card.weeklySummary = self.weeklySummary
        card.weeklyIconName = self.weeklyIconName
        card.updateDailyData(dailyData: self.dailyData)
        card.updateFavoriteStatus(isFavorite: self.isFavorite)
        card.currentViewController = self.currentViewController

        return card
    }
    
    //
    // infoClick
    //
    @objc func infoClick(recognizer: UIGestureRecognizer)
    {
        // Load the Tab View
        currentViewController!.loadTabView(card: self)
    }
}
