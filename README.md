# UsingGoogleMapAPI

## Setting
1. cd UsingGoogleMapAPI
2. pod install

## GoogleMap API 다루기전 설정해줘야 할 부분

- AppDelegate.swift

구글에서 받은 API Key값을 등록

```Swift
import GoogleMaps
import GooglePlaces

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    GMSServices.provideAPIKey(googleAPIKey)
    GMSPlacesClient.provideAPIKey(googleAPIKey)
    return true
}
```

- Info.Plist

위치 동의 및 필요한 LSApplicationQueriesSchemes 설정

```Swift
<plist version="1.0">
<dict>
  <key>LSApplicationQueriesSchemes</key>
  <array>
      <string>googlechromes</string>
      <string>comgooglemaps</string>
  </array>
  <key>NSLocationWhenInUseUsageDescription</key>
  <string>Allow location</string>
</dict>
</plist>
```
## 코드 설명
### CocoaPod으로 쓴 라이브러리
- GoogleMaps - iOS 앱에 Google 지도를 추가하는 라이브러리

- GooglePlaces - 앱에 기기의 위치를 인식하거나 자동완성 기능을 구현하고, 수백만 곳 이상의 장소에 대한 정보를 추가하는 라이브러리

- Alamofire -  HTTP 네트워킹 라이브러리
- SwiftyJSON - JSON데이터 쉽게 처리하게 도와주는 라이브러리

### 프로퍼티
`@IBOutlet weak var goolgleMap: GMSMapView!` - UIView에 googleMapView타입으로 지정하여 Outlet으로 연결
`var locationManager = CLLocationManager()` - locationManager를 전역변수로 설정

#### CLLocation & CLLocationManager
CLLocation - 시스템으로부터 보고되는 위치(위도, 경도 그리고 코스)의 정보를 담는 데이터 오브젝트

CLLocationManager - 앱에 위치 관련 이벤트 전달을 구성하기위한 중심 클래스

 - Tracking large or small changes in the user’s current location with a configurable degree of accuracy.

 - Reporting heading changes from the onboard compass. (iOS only)

 - Monitoring distinct regions of interest and generating location events when the user enters or leaves those regions.

 - Deferring the delivery of location updates while the app is in the background. (iOS only)

 - Reporting the range to nearby beacons.

### viewDidLoad
```swift

override func viewDidLoad() {
        super.viewDidLoad()
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
```

 - `locationManager.requestWhenInUseAuthorization()` - 앱을 사용하는 동안, 사용할 위치 서비스를 허락을 요청
 - `locationManager.startUpdatingHeading()` - 유저의 현재 위치를 업데이트한 정보를 시작
 - `locationManager.desiredAccuracy = kCLLocationAccuracyBest` - 위치의 정확성 high-level로 설정
 - `locationManager.startMonitoringSignificantLocationChanges()` - 중요한 위치 변화를 기초로 하여 업데이트 정보를 시작

 - `self.goolgleMap.camera = GMSCameraPosition.camera(~~)` - 맵의 시점을 표시
 - `self.goolgleMap?.isMyLocationEnabled` - 현재 위치 사용 가능 여부
 - `self.goolgleMap.settings.myLocationButton` - 현재위치 버튼 생성
 - `self.goolgleMap.settings.zoomGestures` - 줌 제스쳐

 
