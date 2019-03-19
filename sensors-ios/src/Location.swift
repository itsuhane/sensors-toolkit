import CoreLocation
import UIKit

protocol LocationDelegate : class {
    func locationDidUpdate(timestamp: Double, longitude: Double, latitude: Double, altitude: Double, horizontalAccuracy: Double, verticalAccuracy: Double)
}

class Location: NSObject, CLLocationManagerDelegate {
    weak var delegate: LocationDelegate? = nil
    
    init?(desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyBestForNavigation, distanceFilter: CLLocationDistance = kCLDistanceFilterNone) {
        
        super.init()
        
        guard CLLocationManager.locationServicesEnabled() else {
            return nil
        }
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = desiredAccuracy
        self.locationManager.distanceFilter = distanceFilter
    }
    
    deinit {
        stop()
        self.locationManager.delegate = nil
    }
    
    func start() -> Bool {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            self.locationManager.requestWhenInUseAuthorization()
            fallthrough
        case .restricted, .denied:
            return false
        case .authorizedWhenInUse, .authorizedAlways:
            break
        }
        self.locationManager.startUpdatingLocation()
        return true
    }
    
    func stop() {
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let delegate = self.delegate else {
            return
        }
        for location in locations {
            delegate.locationDidUpdate(timestamp: location.timestamp.timeIntervalSince1970 - Location.systemBootTime,  longitude: location.coordinate.longitude, latitude: location.coordinate.latitude, altitude: location.altitude, horizontalAccuracy: location.horizontalAccuracy, verticalAccuracy: location.verticalAccuracy)
        }
    }
    
    private static let systemBootTime: Double = {
        var now = Date.timeIntervalSinceReferenceDate + Date.timeIntervalBetween1970AndReferenceDate
        var now_ca = CACurrentMediaTime()
        return now - now_ca
    }()
    
    let locationManager = CLLocationManager()
}
