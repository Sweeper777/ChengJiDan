import UIKit
import SwiftyUtils

class SVGView : UIView {
    
    var svgStrings: [String]? {
        didSet {
            guard let svg = svgStrings else { return }
            if svg.count == 1 {
                guard let path = UIBezierPath(svgString: svg.first!) else {
                    print("cannot create path")
                    return
                }
                svgPaths = [path]
            } else {
                let allPaths = svg.compactMap(UIBezierPath.init)
                let allPathsUnion = allPaths.reduce(into: UIBezierPath()) { (union, path) in
                    union.append(path)
                }
                svgPathBounds = allPathsUnion.bounds
                svgPaths = allPaths
            }
            setNeedsDisplay()
        }
    }
    
    var colorDict: [Int: UIColor] = [:] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var labelTexts: [String] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private(set) var svgPaths: [UIBezierPath] = []
    private(set) var svgPathBounds: CGRect = .zero
    
    var whRatio: CGFloat {
        svgPathBounds.width / svgPathBounds.height
    }
    
    override func draw(_ rect: CGRect) {
        draw(inBounds: self.bounds, lineWidth: min(self.width, self.height) / 640, borderColor: .label, labelFontSize: 5)
    }
    
    func draw(inBounds rect: CGRect, lineWidth: CGFloat, borderColor: UIColor, labelFontSize: CGFloat) {
        
        
        if svgPaths.count == 1 {
            let path = UIBezierPath(cgPath: svgPaths.first!.cgPath)
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
        
        
        let scaleFactor = min(rect.width / svgPathBounds.width, rect.height / svgPathBounds.height)
        let scale = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        for (index, p) in svgPaths.enumerated() {
            let path = UIBezierPath(cgPath: p.cgPath)
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
