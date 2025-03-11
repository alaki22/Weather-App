//
//  City+CoreDataProperties.swift
//  WeatherApp
//
//  Created by Ani Lakirbaia on 23.02.25.
//
//

import Foundation
import CoreData


extension City {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<City> {
        return NSFetchRequest<City>(entityName: "City")
    }

    @NSManaged public var name: String?

}

extension City : Identifiable {

}
