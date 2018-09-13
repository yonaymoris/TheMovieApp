//
//  MovieDetailsController.swift
//  TheMovieApp
//
//  Created by Phuong Ngo on 9/12/18.
//  Copyright © 2018 Phuong Ngo. All rights reserved.
//

import UIKit
import Cosmos
import Hashtags

class MovieDetailsController: UIViewController {

    @IBOutlet var backgroundImage: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var posterImage: UIImageView!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var votesLabel: UILabel!
    //@IBOutlet var cosmosView: CosmosView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var overViewLabel: UILabel!
    @IBOutlet var budgetLabel: UILabel!
    //@IBOutlet var genresView: HashtagView!
    
    
    var averageScore : Double = 0.0
    var titleText : String = ""
    var ratingText : String = ""
    var votesText : String = ""
    var dateText : String = ""
    var overviewText : String = ""
    var backgroundImg : String = ""
    var posterImg : String = ""
    var budget : String = ""
    var genres : [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        for i in genres {
//            var tag = HashTag(word: genre(id: i), withHashSymbol: false, isRemovable: false)
//            genresView.addTag(tag: tag)
//        }

        overViewLabel.sizeToFit()
        titleLabel.text = titleText
        ratingLabel.text = ratingText
        votesLabel.text = votesText
        //cosmosView.rating = averageScore
        dateLabel.text = dateText
        overViewLabel.text = overviewText
        budgetLabel.text = budget
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
    
    func genre(id : Int) -> String {
        switch id {
        case 28:
            return "Action"
        case 16:
            return "Animated"
        case 99:
            return "Documentary"
        case 18:
            return "Drama"
        case 10751:
            return "Family"
        case 14:
            return "Fantasy"
        case 36:
            return "History"
        case 35:
            return "Comedy"
        case 10752:
            return "War"
        case 80:
            return "Crime"
        case 10402:
            return "Music"
        case 9648:
            return "Mystery"
        case 10749:
            return "Romance"
        case 878:
            return "Sci fi"
        case 27:
            return "Horror"
        case 10770:
            return "TV Movie"
        case 53:
            return "Thriller"
        case 37:
            return "Western"
        case 12:
            return "Adventure"
        default:
            return "Unknown genre"
        }
    }
}