import UIKit
import SwiftyXMLParser

class ChengJiDanMapViewController : UIViewController {
    var chengJiDan: ChengJiDanMap!
    
    @IBOutlet var svgView: SVGView!
    
    override func viewDidLoad() {
        chengJiDan = ChengJiDanMap(name: "", entries: [
            CityStatusPair(city: "沈阳市", status: .lived),
            CityStatusPair(city: "北京市", status: .lived),
            CityStatusPair(city: "香港特别行政区", status: .lived),
            CityStatusPair(city: "承德市", status: .spentTheNight),
            CityStatusPair(city: "上海市", status: .spentTheNight),
            CityStatusPair(city: "广州市", status: .spentTheNight),
            CityStatusPair(city: "石家庄市", status: .passedThrough),
            CityStatusPair(city: "青岛市", status: .passedThrough),
            CityStatusPair(city: "天津市", status: .landed),
            CityStatusPair(city: "武汉市", status: .visited),
        ])
        
        let xmlString = try! String(contentsOfFile: Bundle.main.path(forResource: "map", ofType: "svg")!)
        let xml = try! XML.parse(xmlString)
        svgView.svgStrings = Array(xml["svg", "g" ,"path"])
            .map { $0.attributes["d"]! }
        svgView.colorDict = Dictionary(elements:
            chengJiDan.totalForEachProvince.map { ($0.key.svgPathIndex, $0.value) }
        )
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
