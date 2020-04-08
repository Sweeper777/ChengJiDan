import UIKit
import SwiftyXMLParser
import SCLAlertView
import DynamicColor

class ChengJiDanMapViewController : UITableViewController {
    var chengJiDan: ChengJiDanMap!
    
    @IBOutlet var svgView: SVGView!
    @IBOutlet var scoreLabel: UILabel!
    
    override func viewDidLoad() {
        let xmlString = try! String(contentsOfFile: Bundle.main.path(forResource: "map", ofType: "svg")!)
        let xml = try! XML.parse(xmlString)
        svgView.svgStrings = Array(xml["svg", "g" ,"path"])
            .map { $0.attributes["d"]! }
        updateView()
        tableView.separatorColor = .clear
        tableView.allowsSelection = false
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 {
            return tableView.width / svgView.whRatio
        } else {
            return UITableView.automaticDimension
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { _ in
            self.svgView.setNeedsDisplay()
        }) { _ in
            self.tableView.reloadData()
        }
    }
    
    func updateView() {
        svgView.colorDict = Dictionary(elements:
            chengJiDan.colorForEachProvince.map { ($0.key.svgPathIndex, $0.value) }
        )
        updateScoreLabel()
    }
    
    func updateScoreLabel() {
        let scoreText = NSMutableAttributedString(string: "城跡：\n", attributes: [.font: UIFont.systemFont(ofSize: 30)])
        scoreText.append(NSAttributedString(string: "\(chengJiDan.totalScore)", attributes: [.font: UIFont.systemFont(ofSize: 50)]))
        scoreText.append(NSAttributedString(string: "分", attributes: [.font: UIFont.systemFont(ofSize: 30), .baselineOffset: 7]))
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        scoreText.addAttributes([.paragraphStyle: paragraphStyle], range: NSRange(location: 0, length: scoreText.length))
        scoreLabel.attributedText = scoreText
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
            updateView()
        } catch let error {
            let alert = SCLAlertView()
            alert.showError("错误", subTitle: error.localizedDescription, closeButtonTitle: "确定")
        }
    }
}
