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
    
    private func size(ofText string: String, fontSize: CGFloat) -> CGSize {
        return NSAttributedString(string: string,
                                  attributes: [.font: UIFont.systemFont(ofSize: fontSize)])
            .boundingRect(with: CGSize(width: 1000, height: 1000), options: [], context: nil).size
    }
    
    private func findFirstRect(path: UIBezierPath, thatFits: CGSize) -> CGRect? {
        let points = path.cgPath.getPathElementsPoints()
        allPoints: for point in points {
            var checkpoint = point
            var size = CGSize(width: 0, height: 0)
            thisPoint: while size.width <= path.bounds.width {
                if path.contains(checkpoint) && path.cgPath.contains(CGRect(origin: checkpoint, size: thatFits)) {
                    return CGRect(x: checkpoint.x, y: checkpoint.y, width: thatFits.width, height: thatFits.height)
                } else {
                    checkpoint.x += 1
                    size.width += 1
                    continue thisPoint
                }
            }
        }
        return nil
    }
}

extension CGPath {
    func forEach( body: @escaping @convention(block) (CGPathElement) -> Void) {
        typealias Body = @convention(block) (CGPathElement) -> Void
        let callback: @convention(c) (UnsafeMutableRawPointer, UnsafePointer<CGPathElement>) -> Void = { (info, element) in
            let body = unsafeBitCast(info, to: Body.self)
            body(element.pointee)
        }
        //print(MemoryLayout.size(ofValue: body))
        let unsafeBody = unsafeBitCast(body, to: UnsafeMutableRawPointer.self)
        self.apply(info: unsafeBody, function: unsafeBitCast(callback, to: CGPathApplierFunction.self))
    }
    func getPathElementsPoints() -> [CGPoint] {
        var arrayPoints : [CGPoint]! = [CGPoint]()
        self.forEach { element in
            switch (element.type) {
            case CGPathElementType.moveToPoint:
                arrayPoints.append(element.points[0])
            case .addLineToPoint:
                arrayPoints.append(element.points[0])
            case .addQuadCurveToPoint:
                arrayPoints.append(element.points[0])
                arrayPoints.append(element.points[1])
            case .addCurveToPoint:
                arrayPoints.append(element.points[0])
                arrayPoints.append(element.points[1])
                arrayPoints.append(element.points[2])
            default: break
            }
        }
        return arrayPoints
    }
    func getPathElementsPointsAndTypes() -> ([CGPoint],[CGPathElementType]) {
        var arrayPoints : [CGPoint]! = [CGPoint]()
        var arrayTypes : [CGPathElementType]! = [CGPathElementType]()
        self.forEach { element in
            switch (element.type) {
            case CGPathElementType.moveToPoint:
                arrayPoints.append(element.points[0])
                arrayTypes.append(element.type)
            case .addLineToPoint:
                arrayPoints.append(element.points[0])
                arrayTypes.append(element.type)
            case .addQuadCurveToPoint:
                arrayPoints.append(element.points[0])
                arrayPoints.append(element.points[1])
                arrayTypes.append(element.type)
                arrayTypes.append(element.type)
            case .addCurveToPoint:
                arrayPoints.append(element.points[0])
                arrayPoints.append(element.points[1])
                arrayPoints.append(element.points[2])
                arrayTypes.append(element.type)
                arrayTypes.append(element.type)
                arrayTypes.append(element.type)
            default: break
            }
        }
        return (arrayPoints,arrayTypes)
    }
}


extension CGRect {

    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
    
    init(center: CGPoint, size: CGSize) {
        self = CGRect(origin: center, size: size).insetBy(dx: -size.width, dy: -size.height)
    }
}
