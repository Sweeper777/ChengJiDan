import UIKit
import SwiftyXMLParser
import SCLAlertView
import DynamicColor

class ChengJiDanMapViewController : UIViewController {
    var chengJiDan: ChengJiDanMap!
    
    @IBOutlet var svgView: SVGView!
    
    override func viewDidLoad() {
        let xmlString = try! String(contentsOfFile: Bundle.main.path(forResource: "map", ofType: "svg")!)
        let xml = try! XML.parse(xmlString)
        svgView.svgStrings = Array(xml["svg", "g" ,"path"])
            .map { $0.attributes["d"]! }
        svgView.colorDict = Dictionary(elements:
            chengJiDan.colorForEachProvince.map { ($0.key.svgPathIndex, $0.value) }
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
    var colorForEachProvince: [Province: UIColor] {
        Dictionary(elements: Province.allCases.map { ($0, color(forProvince: $0)) })
    }
    
    private func color(forProvince province: Province) -> UIColor {
        let statuses = province.cities.map { entryDict[$0] ?? .untrodden }
        let maxStatus = TravelStatus(rawValue: statuses.map { $0.rawValue }.max() ?? 0) ?? .untrodden
        let baseColor = UIColor(named: maxStatus.debugDescription) ?? .clear
        let totalNumber = province.cities.count
        let visitedCount = statuses.filter { $0.rawValue > 0 }.count
        let percentage = visitedCount.f / totalNumber.f
        return baseColor.withAlphaComponent(percentage)
    }
}

extension ChengJiDanMapViewController : ChengJiDanEditorViewControllerDelegate {
    func didFinishEditing(editingResult: [CityStatusPair]) {
        do {
            var newChengJiDan = ChengJiDanMap(name: chengJiDan.name, entries: editingResult)
            try DataManager.shared.updateChengJiDan(oldChengJiDan: chengJiDan, newChengJiDan: &newChengJiDan)
            chengJiDan = newChengJiDan
            svgView.colorDict = Dictionary(elements:
                chengJiDan.colorForEachProvince.map { ($0.key.svgPathIndex, $0.value) }
            )
        } catch let error {
            let alert = SCLAlertView()
            alert.showError("错误", subTitle: error.localizedDescription, closeButtonTitle: "确定")
        }
    }
}
