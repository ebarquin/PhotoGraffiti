//
//  Graffiti.swift
//  Graffiti
//
//  Created by Eugenio Barquín on 17/6/17.
//  Copyright © 2017 Eugenio Barquín. All rights reserved.
//

import UIKit
import MapKit

class Graffiti: NSObject, NSCoding {
    
    let graffitiAddress: String
    let graffitiLatitude : Double
    let graffitiLongitude : Double
    let graffitiImageName: String
    
    
    init(address: String, latitude: Double, longitude: Double, image: String) {
        self.graffitiAddress = address
        self.graffitiLongitude = longitude
        self.graffitiLatitude = latitude
        self.graffitiImageName = image
    }
    
    //MARK: NSCoding
    required convenience init? (coder aDecoder: NSCoder) {
        let graffitiAddress = aDecoder.decodeObject(forKey: "graffitiAddress") as! String
        let graffitiLatitude = aDecoder.decodeDouble(forKey: "graffitiLatitude")
        let graffitiLongitude = aDecoder.decodeDouble(forKey: "graffitiLongitude")
        let graffitiImageName = aDecoder.decodeObject(forKey: "graffitiImageName") as! String
        
        self.init(address:graffitiAddress, latitude: graffitiLatitude, longitude: graffitiLongitude, image: graffitiImageName)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.graffitiAddress, forKey: "graffitiAddress")
        aCoder.encode(self.graffitiLongitude, forKey: "graffitiLongitude")
        aCoder.encode(self.graffitiLatitude, forKey: "graffitiLatitude")
        aCoder.encode(self.graffitiImageName, forKey: "graffitiImageName")
        
    }
}
extension Graffiti: MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: graffitiLatitude, longitude: graffitiLongitude)
        }
    }
    var title: String? {
        get {
            return "Graffiti"
        }
        
    }
    
    var subtitle: String? {
        get{
            return graffitiAddress.replacingOccurrences(of: "\n", with: "")
    
        }
    }
}
