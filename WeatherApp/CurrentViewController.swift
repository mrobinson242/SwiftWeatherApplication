// MARK: Imports
import UIKit
import SwiftSpinner
import Alamofire
import SwiftyJSON
import Toast_Swift
import Foundation
import QuartzCore
import CoreLocation

class CurrentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate,UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate,
    UIScrollViewDelegate
{
    // MARK: Properties

    // Location Manager
    var locationManager:CLLocationManager!
    var geocoder:CLGeocoder!
    
    // Search Bar Controller
    var searchBar : UISearchBar!
        
    // Latitude/Longitude
    var lat = ""
    var lon = ""
    
    // Create User Defaults Object
    var defaults = UserDefaults.standard

    // First Sub-View Properties
    var city = ""
    var state = "California"
    var timezone = ""
    var temperature = 0.0
    var summary = ""
    var weatherIconName = ""

    // Suggestion Data
    var suggestionData = [String]()
    
    // Prevent Segue for Result View
    var badParameters:Bool = true
    
    // Number of Favorites
    var numFavorites:Int = 0
    var favoriteList = [String]()
    
    // Create Weather Cards
    var currentCard:WeatherCard = Bundle.main.loadNibNamed("WeatherCard", owner: self, options: nil)?.first as! WeatherCard
    var resultCard:WeatherCard = Bundle.main.loadNibNamed("WeatherCard", owner: self, options: nil)?.first as! WeatherCard
    var selectedCard:WeatherCard = Bundle.main.loadNibNamed("WeatherCard", owner: self, options: nil)?.first as! WeatherCard

    // List of all weather cards
    var cards:[WeatherCard] = []

    // Table Views
    @IBOutlet var suggestionDataView: UITableView!

    // Scroll View/Page Control
    @IBOutlet weak var pageControl : UIPageControl!
    @IBOutlet weak var scrollView : UIScrollView!
        
    // MARK: Initialization
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Show Big Spinner
        SwiftSpinner.show("Loading...")
        
        // Initialize table properties
        self.suggestionDataView.delegate = self;
        self.suggestionDataView.dataSource = self;
        
        // Style Suggestion View
        self.suggestionDataView.layer.cornerRadius = 10
        self.suggestionDataView.layer.masksToBounds = true
        
        // Search Bar Initialization
        self.searchBar = UISearchBar()
        self.searchBar.showsCancelButton = false
        self.searchBar.placeholder = "Enter City Name"
        self.searchBar.delegate = self
        self.navigationItem.titleView = searchBar
        
        // Location Information
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization();
        self.locationManager.requestLocation()
        
        self.geocoder = CLGeocoder()

        // Scroll View Initialization
        scrollView.delegate = self
        
        // Hide Favorite Button on Current Card
        currentCard.hideFavButton(isHidden: true)
        currentCard.setMainViewController(view: self)

        // Add Current Card to Weather Page List
        self.cards.append(currentCard)

        // Load Favorites
        loadFavorites()
        
        // Setup for Scroll View
        setupScrollView(cards: cards)
        
        // Update Page Control
        pageControl.numberOfPages = cards.count
        pageControl.currentPage = 0

        // Bring Views to Front
        view.bringSubviewToFront(suggestionDataView)
        view.bringSubviewToFront(pageControl)
    }
    
    // MARK: Location Functions

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        // Get Latitude/Longitude
        self.lat = String(manager.location!.coordinate.latitude)
        self.lon = String(manager.location!.coordinate.longitude)
        
        let loc: CLLocation = CLLocation(latitude: manager.location!.coordinate.latitude, longitude: manager.location!.coordinate.longitude)

        self.geocoder.reverseGeocodeLocation(loc, completionHandler:
        {(placemarks,error) in
            let pm = placemarks! as [CLPlacemark]
            
            if pm.count > 0
            {
                let pm = placemarks![0]
                self.city = pm.locality!
                let country = pm.country!
                let loc = "\(self.city), \(country)"
                
                // TODO: Get Correct City/State/Lat/Lon
                self.currentCard.city = self.city
                self.currentCard.setLocation(location: loc)
                
                // Get Dark Sky Data
                self.getDarkSkyData(city: self.city, lat: self.lat, lon: self.lon, card: self.currentCard, isResult: false)
            }
        })
    }
        
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        // Get Current Location Data
        let url = "http://octofire.us-east-2.elasticbeanstalk.com/autocomplete/?input=\(searchText)"

        // Request Autocomplete Data
        Alamofire.request(url)
                
        // Handle the response
        .responseJSON { response in
          guard response.result.isSuccess,
            let value = response.result.value else {
              print("Error while getting Autocomplete Data: \(String(describing: response.result.error))")
              return
          }
          
            // Get JSON Data
            let json = JSON(value);

            // Clear Existing Elements
            self.suggestionData.removeAll()

            // Iterate over predictions
            for item in json["predictions"].arrayValue
            {
                // Get suggestion data
                let city = item["structured_formatting"]["main_text"]
                let state = item["structured_formatting"]["secondary_text"]
                let suggestion: String = "\(city), \(state)"

                // Add Data to Suggestion List
                self.suggestionData.append(suggestion)
            }
            
            // Refresh Table
            self.suggestionDataView.reloadData()
            
            if(self.searchBar.text != "") {
                self.suggestionDataView.isHidden = false;
                self.suggestionDataView.becomeFirstResponder()
            }
            else {
                self.suggestionDataView.isHidden = true;
            }
        }
    }

    //
    // updateSearchResults
    //
    func updateSearchResults(for searchController: UISearchController){}
    
    //
    // getGeocodeData
    //
    func getGeocodeData(street: String, city: String, state: String, card: WeatherCard, isResult: Bool)
    {
        // Create Geocode Url Address
        let address = "http://octofire.us-east-2.elasticbeanstalk.com/geocode/?street=\(street)&city=\(city)&state=\(state)"
        
        // Encode Address
        let queryUrl = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        //Check if Address is valid
        if let url = URL(string: queryUrl!)
        {
            // Request Data
            Alamofire.request(url)
            
            // Handle the response
            .responseJSON { response in
              guard response.result.isSuccess,
                let value = response.result.value else {
                  print("Error while getting Google Geocode Data: \(String(describing: response.result.error))")
                  return
              }
              
                // Get JSON Data
                let json = JSON(value);
                
                // Set City
                card.state = state

                // Set Latitude/Longitude
                self.lat = json["results"][0]["geometry"]["location"]["lat"].stringValue
                self.lon = json["results"][0]["geometry"]["location"]["lng"].stringValue

                // Get Dark Sky Data
                self.getDarkSkyData(city: city, lat: self.lat, lon: self.lon, card: card, isResult: isResult)
            }
        }
    }

    //
    // getDarkSkyData - Gets Dark Sky Data
    //
    func getDarkSkyData(city: String, lat: String, lon: String, card: WeatherCard, isResult: Bool)
    {
        // Get Current Location Data
        let url = "http://octofire.us-east-2.elasticbeanstalk.com/darkSky/?lat=\(lat)&lon=\(lon)"

        // Request Data
        Alamofire.request(url)
        
        // Handle the response
        .responseJSON { response in
          guard response.result.isSuccess,
            let value = response.result.value else {
              print("Error while getting Dark Sky Data: \(String(describing: response.result.error))")
              return
          }
        
            // Get JSON Data
            let json = JSON(value);
            
            // Get First Sub View Properties
            self.timezone = json["timezone"].stringValue
            self.temperature = json["currently"]["temperature"].doubleValue
            self.summary = json["currently"]["summary"].stringValue
            self.weatherIconName = json["currently"]["icon"].stringValue

            // Update Weather Properties
            let humidity = json["currently"]["humidity"].doubleValue
            let windSpeed = json["currently"]["windSpeed"].doubleValue
            let precipitation = json["currently"]["precipIntensity"].doubleValue
            let visibility = json["currently"]["visibility"].doubleValue
            let pressure = json["currently"]["pressure"].doubleValue
            let cloudCover = json["currently"]["cloudCover"].doubleValue
            let ozone = json["currently"]["ozone"].doubleValue

            // Update Card Subviews
            card.updateFirstSubView(city: city, temp: self.temperature, summary: self.summary , iconName: self.weatherIconName)
            card.updateSecondSubView(humidity: humidity, windSpeed: windSpeed, visibility: visibility, pressure: pressure)
            card.updateWeatherValues(precipitation: precipitation, cloudCover: cloudCover, ozone: ozone)
            
            // Set Weekly Properties
            card.weeklySummary = json["daily"]["summary"].stringValue
            card.weeklyIconName = json["daily"]["icon"].stringValue
            
            // Update Daily Data
            card.updateDailyData(dailyData: json["daily"]["data"].arrayValue)

            // Check if for Result Page
            if(isResult) {
                self.performSegue(withIdentifier: "showResultView", sender: self)
            }

            // Show Big Spinner
            SwiftSpinner.hide()
        }
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return suggestionData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "SuggestionCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SuggestionCell  else {
            fatalError("The dequeued cell is not an instance of SuggestionCell.")
        }
        
        // Fetch Suggestion for the data source layout
        let suggestion = suggestionData[indexPath.row]

        // Set Value
        cell.locationLabel.text = suggestion
            
        return cell
    }
    
    // MARK: Current Function
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        // Check if it's Suggestion Table
        if(suggestionDataView == tableView)
        {
            // Get Selection
            let selected = suggestionData[indexPath.row]
            
            // Split Selection into parameters
            let selectedArr = selected.split{$0 == ","}.map(String.init)
            
            // Show Big Spinner
            SwiftSpinner.show("Fetching Weather Details for \(selected)")
            
            // Clear Search Bar
            self.searchBar.text = ""
            
            // Hide AutoComplete
            self.suggestionDataView.isHidden = true;
            
            let city = selectedArr[0]
            let state = selectedArr[1].trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Set Card Location
            resultCard.state = state
            resultCard.city = city
            resultCard.setLocation(location: selected)

            // Get Google Geocode Data
            getGeocodeData(street: "", city: city, state: state, card: resultCard, isResult: true)
        }
    }
        
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if badParameters  {
             // your code here, like badParameters  = false, e.t.c
             return false
        }
        return true
    }
    

    // MARK: Prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // Show Results Pane
        if(segue.identifier == "showResultView")
        {
            // Create connection to ResultViewController
            let resultView = segue.destination as! ResultViewController;
            
            // Set Main Controller of Result View/Card
            resultCard.setMainViewController(view: self)
            resultCard.setResultViewController(view: resultView)
            resultView.setMainViewController(view: self)
            
            // Check if Result is already a Favorite
            let loc = resultCard.getLocation()
            if favoriteList.contains(loc) {
                // Update Result Card if in Favorite List
                resultCard.updateFavoriteStatus(isFavorite: true)
            }
            else{
                // Update Result Card if in Favorite List
                resultCard.updateFavoriteStatus(isFavorite: false)
            }

            // Update Result View's Result Card
            resultView.resultCard = self.resultCard
        }
        // Show Tab Pane
        else if(segue.identifier == "showTabView")
        {
            // Set Tab Bar Values
            let tabBar = segue.destination as! TabBarController;
            tabBar.location = selectedCard.location
            tabBar.city = selectedCard.city
            tabBar.summary = selectedCard.summary
            tabBar.temperature = selectedCard.temperature

            // Set Today Tab Values
            let todayTab = tabBar.viewControllers![0] as! TodayTabController;
            todayTab.windSpeed = selectedCard.windSpeed
            todayTab.pressure = selectedCard.pressure
            todayTab.precipitation = selectedCard.precipitation
            todayTab.temperature = selectedCard.temperature
            todayTab.summary = selectedCard.summary
            todayTab.iconName = selectedCard.iconName
            todayTab.humidity = selectedCard.humidity
            todayTab.visibility = selectedCard.visibility
            todayTab.cloudCover = selectedCard.cloudCover
            todayTab.ozone = selectedCard.ozone
            
            // Set Weekly Tab Values
            let weeklyTab = tabBar.viewControllers![1] as! WeeklyTabController;
            weeklyTab.summary = selectedCard.weeklySummary
            weeklyTab.iconName = selectedCard.weeklyIconName
            weeklyTab.minTempData = selectedCard.weeklyTempMinData
            weeklyTab.maxTempData = selectedCard.weeklyTempMaxData
        }
    }
    
    // MARK: Favorites
    
    //
    // loadFavorites
    //
    func loadFavorites()
    {
        self.favoriteList = defaults.stringArray(forKey: "favorites") ?? [String]()
        self.numFavorites = favoriteList.count
        
        // Iterate over favorites
        for favorite in favoriteList
        {
            // Create weather card
            let card:WeatherCard = Bundle.main.loadNibNamed("WeatherCard", owner: self, options: nil)?.first as! WeatherCard
            
            // Set Card to be Favorited
            card.updateFavoriteStatus(isFavorite: true)
            card.setMainViewController(view: self)
            card.setLocation(location: favorite)
            
            print("Location: \(favorite)")

            // Split Favorite Location into parameters
            let favoriteArr = favorite.split{$0 == ","}.map(String.init)
            let favCity = favoriteArr[0]
            let favState = favoriteArr[1].trimmingCharacters(in: .whitespacesAndNewlines)

            // Get Google Geocode Data
            getGeocodeData(street: "", city: favCity, state: favState, card: card, isResult: false)
            
            // Attach Favorite Card to List of Cards
            self.cards.append(card)
        }
    }
    
    // MARK: Scroll View
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
    
    func setupScrollView(cards : [WeatherCard])
    {
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(cards.count), height: view.frame.height)
        scrollView.isPagingEnabled = true
        
        for i in 0 ..< cards.count {
            cards[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: view.frame.height)
            scrollView.addSubview(cards[i])
        }
    }
    
    func refreshScrollView(cards: [WeatherCard])
    {
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(cards.count), height: view.frame.height)
    }
        
    //
    // scrollViewDidScroll
    //
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
    
    //
    // loadTabView
    //
    func loadTabView(card: WeatherCard)
    {
        // Update Selected Card
        selectedCard = card

        // Show the Tab View
        performSegue(withIdentifier: "showTabView", sender: self)
    }

    //
    // addFavorite - Adds Favorite to Card List
    //
    func addFavorite(card: WeatherCard)
    {
        // Add Card to Favorites List
        cards.append(card);
        
        // Add to Favorite List
        let location:String = card.getLocation()
        favoriteList.append("\(location)")
        defaults.set(favoriteList, forKey: "favorites")

        // Refresh ScrollView / Page Control
        setupScrollView(cards: cards)
        pageControl.numberOfPages = cards.count
    }

    //
    // removeFavorite  - Removes Favorite from Card List
    //
    func removeFavorite(card: WeatherCard)
    {
        // Initialize Card to Remove
        var removeCard: WeatherCard = card

        // Iterate over Cards
        for item in cards
        {
            // Check if Locations match
            if item.getLocation() == card.getLocation()
            {
                removeCard = item
            }
        }

        // Get card in Cards List
        if let index = cards.firstIndex(of: removeCard)
        {
            // Remove From Card List
            cards.remove(at: index)

            // Remove from Favorite List
            let location:String = card.getLocation()
            favoriteList.removeAll { $0 == "\(location)" }
            defaults.set(favoriteList, forKey: "favorites")

            // Remove from Scroll View
            removeCard.removeFromSuperview()
            
            // Show Toast-Swift Message
            self.view.makeToast("\(removeCard.city) was removed from the Favorite List")

            // Refresh ScrollView / Page Control
            setupScrollView(cards: cards)
            pageControl.numberOfPages = cards.count
        }
    }
}
