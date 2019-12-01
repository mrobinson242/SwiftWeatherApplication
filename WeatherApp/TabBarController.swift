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
         let q = "\(location)"
         let cx = "007605095661351441351:gvpfhjcomov"
         let imgSize = "large"
         let num = "8"
         let searchType = "image"
         let key = "AIzaSyCfbRMcIgw-ZY4hk1KswKN0hCaytlh3m9g"
        
         print ("Q: \(q)")

         // Get Photos
         let address = "https://www.googleapis.com/customsearch/v1?q=\(q)&cx=\(cx)&imgSize=\(imgSize)&num=\(num)&searchType=\(searchType)&key=\(key)"
         
         let url = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
         
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
