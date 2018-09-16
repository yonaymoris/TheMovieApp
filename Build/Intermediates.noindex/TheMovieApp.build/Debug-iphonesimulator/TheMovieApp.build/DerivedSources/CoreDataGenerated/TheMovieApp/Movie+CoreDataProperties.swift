//
//  Movie+CoreDataProperties.swift
//  
//
//  Created by Phuong Ngo on 9/16/18.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Movie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Movie> {
        return NSFetchRequest<Movie>(entityName: "Movie")
    }

    @NSManaged public var backdrop_path: String?
    @NSManaged public var budget: Int64
    @NSManaged public var genre_ids: String?
    @NSManaged public var id: Int64
    @NSManaged public var origin_country: String?
    @NSManaged public var original_language: String?
    @NSManaged public var original_title: String?
    @NSManaged public var overview: String?
    @NSManaged public var popularity: Double
    @NSManaged public var poster_path: String?
    @NSManaged public var release_date: String?
    @NSManaged public var title: String?
    @NSManaged public var vote_average: Double
    @NSManaged public var vote_count: Int64

}
