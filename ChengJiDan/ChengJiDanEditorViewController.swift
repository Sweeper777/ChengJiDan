import UIKit
import SCLAlertView

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
        cell.backgroundColor = UIColor(named: status.debugDescription) ?? .systemGray
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let provinceName = dataSource[indexPath.section].name
        let cityName = dataSource[indexPath.section].cities[indexPath.row]
        let alert = SCLAlertView()
        TravelStatus.allCases.forEach { (status) in
            alert.addButton(status.description, backgroundColor: UIColor(named: status.debugDescription) ?? .systemGray) {
                [weak self] in
                self?.cityStatusPairDict[cityName] = status
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        alert.showEdit(cityName, subTitle: provinceName, closeButtonTitle: "取消")
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func doneTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.didFinishEditing(editingResult: cityStatusPairDict.map { CityStatusPair(city: $0.key, status: $0.value) })
    }
}

protocol ChengJiDanEditorViewControllerDelegate: class {
    func didFinishEditing(editingResult: [CityStatusPair])
}
