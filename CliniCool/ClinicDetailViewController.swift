//
//  ClinicDetailViewController.swift
//  CliniCool
//
//  Created by Ken Baer on 3/2/16.
//  Copyright © 2016 BaerCode. All rights reserved.
//

import UIKit
import MapKit


class ClinicDetailViewController : UIViewController, MKMapViewDelegate {
    
    var clinic : [String : AnyObject]?
    @IBOutlet weak var clinicName: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    var mapOn: Bool! = false
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        mapButton.backgroundColor = UIColor(red: 64.0/255.0, green: 129.0/255.0, blue: 206.0/255.0, alpha: 1.0)
        mapView.delegate = self

        guard let clinic = clinic else {
            return
        }
        
        let name = clinic["name"] as? String
        clinicName.text = name
        
        guard let location = clinic["location"] as? [String : AnyObject]? else {
            return
        }
        // populate address
        let street = location?["streetName"] as! String
        let city = location?["city"] as! String
        let stateCode = location?["stateCode"] as! String
        let zipCode = location?["postalCode"] as! String
        let line1 = street + "\n"
        let line2 = city + ", " + stateCode + " " + zipCode
        address.text = line1 + line2
        let dist = location?["locationDistance"] as! Float
        distance.text = "Location Distance: \(dist) miles"
        
        // extract geo-coordinates and prepare pin for map
        guard let geoLocation = location?["geoLocation"] else {
            return
        }
        
        if let latitude = geoLocation["latitude"] as? CLLocationDegrees, let longitude = geoLocation["longitude"] as? CLLocationDegrees {
            let centerlocation: CLLocation = CLLocation(latitude: latitude, longitude: longitude)
            let span: MKCoordinateSpan = MKCoordinateSpanMake(0.1, 0.1)
            let coordinateRegion = MKCoordinateRegionMake(centerlocation.coordinate, span)
            self.mapView.setRegion(coordinateRegion, animated: true)
            let pin = MKPointAnnotation()
            let coords:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
            pin.coordinate = coords
            pin.title = name
            pin.subtitle = street
            self.mapView.addAnnotation(pin)
            mapView.showsUserLocation = true;
        }
        
        mapView.isHidden = true
        mapButton.setTitle("Show on Map", for: UIControlState())
        
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "pin"
        var view: MKPinAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKPinAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        }
        else {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = false
        }
        

        return view
    }

    // toggle the map and button text
    @IBAction func toggleMap() {
        
        if mapOn == true {
            mapOn = false
            mapView.isHidden = true
            mapButton.setTitle("Show on Map", for: UIControlState())
        }
        else {
            mapOn = true
            mapView.isHidden = false
            mapButton.setTitle("Hide Map", for: UIControlState())
        }

    }
    
    @IBAction func done() {
        
        self.navigationController?.popViewController(animated: true)         
    }
    
}
