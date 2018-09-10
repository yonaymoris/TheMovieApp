//
//  ViewController.swift
//  TheMovieApp
//
//  Created by Phuong Ngo on 9/10/18.
//  Copyright © 2018 Phuong Ngo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD
import CoreData


class ViewController: UIViewController {

    let URL_REQUEST = "https://api.themoviedb.org/3/discover/movie?api_key=fd8ca0808223a0ca5f2b775a8237c9d9&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page="
    let APP_KEY = "fd8ca0808223a0ca5f2b775a8237c9d9"
    var movies : [NSManagedObject] = []
    var page = 1
    
    @IBOutlet var testImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        retreiveData()
        
//        var movie = movies[0]
//        print(movie.value(forKeyPath: "poster_path") as! String)
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        SVProgressHUD.show()
        getMovieData(url: URL_REQUEST, page: page)
        SVProgressHUD.dismiss()
    }
    
    
    // get movies data from the movie db API
    func getMovieData(url : String, page: Int) {
        let request = url + String(page)
        Alamofire.request(request, method : .get).responseJSON {
            response in
            if response.result.isSuccess {
                //print("Success! Got the data")
                
                let movieJSON : JSON = JSON(response.result.value!)
                //print(type(of: movieJSON["results"][]))
                
                if page == 1 {
                    self.deleteAllData()
                    self.movies = []
                }
                
                self.saveData(json: movieJSON["results"][])
                //self.saveMovie(json: movieJSON["results"][][1])
                //print(movieJSON["results"][][1])
                //let img_path = movieJSON["results"][][1]["poster_path"].string
                
                
                //                if let img_url = URL(string: "http://image.tmdb.org/t/p/w185/\(img_path!)") {
                //                    do {
                //                        print(img_url)
                //                        let data = try Data(contentsOf: img_url)
                //                        self.testImage.image = UIImage(data: data)
                //                    } catch let err {
                //                        print("Error")
                //                    }
                //                }
                
            }
            else {
                print("Connection Issues")
            }
        }
    }
    
    
    // retreive data from the Core Data Database
    func retreiveData() {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let context =
            appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Movie")
        
        do {
            movies = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    
    // save an array of movies to Core Data Database
    func saveData(json: JSON) {
        for i in 0...json.count-1 {
            self.saveMovie(json: json[i])
        }
    }
    
    
    // delete all data from Core Data Database (is being called only in case an app is able to retreive data from API e.g. there is internet connection)
    func deleteAllData() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Movie")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
    }
    
    
    // save a single movie to Core Data Database
    func saveMovie(json: JSON) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        print(json)
        
        let context =
            appDelegate.persistentContainer.viewContext
        let entity =
            NSEntityDescription.entity(forEntityName: "Movie",
                                       in: context)!
        let movie = NSManagedObject(entity: entity,
                                    insertInto: context)
        
        let attributes = ["poster_path", "backdrop_path", "genre_ids", "vote_count", "overview", "original_title", "vote_average", "popularity", "id", "original_language", "release_date", "title"]
        
        for i in attributes {
            if i == "genre_ids" {
                movie.setValue(genreIdsToString(genre_ids: genreIdsFromJson(json: json[i])), forKeyPath: i)
            } else if i == "id" {
                movie.setValue(json[i].int, forKeyPath: i)
            } else if i == "popularity" {
                movie.setValue(json[i].double, forKeyPath: i)
            } else if i == "vote_average" {
                movie.setValue(json[i].double, forKeyPath: i)
            } else if i == "vote_count" {
                movie.setValue(json[i].int, forKeyPath: i)
            } else {
                movie.setValue(json[i].string, forKeyPath: i)
            }
        }
        
        do {
            try context.save()
            movies.append(movie)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
    @IBAction func loadMorePressed(_ sender: Any) {
        page += 1
        SVProgressHUD.show()
        getMovieData(url: URL_REQUEST, page: page)
        SVProgressHUD.dismiss()
    }
    
    
    // converts an array of genre ids to string to store in Core Data Database
    func genreIdsToString(genre_ids : [Int]) -> String {
        var str : String = ""
        for i in genre_ids {
            str += String(i) + " "
        }
        
        return str
    }
    
    
    // converts a string of genre ids to Int array to define the genre
    func genreIdsToInt(genre_ids : String) -> [Int] {
        
        if genre_ids != "" {
            var arr = genre_ids.components(separatedBy: " ")
            arr.removeLast()
            
            let intArray = arr.map { Int($0)!}
            return intArray
        } else {
            return [0] }
    }
    
    
    func genreIdsFromJson (json: JSON) -> [Int] {
        var arr : [Int] = []
        let arr1 = json.array
        for i in arr1! {
            arr.append(i.int!)
        }
        
        return arr
    }

}

