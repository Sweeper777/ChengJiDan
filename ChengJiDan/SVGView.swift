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
    
    private(set) var whRatio: CGFloat = 1
    
    override func draw(_ rect: CGRect) {
        draw(inBounds: self.bounds, lineWidth: min(self.width, self.height) / 640, borderColor: .label)
    }
    
    func draw(inBounds rect: CGRect, lineWidth: CGFloat, borderColor: UIColor) {
        guard let svg = svgStrings else { return }
        
        if svg.count == 1 {
            guard let path = UIBezierPath(svgString: svg.first!) else {
                print("cannot create path")
                return
            }
            let bounds = path.bounds
            let scaleFactor = min(rect.width / bounds.width, rect.height / bounds.height)
            let scale = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
            let translate = CGAffineTransform(translationX: -x, y: -y)
            path.apply(translate)
            path.apply(scale)
            path.lineWidth = lineWidth
            borderColor.setStroke()
            path.stroke()
            (colorDict[0] ?? .clear).setFill()
            path.fill()
            return
        }
        
        let allPaths = svg.compactMap(UIBezierPath.init)
        let allPathsUnion = allPaths.reduce(into: UIBezierPath()) { (union, path) in
            union.append(path)
        }
        let bounds = allPathsUnion.bounds
        whRatio = bounds.width / bounds.height
        let scaleFactor = min(rect.width / bounds.width, rect.height / bounds.height)
        let scale = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        for (index, string) in svg.enumerated() {
            guard let path = UIBezierPath(svgString: string) else {
                print("cannot create path")
                continue
            }
            path.apply(scale)
            path.lineJoinStyle = .round
            path.lineWidth = lineWidth
            borderColor.setStroke()
            path.stroke()
            (colorDict[index] ?? .clear).setFill()
            path.fill()
        }
    }
}

