//
//  PhotosTabController.swift
//  WeatherApp
//
//  Created by Matthew Robinson on 11/17/19.
//  Copyright © 2019 Matthew Robinson. All rights reserved.
//

import UIKit

class PhotosTabController: UIViewController
{
    // Link Temperature Line Chart
    @IBOutlet weak var photoView: UIScrollView!

    // MARK: Initialization
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Initialize Photo View Size
        self.photoView.contentSize = CGSize(width:364, height:0)
    }
    
    func setPhotos(photoData: [String])
    {
        // Iterate over the Photos
        for index in 0...photoData.count-1
        {
            // Get Photo Contents
            let url = URL(string: "\(photoData[index])")
            let data = try? Data(contentsOf: url!)
            
            if let imageData = data
            {
                let image = UIImage(data: imageData)
                
                let imageView = UIImageView(image: image)
                imageView.frame = CGRect(x: 0, y: 0 + (index*400), width: 364, height: 450)
                photoView.addSubview(imageView)
                self.photoView.contentSize.height += imageView.frame.size.height
            }
        }
    }
}
