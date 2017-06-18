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
    
    var selectedCallaoutImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GraffitiManager.shared4Instance.load()
        
        let image = UIImage(named: "img_navbar_title")
        self.navigationItem.titleView = UIImageView(image: image)
        
        updatingLocation = false
    }
    override func viewWillAppear(_ animated: Bool) {
        mapView.delegate = self
        mapView.addAnnotations(GraffitiManager.shared4Instance.graffitis)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TagGraffiti" {
            let navigationController = segue.destination as! UINavigationController
            let detailsViewController = navigationController.topViewController as! GraffitiDetailsViewController
            detailsViewController.taggedGraffiti = self.graffiti
            detailsViewController.delegate = self
        }
        if segue.identifier == "showPinImage" {
            let navigationController = segue.destination as! UINavigationController
            let graffitiImageViewController = navigationController.topViewController as! GraffitiImageViewController
            graffitiImageViewController.selectedCallout = selectedCallaoutImage
            
        }
        
    }

}
extension CurrentLocationViewController: GraffitiDetailsViewControllerDelegate {
    func graffitiDidFinishGetTagged(sender: GraffitiDetailsViewController, taggedGraffiti: Graffiti) {
        GraffitiManager.shared4Instance.graffitis.append(taggedGraffiti)
        GraffitiManager.shared4Instance.save()
        
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

extension CurrentLocationViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "graffitiPin")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "graffitiPin")
        } else {
            annotationView?.annotation = annotation
        }
        if let place = annotation as? Graffiti {
            let imageName = place.graffitiImageName
            if let imagesURL = GraffitiManager.shared4Instance.imagesURL() {
                let imageData = try! Data(contentsOf: imagesURL.appendingPathComponent(imageName))
                selectedCallaoutImage = UIImage(data:imageData)
                let image = resizeImage(image: selectedCallaoutImage!, newWidth: 40.0)
                let btnImageView = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
                btnImageView.setImage(image, for: .normal)
                annotationView?.leftCalloutAccessoryView = btnImageView
                annotationView?.image = UIImage(named: "img_pin")
                annotationView?.canShowCallout = true
            }
            
            
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.leftCalloutAccessoryView {
            performSegue(withIdentifier: "showPinImage", sender: view)
        }
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

