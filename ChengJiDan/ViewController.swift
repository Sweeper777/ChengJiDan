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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showChengJiDan", sender: chengJiDans[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
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
    
    func addChengJiDan(name: String) {
        if name.trimmed() == "" {
            SCLAlertView().showError("错误", subTitle: "名字不能为空！", closeButtonTitle: "确定")
        } else if DataManager.shared.queryChengJiDan("name == %@", args: name).count > 0 {
            SCLAlertView().showError("错误", subTitle: "该名字已被使用！", closeButtonTitle: "确定")
        } else {
            do {
                let newChengJiDan = try DataManager.shared.addChengJiDan(withName: name)
                self.chengJiDans.append(newChengJiDan)
                self.tableView.insertRows(at: [IndexPath(row: self.chengJiDans.count - 1, section: 0)], with: .automatic)
            } catch let error {
                SCLAlertView().showError("错误", subTitle: error.localizedDescription, closeButtonTitle: "确定")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ChengJiDanMapViewController, let map = sender as? ChengJiDanMap {
            vc.chengJiDan = map
        }
    }
}

