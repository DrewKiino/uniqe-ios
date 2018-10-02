/*-----------------------------------
 
 - UNQ -
 
 created by Christian Noble © 2017
 All Rights reserved to UNQ
 
 -----------------------------------*/


import UIKit
import MapKit
import CoreLocation


class DistanceMap: UIViewController,
MKMapViewDelegate,
UITextFieldDelegate,
CLLocationManagerDelegate
{

    /* Views */
    @IBOutlet weak var aMap: MKMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceSlider: UISlider!
    
    @IBOutlet weak var locationTxt: UITextField!
    
    
    
    
    /* Variables */
    var distance = Double()
    var location = CLLocation()
    var locationManager: CLLocationManager!

    
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinView:MKPinAnnotationView!
    var region: MKCoordinateRegion!
    
    
    
    
override func viewDidLoad() {
        super.viewDidLoad()

    // Set initial variables
    let distFormatted = String(format: "%.0f", distance)
    distanceLabel.text = "\(distFormatted) miles around your location"
    distanceSlider.value = Float(distance)
    
    
    // Add a pin on the Map
    addPinOnMap(location)
}


    
    
    
// MARK: - SEARCH FOR A LOCATION BY ADDRESS OR CITY
func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField.text != "" {
        let address = textField.text!
        textField.resignFirstResponder()
        print(address)

        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address, completionHandler: { (placemarks, error) in
                if let placemark = placemarks?.first {
                    let coords = placemark.location!.coordinate
                
                    self.location = CLLocation(latitude: coords.latitude, longitude: coords.longitude)
                    self.addPinOnMap(self.location)
                    
            } else {
                self.simpleAlert("Location not found. Try a new search.")
            }
        })
    }
return true
}

    
    
    
// MARK: - GET CURRENT LOCATION BUTTON
@IBAction func currentLocationButt(_ sender: Any) {
    // Init LocationManager
    locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    if locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)) {
        locationManager.requestAlwaysAuthorization()
    }
    locationManager.startUpdatingLocation()
}
    
   
    
// MARK: - CORE LOCATION DELEGATES
func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    simpleAlert("We coulnd't get your location. Please go into Settings, search for UNQ and enable Location service, so you'll be able to see ads nearby you.")
        
    // Set New York City as default currentLocation
    location = CLLocation(latitude: 40.7143528, longitude: -74.0059731)
    chosenLocation = nil
    
    // Add pin on the map
    addPinOnMap(location)
}
    
func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    locationManager.stopUpdatingLocation()
        
    location = locations.last!
    
    locationManager = nil
    chosenLocation = nil
    
    // Add pin on the map
    addPinOnMap(location)
}

    
    
    
    
// MARK: - ADD A PIN ON THE MAPVIEW
func addPinOnMap(_ location: CLLocation) {
    aMap.delegate = self
    aMap.removeOverlays(aMap.overlays)
    
    if aMap.annotations.count != 0 {
        annotation = aMap.annotations[0]
        aMap.removeAnnotation(annotation)
    }
    
    // Add PointAnnonation text and a Pin to the Map
    pointAnnotation = MKPointAnnotation()
    pointAnnotation.coordinate = CLLocationCoordinate2D( latitude: location.coordinate.latitude, longitude:location.coordinate.longitude)
    pinView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
    aMap.centerCoordinate = pointAnnotation.coordinate
    aMap.addAnnotation(pinView.annotation!)
            
    // Zoom the Map to the location
    region = MKCoordinateRegionMakeWithDistance(self.pointAnnotation.coordinate, distance*4000, distance*4000);
    aMap.setRegion(region, animated: true)
    aMap.regionThatFits(region)
    aMap.reloadInputViews()
    
    
    // Add circle
    addRadiusCircle(location)
}
    
    
    
    
// MARK: - ADD A RED CIRCLE AROUND THE AREA
func addRadiusCircle(_ location: CLLocation) {
    let circle = MKCircle(center: location.coordinate, radius: distance*1609 as CLLocationDistance)
    aMap.add(circle)
}
    
func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    if overlay is MKCircle {
        let circle = MKCircleRenderer(overlay: overlay)
        circle.strokeColor = UIColor.red
        circle.fillColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.1)
        circle.lineWidth = 1
        return circle
    }
    
return MKOverlayRenderer()
}
    
    
    
    
// MARK: - CUSTOMIZE PIN ANNOTATION
func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    if annotation.isKind(of: MKPointAnnotation.self) {
            
        // Try to dequeue an existing pin view first.
        let reuseID = "CustomPinAnnotationView"
        var annotView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
            
        if annotView == nil {
            annotView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            annotView!.canShowCallout = true
                
            // Custom Pin image
            let imageView = UIImageView(frame: CGRect(x:0, y:0, width:44, height: 44))
            imageView.image =  UIImage(named: "curr_loc_icon")
            imageView.center = annotView!.center
            imageView.contentMode = .scaleAspectFill
            annotView!.addSubview(imageView)
                
        }
        return annotView
    }
        
return nil
}
    
    

   
// MARK: - DISTANCE SLIDER CHANGED
@IBAction func distanceChanged(_ sender: UISlider) {
    distance = Double(sender.value)
    let distFormatted = String(format: "%.0f", distance)
    distanceLabel.text = "\(distFormatted) miles around your location"
}
    
    
// MARK: - SLIDER ENDS DRAGGING
@IBAction func sliderEndDrag(_ sender: UISlider) {
    // Refresh the MapView
    addPinOnMap(location)
}
    
    
// MARK: - APPLY DISTANCE BUTTON
@IBAction func applyButt(_ sender: Any) {
    chosenLocation = location
    distanceInMiles = distance
    dismiss(animated: true, completion: nil)
}
    
    
    
// MARK: - DISMISS BUTTON
@IBAction func dismissButt(_ sender: Any) {
    dismiss(animated: true, completion: nil)
}
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
