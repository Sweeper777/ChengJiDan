import UIKit
import SwiftyUtils

class SVGView : UIView {
    
    var svgStrings: [String]? {
        didSet {
            setNeedsDisplay()
        }
    }
    
}

