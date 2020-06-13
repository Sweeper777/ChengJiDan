import UIKit
import SCLAlertView
import SWPinYinSearcher_JDBR
import GoogleMobileAds
import MGSwipeTableCell

class ChengJiDanEditorViewController : UITableViewController {
    weak var delegate: ChengJiDanEditorViewControllerDelegate?
    var chengJiDan: ChengJiDanMap!
    var cityStatusPairs: [CityStatusPair]!
    var cityStatusPairDict: [String: TravelStatus]!
    var dataSource: [Province]!
    
    var newName: String?
    
    var ad: GADInterstitial!
    var adsLeft = 4
    
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
        searchController.searchBar.placeholder = "搜索 (支持拼音)..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
        
        ad = createAd()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MGSwipeTableCell
        let status: TravelStatus
        let cityName: String
        if isFiltering {
            cityName = filteredCities[indexPath.row]
        } else {
            cityName = dataSource[indexPath.section].cities[indexPath.row]
        }
        cell.textLabel?.text = cityName
        status = cityStatusPairDict[cityName] ?? .untrodden
        cell.detailTextLabel?.text = status.description
        cell.backgroundColor = UIColor(named: status.debugDescription) ?? .systemGray
        cell.leftButtons = TravelStatus.allCases.map {
            status in
            return MGSwipeButton(title: status.description, backgroundColor: UIColor(named: status.debugDescription) ?? .systemGray) {
                [weak self] sender in
                guard let `self` = self else { return false }
                self.cityStatusPairDict[cityName] = status
                tableView.reloadRows(at: [indexPath], with: .automatic)
                self.tryShowAd(withProbability: 3)
                return true
            }
        }
        cell.leftSwipeSettings.transition = .static
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
                guard let `self` = self else { return }
                self.cityStatusPairDict[cityName] = status
                tableView.reloadRows(at: [indexPath], with: .automatic)
                self.tryShowAd(withProbability: 3)
            }
        }
        alert.showEdit(cityName, subTitle: provinceName, closeButtonTitle: "取消")
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if isFiltering {
            return nil
        } else {
            return Province.allCases.map { $0.abbreviation }
        }
    }
    
    func tryShowAd(withProbability probability: Int) {
        if self.adsLeft > 0 && self.ad.isReady && Int.random(in: 0..<100) < probability {
            self.ad.present(fromRootViewController: self)
            self.adsLeft -= 1
        }
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        tryShowAd(withProbability: 2)
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        tryShowAd(withProbability: 2)
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

extension ChengJiDanEditorViewController : GADInterstitialDelegate {
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        self.ad = createAd()
    }
    
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print(error)
    }
}
