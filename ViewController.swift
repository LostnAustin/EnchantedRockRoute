//
//  ViewController.swift
//  eRockRoute
//
//  Created by primaryuser on 12/4/18.
//  Copyright © 2018 Chad Lengefeld. All rights reserved.
//

import UIKit
import Mapbox
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections




    
class ViewController: UIViewController, MGLMapViewDelegate {
    var mapView: NavigationMapView!
    var navigateButton: UIButton!
    var directionsRoute: Route?
    

    
    let enchantedCoordinate = CLLocationCoordinate2D(latitude: 30.5066, longitude: -98.8189)
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = NavigationMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true)
        
        addButton()
    }
    func addButton() {
        navigateButton = UIButton(frame: CGRect(x: (view.frame.width/2) - 100, y: view.frame.height  - 75, width: 200, height: 50))
        
        navigateButton.setTitle("Navigate", for: .normal)
        navigateButton.setTitleColor(UIColor(red: 59/255, green: 178/255, blue: 208/255, alpha: 1), for: .normal)
        navigateButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
        navigateButton.layer.cornerRadius = 25
        navigateButton.layer.shadowOffset = CGSize(width: 0, height: 10)
        navigateButton.backgroundColor = UIColor .blue
        navigateButton.layer.shadowRadius = 5
        navigateButton.layer.shadowOpacity = 0.3
        navigateButton.addTarget(self, action: #selector(navigateButtonWasPressed(_:)), for: .touchUpInside)
        view.addSubview(navigateButton)
    }
    @objc func navigateButtonWasPressed(_ sender: UIButton) {
        mapView.setUserTrackingMode(.none, animated: true)
        
        let annotation = MGLPointAnnotation()
        annotation.coordinate = enchantedCoordinate
        annotation.title = "Start Navigation"
        mapView.addAnnotation(annotation)
        calculatedRoute(from: (mapView.userLocation!.coordinate), to: enchantedCoordinate)  { (route, error)  in
            if error != nil {
                print("Error getting route")
        }
            
        }
    }
    
    
    
    
    
    func calculatedRoute(from originCoor: CLLocationCoordinate2D, to destinationCoor: CLLocationCoordinate2D, completion: @escaping (Route?, Error?) -> Void) {
       
        let origin = Waypoint(coordinate: originCoor, coordinateAccuracy: -1, name: "Start")
        let destination = Waypoint(coordinate: destinationCoor, coordinateAccuracy: -1, name: "Finish")
        
        let options = NavigationRouteOptions(waypoints: [origin, destination], profileIdentifier: .automobileAvoidingTraffic)
        
        _ = Directions.shared.calculate(options, completionHandler: { (waypoints, routes, error) in self.directionsRoute = routes?.first
            //draw the route line
            self.drawRoute(route: self.directionsRoute!)
            
            
            let coordinateBounds = MGLCoordinateBounds(sw:destinationCoor, ne: originCoor )
            let insets = UIEdgeInsets( top: 50, left: 50, bottom: 50, right: 50)
            let routeCam = self.mapView.cameraThatFitsCoordinateBounds(coordinateBounds, edgePadding: insets)
            self.mapView.setCamera(routeCam, animated: true)
        })
    }
    
    func drawRoute(route: Route) {
        guard route.coordinateCount > 0 else { return }
        var routeCoordinates = route.coordinates!
        let polyline = MGLPolylineFeature(coordinates: &routeCoordinates, count: route.coordinateCount)
        
        if let source = mapView.style?.source(withIdentifier: "route-source") as? MGLShapeSource {
            source.shape = polyline
        } else {
           
            let source = MGLShapeSource(identifier: "route-source", features: [polyline], options: nil)
            
            let lineStyle = MGLLineStyleLayer(identifier: "route-style", source: source)
          
            
            mapView.style?.addSource(source)
            mapView.style?.addLayer(lineStyle)
            
        }
    }
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    func mapView(_ mapView: MGLMapView, tapOnCalloutFor annotation: MGLAnnotation) {
        let navigationVC = NavigationViewController(for: directionsRoute!)
        present(navigationVC, animated: true, completion: nil)
    }
}

