import UIKit
import SwiftyXMLParser

class ChengJiDanMapViewController : UIViewController {
    var chengJiDan: ChengJiDanMap!
    
    @IBOutlet var svgView: SVGView!
    
    override func viewDidLoad() {
        let xmlString = try! String(contentsOfFile: Bundle.main.path(forResource: "map", ofType: "svg")!)
        let xml = try! XML.parse(xmlString)
        svgView.svgStrings = Array(xml["svg", "g" ,"path"])
            .map { $0.attributes["d"]! }
        svgView.colorDict = Dictionary(elements:
            chengJiDan.totalForEachProvince.map { ($0.key.svgPathIndex, $0.value) }
        )
    }
    
    @IBAction func editTapped() {
        performSegue(withIdentifier: "editChengJiDan", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = (segue.destination as? UINavigationController)?.topViewController as? ChengJiDanEditorViewController {
            vc.cityStatusPairs = chengJiDan.entries
            vc.delegate = self
        }
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

extension ChengJiDanMapViewController : ChengJiDanEditorViewControllerDelegate {
    func didFinishEditing(editingResult: [CityStatusPair]) {
        
    }
}
