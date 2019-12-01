//
//  ResultViewController.swift
//  WeatherApp
//
//  Created by Matthew Robinson on 11/16/19.
//  Copyright © 2019 Matthew Robinson. All rights reserved.
//

import UIKit
import Toast_Swift
import Foundation

class ResultViewController: UIViewController
{
    // MARK: Properties
    
    // Current View Controller
    var currentViewController:CurrentViewController?

    // First Sub-View Properties
    var city = ""
    var summary = ""
    var location = ""
    var temperature = 0.0
    
    // Result Card
    var resultCard:WeatherCard = Bundle.main.loadNibNamed("WeatherCard", owner: self, options: nil)?.first as! WeatherCard

    // Twitter Button
    @IBOutlet weak var twitterBtn: UIButton!
    
    // Weather Card
    @IBOutlet weak var weatherCard: UIView!

    // MARK: Initialization
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Update Weather Card
        self.weatherCard.addSubview(resultCard)

        // Update Title of Result View
        self.title = resultCard.city
        
        // Back button in navigation bar
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
        self.navigationItem.rightBarButtonItem = twitterButton
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
        
    //
    // tweet
    //
    @objc func tweet(sender: UIBarButtonItem)
    {
        print("Tweet()")
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
    // setMainViewController
    //
    func setMainViewController(view: CurrentViewController)
    {
        currentViewController = view
    }
}
