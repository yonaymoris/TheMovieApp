//
//  MovieDetailsController.swift
//  TheMovieApp
//
//  Created by Phuong Ngo on 9/12/18.
//  Copyright © 2018 Phuong Ngo. All rights reserved.
//

import UIKit
import Cosmos

class MovieDetailsController: UIViewController {

    @IBOutlet var backgroundImage: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var posterImage: UIImageView!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var votesLabel: UILabel!
    @IBOutlet var cosmosView: CosmosView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var overViewLabel: UILabel!
    
    var averageScore : Double = 0.0
    var titleText : String = ""
    var ratingText : String = ""
    var votesText : String = ""
    var dateText : String = ""
    var overviewText : String = ""
    var backgroundImg : String = ""
    var posterImg : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overViewLabel.sizeToFit()
        titleLabel.text = titleText
        ratingLabel.text = ratingText
        votesLabel.text = votesText
        cosmosView.rating = averageScore
        dateLabel.text = dateText
        overViewLabel.text = overviewText
        //print(overviewText)
        
        if let img_url1 = URL(string: "http://image.tmdb.org/t/p/w185/\(backgroundImg)") {
            do {
                //print("dope")
                let data = try Data(contentsOf: img_url1)
                backgroundImage.image = UIImage(data: data)
            } catch let err {
                print("Error")
            }
        }
        
        if let img_url2 = URL(string: "http://image.tmdb.org/t/p/w185/\(posterImg)") {
            do {
                //print(img_url)
                let data1 = try Data(contentsOf: img_url2)
                posterImage.image = UIImage(data: data1)
            } catch let err {
                print("Error")
            }
        }
        
    }
}
