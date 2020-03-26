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
    
}

