import UIKit

class ChengJiDanEditorViewController : UITableViewController {
    weak var delegate: ChengJiDanEditorViewControllerDelegate?
    var cityStatusPairs: [CityStatusPair]!
    var cityStatusPairDict: [String: TravelStatus]!
    var dataSource: [Province]!
    
    override func viewDidLoad() {
        cityStatusPairDict = Dictionary(elements: cityStatusPairs!.map { ($0.city, $0.status) })
        dataSource = Province.allCases
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource[section].cities.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        dataSource[section].name
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = dataSource[indexPath.section].cities[indexPath.row]
        let status = cityStatusPairDict[dataSource[indexPath.section].cities[indexPath.row]] ?? .untrodden
        cell.detailTextLabel?.text = status.description
        return cell
    }
}

protocol ChengJiDanEditorViewControllerDelegate: class {
    func didFinishEditing(editingResult: [CityStatusPair])
}
