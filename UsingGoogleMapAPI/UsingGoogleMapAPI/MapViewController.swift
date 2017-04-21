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

class ViewController: UIViewController, GMSMapViewDelegate,CLLocationManagerDelegate {

    @IBOutlet weak var goolgleMap: GMSMapView!

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
        self.goolgleMap.camera = camera
        self.goolgleMap.delegate = self
        self.goolgleMap?.isMyLocationEnabled = true
        self.goolgleMap.settings.myLocationButton = true
        self.goolgleMap.settings.zoomGestures = true
    }


}

