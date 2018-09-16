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
import Hashtags

var cellsPerRow:CGFloat = 3
let cellPadding:CGFloat = 5

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    //MARK: - Global Variables
    @IBOutlet var collectionView: UICollectionView!
    
    var flag : Bool = false
    let URL_REQUEST = "https://api.themoviedb.org/3/discover/movie?api_key=fd8ca0808223a0ca5f2b775a8237c9d9&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page="
    let APP_KEY = "fd8ca0808223a0ca5f2b775a8237c9d9"
    var movies : [NSManagedObject] = []
    var page = 1
    var currentIndex : Int = 0
    var conntectionIssuesFlag : Bool = false
    var width : CGFloat = 0.0
    
    override func viewWillLayoutSubviews() {
        if view.frame.size.width < view.frame.size.height {
            width = (view.frame.size.width - 30) / 2
        } else {
            width = (view.frame.size.width - 60) / 4
        }
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: 255)
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.show()
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: 255)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
            self.retreiveData()
            self.getMovieData(url: self.URL_REQUEST, page: self.page)
            SVProgressHUD.dismiss()
        }
    }
    
    //MARK: - Alerts
    func reloadAlert() {
        
        let alert = UIAlertController(title: "Connection Issues", message: "Oops! Check your internet connection, and retry.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.default, handler: { action in
            self.reloadMovieData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Scroll down and up cases methods
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height {
            if !flag {
                updateMovieData()
            }
        }
        if offsetY < 0 {
            if !flag {
                reloadMovieData()
            }
        }
    }
    
    //TODO: Reload all the data from the first page
    func reloadMovieData() {
        flag = true
        print("reload data")
        SVProgressHUD.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.page = 1
            self.getMovieData(url: self.URL_REQUEST, page: self.page)
            //self.retreiveData()
            self.collectionView.reloadData()
        }
        self.flag = false
        SVProgressHUD.dismiss()
    }
    
    
    @IBAction func reloadDataButtonPressed(_ sender: Any) {
        reloadMovieData()
    }
    
    
    //TODO: Load the next page of movies
    func updateMovieData() {
        flag = true
        print("updating data")
        SVProgressHUD.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if self.page <= 5 {
                self.page += 1
                self.getMovieData(url: self.URL_REQUEST, page: self.page)
                self.collectionView.reloadData()
            }
            self.flag = false
            SVProgressHUD.dismiss()
        }
    }
    
    
    //MARK: - Collection View methods
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentIndex = indexPath.row
        performSegue(withIdentifier: "segue", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        let img_path = movies[indexPath.row].value(forKeyPath: "poster_path") as! String
        cell.titleLabel.text = movies[indexPath.row].value(forKeyPath: "title") as! String
        cell.ratingLabel.text = "\(movies[indexPath.row].value(forKeyPath: "vote_average") as! Double)/10(\(movies[indexPath.row].value(forKeyPath: "vote_count") as! Double) votes)"
        
        if let img_url = URL(string: "http://image.tmdb.org/t/p/w185/\(img_path)") {
            do {
                //print(img_url)
                let data = try Data(contentsOf: img_url)
                cell.testImage.image = UIImage(data: data)
            } catch let err {
                if flag == false {
                    self.reloadAlert()
                    flag = true
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                        self.flag = false
                    }
                }
                print("Error")
            }
        }
        return cell
    }
    
    
    //MARK: - Segue methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segue" {
            let detailsVC = segue.destination as! MovieDetailsController
            
            detailsVC.titleText = movies[currentIndex].value(forKeyPath: "title") as! String
            detailsVC.ratingText = "\(movies[currentIndex].value(forKeyPath: "vote_average") as! Double)/10"
            detailsVC.votesText = "(\(movies[currentIndex].value(forKeyPath: "vote_count") as! Int64) votes)"
            detailsVC.averageScore = movies[currentIndex].value(forKeyPath: "vote_average") as! Double
            detailsVC.dateText = "\((movies[currentIndex].value(forKeyPath: "release_date") as! String).prefix(4))/\(movies[currentIndex].value(forKeyPath: "origin_country") as! String)"
            detailsVC.overviewText = movies[currentIndex].value(forKeyPath: "overview") as! String
            detailsVC.backgroundImg = movies[currentIndex].value(forKeyPath: "backdrop_path") as! String
            detailsVC.posterImg = movies[currentIndex].value(forKeyPath: "poster_path") as! String
            detailsVC.budget = "Budget: \(movies[currentIndex].value(forKeyPath: "budget") as! Int64)"
            detailsVC.genres = genreIdsToInt(genre_ids: movies[currentIndex].value(forKeyPath: "genre_ids") as! String)
        }
    }
    
    
    //MARK: Adding and retreiving data methods
    
    //TODO: Get movies data from the movie db API
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
                    self.movies.removeAll()
                }
                
                self.saveData(json: movieJSON["results"][])
            }
            else {
                self.reloadAlert()
                print("Connection Issues")
            }
        }
    }
    
    
    //TODO: retreive data from the Core Data Database
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
    
    
    //TODO: save an array of movies to Core Data Database
    func saveData(json: JSON) {
        for i in 0...json.count-1 {
            self.saveMovie(json: json[i])
        }
        extractOriginCountry()
    }
    
    
    //TODO: delete all data from Core Data Database (is being called only in case an app is able to retreive data from API e.g. there is internet connection)
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
    
    //TODO: save a single movie to Core Data Database
    func saveMovie(json: JSON) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        //print(json)
        
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
            collectionView.reloadData()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    //TODO: Send a separate request on each movie's country of origin
    func extractOriginCountry() {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let context =
            appDelegate.persistentContainer.viewContext
        var movie_id = 0
        
        for i in 0...movies.count-1 {
            movie_id = movies[i].value(forKeyPath: "id") as! Int
            //print(movie_id)
            let origin_request = "https://api.themoviedb.org/3/movie/\(movie_id)?api_key=fd8ca0808223a0ca5f2b775a8237c9d9"
            Alamofire.request(origin_request, method : .get).responseJSON {
                response in
                if response.result.isSuccess {
                    let movieDetailsJSON : JSON = JSON(response.result.value!)
                    if movieDetailsJSON["production_countries"][0]["name"].string != nil {
                        self.movies[i].setValue(movieDetailsJSON["production_countries"][0]["name"].string!, forKey: "origin_country")
                        //print(movieDetailsJSON["production_countries"][0]["name"].string!)
                    } else {
                        self.movies[i].setValue("Unknown", forKey: "origin_country")
                    }
                    
                    self.movies[i].setValue(movieDetailsJSON["budget"].int!, forKey: "budget")
                    do {
                        try context.save()
                        //movies.append(movie)
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }
                } else {
                        print("Connection Issues Finding the Movie Origin")
                }
            }
        }
    }
    
    
    //TODO: converts an array of genre ids to string to store in Core Data Database
    func genreIdsToString(genre_ids : [Int]) -> String {
        var str : String = ""
        for i in genre_ids {
            str += String(i) + " "
        }
        
        return str
    }
    
    
    //TODO: converts a string of genre ids to Int array to define the genre
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

