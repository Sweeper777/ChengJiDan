import UIKit
import SwiftyUtils

class GeoJSONMapView : UIView {
    var featureCollection: MapFeatureCollection? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        UIColor.label.setStroke()
        guard let featureCollection = self.featureCollection else { return }
        let features = featureCollection.features
        for feature in features {
            print("Drawing \(feature.properties!.name)")
            guard let multipolygon = feature.geometry?.coordinates else { continue }
            let multiPolygonPath = UIBezierPath()
            for polygon in multipolygon {
                let firstLinearRing = polygon.first!
                for (index, position) in firstLinearRing.enumerated() {
                    if index == 0 {
                        multiPolygonPath.move(to: project(long: position.longitude, lat: position.latitude))
                    } else {
                        multiPolygonPath.addLine(to: project(long: position.longitude, lat: position.latitude))
                    }
                }
                multiPolygonPath.close()
            }
            multiPolygonPath.lineWidth = 0.3
            multiPolygonPath.stroke()
        }
    }
    
    func project(long: Double, lat: Double) -> CGPoint {
        let projectedLong = ((long - 73.5) / 61.25).f * width
        let projectedLat = (1 - ((mercator(lat) - 0.1548) / 0.9582).f) * height
        return CGPoint(x: projectedLong, y: projectedLat)
    }
    
    func mercator(_ lat: Double) -> Double {
        asinh(tan(lat * .pi / 180))
    }
}
