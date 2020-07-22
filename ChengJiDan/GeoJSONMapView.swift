import UIKit
import SwiftyUtils

class GeoJSONMapView : UIView {
    var featureCollection: MapFeatureCollection? {
        didSet {
            setNeedsDisplay()
        }
    }
    
}
