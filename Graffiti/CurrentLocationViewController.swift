//
//  CurrenLocationViewController.swift
//  Graffiti
//
//  Created by Eugenio Barquín on 17/6/17.
//  Copyright © 2017 Eugenio Barquín. All rights reserved.
//

import UIKit
import MapKit

class CurrentLocationViewController: UIViewController {
    
    @IBOutlet weak var getButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tagButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var graffiti: Graffiti?
    
    let locationManager = CLLocationManager()
    let geoCoder = CLGeocoder()
    
    var updatingLocation = false  {
        didSet{
            if updatingLocation {
                getButton.setImage(#imageLiteral(resourceName: "btn_localizar_off"), for: .normal)
                activityIndicator.isHidden = false
                activityIndicator.startAnimating()
                getButton.isUserInteractionEnabled = false
            } else {
                getButton.setImage(#imageLiteral(resourceName: "btn_localizar_on"), for: .normal)
                activityIndicator.isHidden = true
                activityIndicator.stopAnimating()
                getButton.isUserInteractionEnabled = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: "img_navbar_title")
        self.navigationItem.titleView = UIImageView(image: image)
        
        updatingLocation = false
    }

    @IBAction func getLocation(_ sender: Any) {
        startLocationManager()
    }
 
    func startLocationManager() {
        let authStatus = CLLocationManager.authorizationStatus()
        switch authStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            showLocationServicesDeniedAlert()
        default:
            if CLLocationManager.locationServicesEnabled() {
                self.updatingLocation = true
                self.tagButton.isEnabled = false
                
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.requestLocation()
                
                //Zoom in in user location
                let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
                mapView.setRegion(mapView.regionThatFits(region), animated: true)
                
                
            }
            
        }
        
    }
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Localización desactivada", message: "Por favor activa la localización para esta aplicación en ajustes", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    func stringFromPlacemark(placemark: CLPlacemark) -> String {
        var line1 = ""
        if let s = placemark.thoroughfare {
            line1  += s + ", "
        }
        if let s = placemark.subThoroughfare {
            line1 += s
        }
        var line2 = ""
        if let s = placemark.postalCode {
            line2 += s + " "
        }
        if let s = placemark.locality {
            line2  += s
        }
        var line3 = ""
        if let s = placemark.administrativeArea {
            line3  += s + " "
        }
        return line1 + "\n" + line2  + "\n" + line3
    }

}

extension CurrentLocationViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("******** Error in Core Location **********")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let newLocation = locations.last else { return }
        
        let latitude = Double(newLocation.coordinate.latitude)
        let longitude = Double(newLocation.coordinate.longitude)
        
        geoCoder.reverseGeocodeLocation(newLocation) { (placemarks, error) in
            if error == nil {
                var address = "Not determined"
                if let placemark = placemarks?.last {
                    address = self.stringFromPlacemark(placemark: placemark)
                }
                self.graffiti = Graffiti(address: address, latitude: latitude, longitude: longitude, image: "")
            }
            self.updatingLocation = false
            self.tagButton.isEnabled = true
        }
    }
    
}

