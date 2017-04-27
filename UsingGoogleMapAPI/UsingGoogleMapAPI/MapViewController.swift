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
    var placesClient: GMSPlacesClient!
    var currentLocation = [String: Double]()
    var markerLocationInfo : CLLocationCoordinate2D! // 지우기
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //locationManager - 좌표 알려주는 매니져
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingHeading()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
        
        //18.472548,-69.940499
        //37.404796,127.106053
        let camera = GMSCameraPosition.camera(withLatitude: 18.472548, longitude: -69.940499, zoom: 15.0)
        self.googleMap.camera = camera
        self.googleMap.delegate = self
        self.googleMap?.isMyLocationEnabled = true
        self.googleMap.settings.myLocationButton = true
        self.googleMap.settings.zoomGestures = true
    }
    

    // Part - Delegate : GMSMapViewDelegate
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        googleMap.isMyLocationEnabled = true
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        googleMap.clear()
        currentLocation["latitude"] = coordinate.latitude
        currentLocation["longtitude"] = coordinate.longitude
        
        
        searchCafeAroundMe(latitude: coordinate.latitude, longtitude: coordinate.longitude) { (cafeInfoArray) in
            self.spreadMarker(cafeInfoArray: cafeInfoArray)
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        cafeName.text = marker.title
        cafeAddress.text = marker.snippet
        markerLocationInfo = marker.position
        return true
    }
    
    // Part - Method : 맵에 마커 생성하는 기능
    func createMarker(titleMarker : String, snippetMarker : String, iconMarker: UIImage, latitude : CLLocationDegrees, longitude : CLLocationDegrees) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(latitude, longitude)
        marker.title = titleMarker
        marker.snippet = snippetMarker
        marker.icon = iconMarker
        marker.map = googleMap
    }
    
    // Part - Method : 내 주위 700미터 안의 카페 탐색
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
            completion(cafeInfoArray)
        }
    }
    // Part - Method : 마커 뿌리기
    func spreadMarker (cafeInfoArray : [[String : Any]]) {
        for cafeInfo in cafeInfoArray {
            let cafeURL = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(String(describing: cafeInfo["cafeInfoID"]!))&language=ko&key=AIzaSyD2McX3Ev3I5C-ZT-l8EsbVO9YMFcsjfcQ"
            
            Alamofire.request(cafeURL).responseJSON { responds in
                let json = JSON(data: responds.data!)
                let result = json["result"].dictionary
                let address = result?["formatted_address"]?.stringValue
                let name = result?["name"]?.stringValue
                
                self.createMarker(titleMarker: name!, snippetMarker: address!, iconMarker: #imageLiteral(resourceName: "marker") , latitude: cafeInfo["cafeLatitude"]! as! CLLocationDegrees, longitude: cafeInfo["cafeLongtitude"]! as! CLLocationDegrees)
            }
        }
    }
    
    func findRoad (markerLatitude : CLLocationDegrees, markerLongtitude: CLLocationDegrees) {
        let origin = "\(String(describing: currentLocation["latitude"]!)),\(String(describing: currentLocation["longtitude"]!))"
        let destination = "\(markerLatitude),\(markerLongtitude)"
        

        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&key=AIzaSyD2McX3Ev3I5C-ZT-l8EsbVO9YMFcsjfcQ"
        
        Alamofire.request(url).responseJSON{ responds in
            let json = JSON(data: responds.data!)
            print(json)
            let routes = json["routes"].arrayValue
            
            // 출발점과 도착점을 polyline으로 연결하기
            for route in routes {
                let routeOverViewPolyine = route["overview_polyline"].dictionary
                let points = routeOverViewPolyine?["points"]?.stringValue
                let path = GMSPath.init(fromEncodedPath: points!)
                let polyline = GMSPolyline.init(path: path)
                polyline.strokeColor = UIColor.blue
                polyline.strokeWidth = 4
                polyline.map = self.googleMap
            }
        }

    }
    
    @IBAction func findRoadButton(_ sender: Any) {
        findRoad(markerLatitude: markerLocationInfo.latitude, markerLongtitude: markerLocationInfo.longitude)
    }
    
    
}
