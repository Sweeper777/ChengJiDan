import UIKit
import SwiftyUtils

class SVGView : UIView {
    
    var svgStrings: [String]? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var colorDict: [Int: UIColor] = [:] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard let svg = svgStrings else { return }
        
        if svg.count == 1 {
            guard let path = UIBezierPath(svgString: svg.first!) else {
                print("cannot create path")
                return
            }
            let bounds = path.bounds
            let scaleFactor = min(self.bounds.width / bounds.width, self.bounds.height / bounds.height)
            let scale = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
            let translate = CGAffineTransform(translationX: -x, y: -y)
            path.apply(translate)
            path.apply(scale)
            path.lineWidth = 1
            UIColor.label.setStroke()
            path.stroke()
            (colorDict[0] ?? .clear).setFill()
            path.fill()
            return
        }
        
        for (index, string) in svg.enumerated() {
            guard let path = UIBezierPath(svgString: string) else {
                print("cannot create path")
                continue
            }
            
            path.lineWidth = 1
            UIColor.label.setStroke()
            path.stroke()
            (colorDict[index] ?? .clear).setFill()
            path.fill()
        }
    }
}

