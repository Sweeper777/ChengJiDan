import UIKit
import SwiftyXMLParser

class ChengJiDanMapViewController : UIViewController {
    var chengJiDan: ChengJiDanMap!
    
    @IBOutlet var svgView: SVGView!
    
    override func viewDidLoad() {
    }
    
}

extension ChengJiDanMap {
    var totalForEachProvince: [Province: UIColor] {
        let groups = Dictionary(grouping: entries, by: { Province(city: $0.city) })
        var totals = groups.mapValues { $0.map { $0.status.rawValue }.max() ?? 0 }
        totals[nil] = nil
        return totals.mapValues { UIColor(named: TravelStatus(rawValue: $0)!.debugDescription) } as! [Province: UIColor]
    }
}
