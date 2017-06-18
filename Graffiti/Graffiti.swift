//
//  Graffiti.swift
//  Graffiti
//
//  Created by Eugenio Barquín on 17/6/17.
//  Copyright © 2017 Eugenio Barquín. All rights reserved.
//

import UIKit

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
