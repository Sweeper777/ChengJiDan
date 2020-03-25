import UIKit
import SCLAlertView

class ChengJiDanListViewController: UITableViewController {

    var chengJiDans: [ChengJiDanMap]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chengJiDans = DataManager.shared.allChengJiDan
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chengJiDans.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = chengJiDans[indexPath.row].name
        return cell
    }
}

