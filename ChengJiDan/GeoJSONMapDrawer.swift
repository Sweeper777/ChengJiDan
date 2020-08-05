import UIKit
import SwiftyUtils

class GeoJSONMapDrawer {
    var featureCollection: MapFeatureCollection?
    
    var lowestLongitude: Double = 0
    var longitudeRange: Double = 180
    var lowestLatitudeMercator: Double = 0
    var latitudeRangeMercator: Double = 3
    var colorDict: [String: UIColor] = [:]
    
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
    
    func drawMapImage(borderColor: UIColor, frame: CGRect, on dispatchQueue: DispatchQueue, completion: @escaping (UIImage?) -> Void) {
        dispatchQueue.async { [weak self] in
            guard let `self` = self else {
                completion(nil)
                return
            }
            UIGraphicsBeginImageContext(frame.size)
            self.drawMap(borderColor: borderColor, frame: frame)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            completion(image)
        }
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
