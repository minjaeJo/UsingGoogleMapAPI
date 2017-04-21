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
    
    // CLLocation은 좌표(위도, 경도)를 알려주는 데이터 오브젝트
    var locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        //locationManager - 좌표 알려주는 매니져
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingHeading()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
        
        //googleMapsView - 지도 생성 및 표시
        let camera = GMSCameraPosition.camera(withLatitude: 37.405614, longitude: 127.106064, zoom: 15.0)
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
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        googleMap.isMyLocationEnabled = true
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        convertToAddress(latitude: coordinate.latitude, longtitude: coordinate.longitude) { (address) in
            self.locationLabel.text = address
        }
//        print("coordinate = \(coordinate)")
//        locationLabel.text = "\()"
        //"위도:\(coordinate.latitude), 경도:\(coordinate.longitude)"
    }
    
//    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
//
//    }
    func convertToAddress(latitude : CLLocationDegrees, longtitude: CLLocationDegrees, completion : @escaping (String) -> Void) {
        let url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(latitude),\(longtitude)"
//        var address = ""
        
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
//            address = formattedAddress
        }
    }
}

