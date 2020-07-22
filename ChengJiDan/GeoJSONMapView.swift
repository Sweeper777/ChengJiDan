import UIKit
import SwiftyUtils

class GeoJSONMapView : UIView {
    var featureCollection: MapFeatureCollection? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    
    func project(long: Double, lat: Double) -> CGPoint {
        let projectedLong = ((long - 73.5) / 61.25).f * width
        let projectedLat = (1 - ((lat - 8.8) / 44.8).f) * height
        return CGPoint(x: projectedLong, y: projectedLat)
    }
}
