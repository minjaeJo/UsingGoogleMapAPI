# UsingGoogleMapAPI

## 목차
- setting
- GoogleMap API 다루기전 설정해줘야 할 부분
- MapViewController 코드 설명
  - CocoaPod으로 쓴 라이브러리
  - 전역 프로퍼티
  - CLLocation & CLLocationManager
  - viewDidLoad
  - Part - Delegate : GMSMapViewDelegate
  - Part - Method : 맵에 마커 생성하는 기능
  - Part - Method : 내 주위 700미터 안의 카페 탐색
  - Part - Method : 마커 뿌리기
- 소감
  - googleMaps API 쓰면서 힘들거나 막혔던 점



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
        self.googleMap.camera = camera
        self.googleMap.delegate = self
        self.googleMap?.isMyLocationEnabled = true
        self.googleMap.settings.myLocationButton = true
        self.googleMap.settings.zoomGestures = true
    }
```

 - `locationManager.requestWhenInUseAuthorization()` - 앱을 사용하는 동안, 사용할 위치 서비스를 허락을 요청
 - `locationManager.startUpdatingHeading()` - 유저의 현재 위치를 업데이트한 정보를 시작
 - `locationManager.desiredAccuracy = kCLLocationAccuracyBest` - 위치의 정확성 high-level로 설정
 - `locationManager.startMonitoringSignificantLocationChanges()` - 중요한 위치 변화를 기초로 하여 업데이트 정보를 시작

 - `self.googleMap.camera = GMSCameraPosition.camera(~~)` - 맵의 시점을 표시
 - `self.googleMap?.isMyLocationEnabled` - 현재 위치 사용 가능 여부
 - `self.googleMap.settings.myLocationButton` - 현재위치 버튼 생성
 - `self.googleMap.settings.zoomGestures` - 줌 제스쳐

### Part - Delegate : GMSMapViewDelegate
```Swift
func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
    googleMap.isMyLocationEnabled = true
}

func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
    googleMap.clear()

    searchCafeAroundMe(latitude: coordinate.latitude, longtitude: coordinate.longitude) { (cafeInfoArray) in
        self.spreadMarker(cafeInfoArray: cafeInfoArray)
    }
}

func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
    cafeName.text = marker.title
    cafeAddress.text = marker.snippet
    return true
}
```

 -  `func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition)` - 제스쳐가 끝나거나 애니메이션이 완료된 직후, 맵이 idle(아무것도 안하고 있는 상태)일때 이 메소드를 호출한다.

- `func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D)` - 특정 좌표에 클릭할때마다 이 메소드를 부른다.(단, 마커를 클릭한 경우는 취급하지 않는다) => 이 메소드에서 좌표찍을때마다 그 좌표를 중심으로 700미터 반경안의 카페를 탐색하는 searchCafeAroundMe 메소드를 비동기 호출한다.

- `func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool` - 마커를 클릭할때마다 카페이름과 카페주소에 값들을 넘겨준다.

### Part - Method : 맵에 마커 생성하는 기능

```Swift

func createMarker(titleMarker : String, snippetMarker : String, iconMarker: UIImage, latitude : CLLocationDegrees, longitude : CLLocationDegrees) {
    let marker = GMSMarker()
    marker.position = CLLocationCoordinate2DMake(latitude, longitude)
    marker.title = titleMarker
    marker.snippet = snippetMarker
    marker.icon = iconMarker
    marker.map = googleMap
}

```

-  기본적으로 GMSMarker는 추상클래스인 GMSOverLayout을 상속받아 만들어진 마커의 클래스이다. 위 메소드는 정해진 파라미터(마커이름, 마커상세정보, 아이콘, 위도, 경도)를 가지고 마커를 만드는 역할을 담당하는 메소드이다.

### Part - Method : 내 주위 700미터 안의 카페 탐색
```Swift

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

```

- searchCafeAroundMe함수는 내 주변 700미터 반경의 카페를 GooglePlaces API로 장소검색한 결과들을 cafeInfoArray에 담는 역할을 하는 메소드이다.


### Part - Method : 마커 뿌리기
```Swift

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

```

- spreadMarker함수는 파라미터에 들어온 아규먼트의 배열을 루프를 돌린다. 그리고 각각의 카페정보를 createMarker의 파라미터들에게 아규먼트를 넘겨줘서 마커를 만들어 화면에 뿌려주는 역할을 담당하는 메소드이다.

## 소감
### googleMaps API 쓰면서 힘들거나 막혔던 점
**4/17 ~ 4/18** : 이 기간은 오로지 가이드만 따라하는 시간을 가짐. 힘들었던 점은 문서에 대해 이해하고 따라하는데 시간이 많이 걸렸던 것 같음.

**4/19** : 내가 원하는 방향으로 뷰를 커스텀 하는 방법에 대해 고민하는 시간을 많이 가짐. 가이드중 `let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)`를 super view위에 올려 맵을 띄우는 예제가 있음. 나는 예제와 다르게 oulet으로 연결해서 처리하고 싶었음. 하지만... 그 길을 험난했음... 여기서 많은 시간을 삽질함.

=> 해결했던 방법 : view를 main.storyboard에 올리고 UIView입력하는 곳에 GMSMapView 타입으로 지정하고 아울렛 연결하여 해결

**4/20** : 실행할때마다 AppDelegate에서 app crash나는 부분을 고친다고 하루를 다날렸음...

=> 해결했던 방법 : app bulid setting에서 Linking - Debug에서 ObejC로 바꾸니 해결됨.. 아직도 정확한 원인을 모르겠음.

**4/21** : Alamofire과 SwiftyJSON을 익혀서 직접 사용하는 학습시간이 조금 있었음.
1. 정체되었던 부분은 `func convertToAddress(latitude : CLLocationDegrees, longtitude: CLLocationDegrees, completion : @escaping (String) -> Void) `에서 api에 받아온 json을 처리하는 부분임. 애매하게.. 잘 안되던 부분이였음.

2. Alamofire는 기본적으로 비동기처리 방식임. 그렇다보니 리턴값으로 넘기는게 힘들었음

=> 해결했던 방법: 1. 디버깅 툴을 이용해서 받아온 값들 하나하나 뜯어가며 공책으로 품 2. 구제이 도움으로 completion : (String) -> Void 을 이용해 해결함. 기본적으로 비동기방식이라 이런 식으로 접근 해야한다고 함.
