//
//  ViewController.swift
//  UsingGoogleMapAPI
//
//  Created by   minjae on 2017. 4. 21..
//  Copyright © 2017년 minjae. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import SwiftyJSON

class MapViewController: UIViewController, GMSMapViewDelegate,CLLocationManagerDelegate {

    @IBOutlet weak var googleMap: GMSMapView!
    @IBOutlet weak var locationLabel: UILabel!
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var placesClient: GMSPlacesClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //locationManager - 좌표 알려주는 매니져
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingHeading()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
        
        //googleMapsView - 지도 생성 및 표시127.106053
        let camera = GMSCameraPosition.camera(withLatitude: 37.404796, longitude: 127.106053, zoom: 15.0)
        self.googleMap.camera = camera
        self.googleMap.delegate = self
        self.googleMap?.isMyLocationEnabled = true
        self.googleMap.settings.myLocationButton = true
        self.googleMap.settings.zoomGestures = true
    }
    
    // Part - Method : 맵에 마커 생성하는 기능
    func createMarker(titleMarker : String, iconMarker: UIImage, latitude : CLLocationDegrees, longitude : CLLocationDegrees) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(latitude, longitude)
        marker.title = titleMarker
        marker.icon = iconMarker
        marker.map = googleMap
    }
    
    // Part - Delegate : Location Manager Delegate
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error to get lotation \(error)")
    }
    
    
    
// Part - Delegate : GMSMapViewDelegate
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        googleMap.isMyLocationEnabled = true
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        convertToAddress(latitude: coordinate.latitude, longtitude: coordinate.longitude) { (address) in
            self.locationLabel.text = address
            print(address)
        }
        around()
    }
    
//    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
//
//    }
    func convertToAddress(latitude : CLLocationDegrees, longtitude: CLLocationDegrees, completion : @escaping (String) -> Void) {
        let url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(latitude),\(longtitude)"
        
        Alamofire.request(url).responseJSON{ responds in
            print(responds.request as Any)
            print(responds.response as Any)
            print(responds.data as Any)
            print(responds.result as Any)
            
            let json = JSON(data: responds.data!)
            let result = json["results"].arrayValue
            let premiseTypeAddress = result[0].dictionary
            let formattedAddress = (premiseTypeAddress?["formatted_address"]?.stringValue)!
            completion(formattedAddress)
        }
    }
    func around () {
        let url = "https://maps.googleapis.com/maps/api/place/radarsearch/json?location=37.404796,127.106053&radius=3000&type=cafe&key=AIzaSyD2McX3Ev3I5C-ZT-l8EsbVO9YMFcsjfcQ"
        Alamofire.request(url).responseJSON { responds in
            print(responds.request as Any)
            print(responds.response as Any)
            print(responds.data as Any)
            print(responds.result as Any)
            let json = JSON(data: responds.data!)
            let results = json["results"].arrayValue
            for result in results {
                let geometry = result["geometry"].dictionaryValue
                let location = geometry["location"]?.dictionary
                let locationLatitude = location?["lat"]?.doubleValue
                let locationLongtitude = location?["lng"]?.doubleValue
                //let place_id = result[""]
//
                self.createMarker(titleMarker: "카페", iconMarker: #imageLiteral(resourceName: "startPin") , latitude: locationLatitude!, longitude: locationLongtitude!)
//                
            }
            
        }
    }
}

