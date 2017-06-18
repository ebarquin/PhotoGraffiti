//
//  Graffiti.swift
//  Graffiti
//
//  Created by Eugenio Barquín on 17/6/17.
//  Copyright © 2017 Eugenio Barquín. All rights reserved.
//

import UIKit
import MapKit

class Graffiti: NSObject {
    
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
