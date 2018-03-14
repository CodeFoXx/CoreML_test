//
//  MapViewController.swift
//  htb
//
//  Created Осина П.М. on 26.02.18.
//  Copyright © 2018 htb. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var presenter: MapPresenter!
    let regionRadius: CLLocationDistance = 1000
    var artWorks: [Artwork] = []
    let locationManager = CLLocationManager()
    var previousAnnotation = MKPointAnnotation()
    var currentPlaceMark: CLPlacemark?


    @IBAction func showDirection(_ sender: Any) {
        
        mapView.removeOverlays(mapView.overlays)
        guard let currentPlacemark = currentPlaceMark else{
            return
        }
        
        let directionRequest = MKDirectionsRequest()
        let destinationPlacemark = MKPlacemark(placemark: currentPlaceMark!)
        
        directionRequest.source = MKMapItem.forCurrentLocation()
        
        directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
        directionRequest.transportType = .automobile
        
        //calculate the route
        let directions = MKDirections(request: directionRequest)
        directions.calculate{ (directionResponse, error) in
            guard let directionResponse = directionResponse else{
                if let error = error {
                    print("error getting directions: \(error.localizedDescription)")
                }
                return
            }
            
            let route = directionResponse.routes[0]
            self.mapView.add(route.polyline, level: .aboveRoads)
        }
    }
    
    @IBAction func pinPress(_ sender: UILongPressGestureRecognizer) {
    
        let location = sender.location(in: mapView)
        let locCord = self.mapView.convert(location, toCoordinateFrom: self.mapView)

        let annotation = MKPointAnnotation()
        
        annotation.coordinate = locCord
        annotation.title = "Destination"
        annotation.subtitle = "Location of Destination"
        let a = Artwork(title: "Destination", locationName: "Destination", discipline: "Destination", coordinate: locCord)
        artWorks.append(a)
        self.mapView.removeAnnotations(mapView.annotations)
        self.mapView.removeOverlays(mapView.overlays)
        self.mapView.addAnnotation(artWorks[artWorks.count-1])
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        previousAnnotation.title = "null"
        
        mapView.delegate = self
        
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.showsTraffic = true
        mapView.showsPointsOfInterest = true
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.stopUpdatingLocation()
        
        mapView.isZoomEnabled = true
        if #available(iOS 11.0, *) {
            mapView.register(ArtworkMarkerView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        } else {
            // Fallback on earlier versions
        }
        locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled(){
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            //locationManager.requestLocation()
        }
        loadInitialData()
        mapView.addAnnotations(artWorks)
        
    }
    
    func loadInitialData(){
        guard let fileName = Bundle.main.path(forResource: "PublicArt", ofType: "json")
            else { return }
        let optionalData = try? Data(contentsOf: URL(fileURLWithPath: fileName))
        
        guard
            let data = optionalData,
            let json = try? JSONSerialization.jsonObject(with: data),
            let dictionary = json as? [String: Any],
            let works = dictionary["data"] as? [[Any]]
            else { return }
        
        let validWorks = works.flatMap{ Artwork(json: $0)}
        artWorks.append(contentsOf: validWorks)
    }
    
    func centerMapOnLocation(location: CLLocation){
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func drawRoute(sourceLocation: CLLocationCoordinate2D, destinationLocation: CLLocationCoordinate2D){
        
        //let sourceLocation = CLLocationCoordinate2D(latitude: 40.759011, longitude: -73.984472)
        //let destinationLocation = CLLocationCoordinate2D(latitude: 40.748441, longitude: -73.98556)
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.title = "Times Square"
        
        if let location = sourcePlacemark.location{
            sourceAnnotation.coordinate = location.coordinate
        }
        
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.title = "Empire State Building"
        
        if let location = destinationPlacemark.location{
            destinationAnnotation.coordinate = location.coordinate
        }
        
        self.mapView.showAnnotations([sourceAnnotation, destinationAnnotation], animated: true)
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .any
        
        
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate{
            (response, error) -> Void in
            guard let response = response else{
                if let error = error{
                    print("Error: \(error)")
                }
                return
            }
            let route = response.routes[0]
            self.mapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        }
    }
    
}

extension MapViewController: MapView, MKMapViewDelegate {
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        
//        guard let annotaion = annotation as? Artwork else { return nil }
//        
//        let identifier = "marker"
//        if #available(iOS 11.0, *) {
//            var view: MKMarkerAnnotationView
//            if let daqueuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
//                as? MKMarkerAnnotationView{
//                daqueuedView.annotation = annotation
//                view = daqueuedView
//            }
//            else{
//                view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//                view.canShowCallout = true
//                view.calloutOffset = CGPoint(x: -5, y: 5)
//                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//            }
//            return view
//        } else {
//            // Fallback on earlier versions
//            return nil
//        }
//    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! Artwork
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMaps(launchOptions: launchOptions)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 3.0
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let location = view.annotation as? Artwork{
            self.currentPlaceMark = MKPlacemark(coordinate: location.coordinate)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[0]
        
        let center = location.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
        
        mapView.showsUserLocation = true
    }
    
}
