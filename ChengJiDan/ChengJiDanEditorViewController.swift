import UIKit
import SCLAlertView
import SWPinYinSearcher_JDBR

class ChengJiDanEditorViewController : UITableViewController {
    weak var delegate: ChengJiDanEditorViewControllerDelegate?
    var chengJiDan: ChengJiDanMap!
    var cityStatusPairs: [CityStatusPair]!
    var cityStatusPairDict: [String: TravelStatus]!
    var dataSource: [Province]!
    
    var newName: String?
    
    let searchController = UISearchController(searchResultsController: nil)
    var filteredCities: [String] = []
    
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    override func viewDidLoad() {
        cityStatusPairs = chengJiDan.entries
        cityStatusPairDict = Dictionary(elements: cityStatusPairs!.map { ($0.city, $0.status) })
        dataSource = Province.allCases
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "搜索..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltering {
            return 1
        } else {
            return dataSource.count
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredCities.count
        } else {
            return dataSource[section].cities.count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isFiltering {
            return nil
        } else {
            return dataSource[section].name
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let status: TravelStatus
        if isFiltering {
            cell.textLabel?.text = filteredCities[indexPath.row]
            status = cityStatusPairDict[filteredCities[indexPath.row]] ?? .untrodden
        } else {
            cell.textLabel?.text = dataSource[indexPath.section].cities[indexPath.row]
            status = cityStatusPairDict[dataSource[indexPath.section].cities[indexPath.row]] ?? .untrodden
        }
        cell.detailTextLabel?.text = status.description
        cell.backgroundColor = UIColor(named: status.debugDescription) ?? .systemGray
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchController.searchBar.resignFirstResponder()
        let provinceName: String
        let cityName: String
        if isFiltering {
            provinceName = Province(city: filteredCities[indexPath.row])!.name
            cityName = filteredCities[indexPath.row]
        } else {
            provinceName = dataSource[indexPath.section].name
            cityName = dataSource[indexPath.section].cities[indexPath.row]
        }
        let alert = SCLAlertView()
        TravelStatus.allCases.forEach { (status) in
            alert.addButton("\(status.description) （\(status.rawValue)分）", backgroundColor: UIColor(named: status.debugDescription) ?? .systemGray) {
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
    
    @IBAction func renameTapped() {
        let alert = SCLAlertView()
        let textField = alert.addTextField("输入新名字")
        textField.text = "\(chengJiDan.name)"
        alert.addButton("确定") {
            self.renameChengJiDan(name: textField.text ?? "")
        }
        alert.showEdit("重命名：", subTitle: nil, closeButtonTitle: "取消")
    }
    
    func renameChengJiDan(name: String) {
        if name.trimmed() == "" {
            SCLAlertView().showError("错误", subTitle: "名字不能为空！", closeButtonTitle: "确定")
        } else if DataManager.shared.queryChengJiDan("name == %@", args: name.trimmed()).count > 0 {
            SCLAlertView().showError("错误", subTitle: "该名字已被使用！", closeButtonTitle: "确定")
        } else {
            newName = name.trimmed()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.didFinishEditing(editingResult: cityStatusPairDict.map { CityStatusPair(city: $0.key, status: $0.value) }, newName: newName)
    }
    
    func createAd() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: adUnitIdInterstitial)
        interstitial.delegate = self
        let request = GADRequest()
        interstitial.load(request)
        return interstitial
    }
}

protocol ChengJiDanEditorViewControllerDelegate: class {
    func didFinishEditing(editingResult: [CityStatusPair], newName: String?)
}

extension ChengJiDanEditorViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
    
    func filterContentForSearchText(_ searchText: String) {
        let allCities = dataSource!.flatMap { $0.cities }
        filteredCities = (allCities as NSArray).searchPinYin(withKeyPath: nil, search: searchText.lowercased(), searchOption: [.hanZi, .jianPin, .quanPin]) as! [String]
        tableView.reloadData()
    }
}
