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
    @IBOutlet weak var cafeAddress: UILabel!
    @IBOutlet weak var cafeName: UILabel!
    @IBOutlet weak var cafePicture: UIImageView!
    
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

    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        googleMap.isMyLocationEnabled = true
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        googleMap.clear()

//        searchCafeAroundMe(latitude: coordinate.latitude, longtitude: coordinate.longitude) { (cafeInfoArray) in
//                spreadMarker(cafeInfo: cafeInfoArray)
//        }
    }
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print("yo~")
        return true
    }


    // 내 주위 700미터 안의 카페 탐색
    func searchCafeAroundMe (latitude : CLLocationDegrees, longtitude: CLLocationDegrees, completion : @escaping ([[String : Any]]) -> Void) {
        
        var cafeInfo = [String : Any]()
        var cafeInfoArray = [[String : Any]]()
        
        let aroundMeURL = "https://maps.googleapis.com/maps/api/place/radarsearch/json?location=\(latitude),\(longtitude)&radius=700&type=cafe&key=AIzaSyD2McX3Ev3I5C-ZT-l8EsbVO9YMFcsjfcQ"
    
        Alamofire.request(aroundMeURL).responseJSON { responds in
            let json = JSON(data: responds.data!)
            let results = json["results"].arrayValue
            
            for result in results {
                let geometry = result["geometry"].dictionaryValue
                let location = geometry["location"]?.dictionary
                let cafeLatitude = location?["lat"]?.doubleValue
                let cafeLongtitude = location?["lng"]?.doubleValue
                let cafeInfoID = result["place_id"].stringValue
                
                cafeInfo["cafeLatitude"] = cafeLatitude
                cafeInfo["cafeLongtitude"] = cafeLongtitude
                cafeInfo["cafeInfoID"] = cafeInfoID
                cafeInfoArray.append(cafeInfo)
            }
        }
        completion(cafeInfoArray)
    }
    
    func spreadMarker (cafeInfo : [[String : Any]]) {
        
        for  in cafeInfo {
            
        }
    }
    //self.createMarker(titleMarker: "카페", iconMarker: #imageLiteral(resourceName: "startPin") , latitude: cafeLatitude!, longitude: cafeLongtitude!)
    //            let cafeURL = "https://maps.googleapis.com/maps/api/place/details/json?placeid=ChIJoxjnPvSnfDURgtAkn8HmE_8&language=ko&key=AIzaSyD2McX3Ev3I5C-ZT-l8EsbVO9YMFcsjfcQ"
    //
    //            Alamofire.request(cafeURL).responseJSON { responds in
    //                let json = JSON(data: responds.data!)
    //                let result = json["result"].dictionary
    //                let address = result?["formatted_address"]?.stringValue
    //                let name = result?["name"]?.stringValue
    //
    //                self.cafeAddress.text = address
    //                self.cafeName.text = name
    //
    //            }
}



