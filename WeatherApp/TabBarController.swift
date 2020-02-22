//
//  TabBarController.swift
//  WeatherApp
//
//  Created by Matthew Robinson on 11/16/19.
//  Copyright © 2019 Matthew Robinson. All rights reserved.
//

import UIKit
import SwiftSpinner
import Alamofire
import SwiftyJSON

class TabBarController: UITabBarController, UITabBarControllerDelegate
{
    // MARK: Properties
    var city = ""
    var location = ""
    var summary = ""
    var temperature = 0.0
    
    // Photo Data
    var photoData = [String]()

    // MARK: Initialization
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Set Title
        self.delegate = self
        self.title = city
        
        //For back button in navigation bar
        let backButton = UIBarButtonItem()
        backButton.title = "Weather"
        
        // Create Twitter Button
        let twitterButton = UIBarButtonItem(
            image:  UIImage(named: "twitter"),
            style: .plain,
            target: self,
            action: #selector(tweet(sender:))
        )
        
        // Update Buttons
        self.navigationItem.rightBarButtonItems = [twitterButton]
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem)
    {
        // Get Photos
        if item.self.title == "PHOTOS" {
            // Show Big Spinner
            SwiftSpinner.show("Fetching Google Images...")
            
            // Get Photos
            getPhotos()
        }
    }

    //
    // tweet
    //
    @objc func tweet(sender: UIBarButtonItem)
    {
        let temp = "\(Int(round(self.temperature)))° F"
        let tempString = "The current temperature at \(city) is \(temp)."
        let summaryString = "The weather conditions are \(summary)"
        let hashtag = "&hashtags=CSCI571WeatherSearch"
        let urlString = "https://twitter.com/intent/tweet?text=\(tempString) \(summaryString) \(hashtag)"
        let urlQuery = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        if let urlopen = URL(string: urlQuery!)
        {
            UIApplication.shared.open(urlopen)
        }
    }
    
     //
     // getPhotos
     //
     func getPhotos()
     {
        // Split Location
        let strArray = location.split{$0 == ","}.map(String.init)

        // Form Query
        let query = "Skyline \(strArray[0])"
        
        // Create Geocode Url Address
        let address = "http://octofire.us-east-2.elasticbeanstalk.com/googlePhotos/?location=\(query)"

        // Encode Address
        let url = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
         // Check if URL is valid
         if let urlopen = URL(string: url!)
         {
             // Request Data
             Alamofire.request(urlopen)
             
             // Handle the response
             .responseJSON { response in
               guard response.result.isSuccess,
                 let value = response.result.value else {
                   print("Error while getting City Photos: \(String(describing: response.result.error))")
                   return
               }
                 
                 // Get JSON Data
                 let json = JSON(value);
                
                 // Clear out existing data
                 self.photoData.removeAll()
                 
                 // Iterate over Photos
                 for item in json["items"].arrayValue
                 {
                    self.photoData.append(item["link"].stringValue)
                 }
                
                // Set Photos in Controller
                let photosViewController = self.viewControllers![2] as! PhotosTabController;
                photosViewController.setPhotos(photoData: self.photoData)
                
                // Hide Swift Spinner
                SwiftSpinner.hide()
             }
         }
     }
}
