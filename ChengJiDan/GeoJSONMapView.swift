import UIKit
import SwiftyUtils

class GeoJSONMapView : UIView {
    var featureCollection: MapFeatureCollection? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var lowestLongitude: Double = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    var longitudeRange: Double = 180 {
        didSet {
            setNeedsDisplay()
        }
    }
    var lowestLatitudeMercator: Double = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    var latitudeRangeMercator: Double = 3 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var colorDict: [String: UIColor] = [:] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    func drawMap(borderColor: UIColor, frame: CGRect) {
        func transformProjectedPoint(_ point: CGPoint) -> CGPoint {
            point
                .applying(CGAffineTransform(scaleX: frame.width, y: frame.height))
                .applying(CGAffineTransform(translationX: frame.x, y: frame.y))
        }
        
        borderColor.setStroke()
        guard let featureCollection = self.featureCollection else { return }
        let features = featureCollection.features
        for feature in features {
            guard let multipolygon = feature.geometry?.coordinates else { continue }
            let multiPolygonPath = UIBezierPath()
            (colorDict[feature.properties?.name ?? ""] ?? .clear).setFill()
            for polygon in multipolygon {
                let firstLinearRing = polygon.first!
                for (index, position) in firstLinearRing.enumerated() {
                    if index == 0 {
                        multiPolygonPath.move(to:
                            transformProjectedPoint(project(long: position.longitude, lat: position.latitude))
                        )
                    } else {
                        multiPolygonPath.addLine(to:
                            transformProjectedPoint(project(long: position.longitude, lat: position.latitude))
                        )
                    }
                }
                multiPolygonPath.close()
            }
            multiPolygonPath.lineWidth = 0.3
            multiPolygonPath.stroke()
            multiPolygonPath.fill()
        }
    }
    
    override func draw(_ rect: CGRect) {
        drawMap(borderColor: .label, frame: bounds)
    }
    
    func project(long: Double, lat: Double) -> CGPoint {
        let projectedLong = ((long - lowestLongitude) / longitudeRange).f
        let projectedLat = (1 - ((mercator(lat) - lowestLatitudeMercator) / latitudeRangeMercator).f)
        return CGPoint(x: projectedLong, y: projectedLat)
    }
    
    func mercator(_ lat: Double) -> Double {
        asinh(tan(lat * .pi / 180))
    }
}
