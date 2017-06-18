//
//  GraffitiManager.swift
//  Graffiti
//
//  Created by Eugenio Barquín on 18/6/17.
//  Copyright © 2017 Eugenio Barquín. All rights reserved.
//

import Foundation

class GraffitiManager {
    static let shared4Instance = GraffitiManager()
    
    var graffitis: [Graffiti] = [Graffiti]()
    
    func save() {
        if let url = databaseURL() {
            NSKeyedArchiver.archiveRootObject(graffitis, toFile: url.path)
        } else {
            print("Error saving data")
        }
    }
    func load() {
        if let url = databaseURL(),
            let savedData = NSKeyedUnarchiver.unarchiveObject(withFile: url.path) as? [Graffiti] {
            graffitis = savedData
        } else {
            print ("Error lodaing data")
        }
    }
    
    func databaseURL() -> URL? {
        if let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let url = URL(fileURLWithPath: documentDirectory)
            return url.appendingPathComponent("graffities.data")
        } else {
            return nil
        }
    }
    
    func imagesURL() -> URL? {
        if let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let url = URL(fileURLWithPath: documentDirectory)
            return url
        } else {
            return nil
        }

    }
}
