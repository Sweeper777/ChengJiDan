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
    
    @IBAction func addChengJiDanTapped() {
        let chengJiDansWithDefaultNames = DataManager.shared.queryChengJiDan("name BEGINSWITH %@", args: "城跡单")
        let nextNumber = (chengJiDansWithDefaultNames.compactMap { Int($0.name.dropFirst(3)) }.max() ?? 0) + 1
        
        let alert = SCLAlertView()
        let textField = alert.addTextField("给新城跡单取个名字吧！")
        textField.text = "城跡单\(nextNumber)"
        alert.addButton("确定") {
            self.addChengJiDan(name: textField.text ?? "")
        }
        alert.showEdit("新城跡单", subTitle: nil, closeButtonTitle: "取消")
    }
    
}

