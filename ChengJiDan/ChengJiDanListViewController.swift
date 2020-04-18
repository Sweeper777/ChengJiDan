import UIKit
import SCLAlertView

class ChengJiDanListViewController: UITableViewController {

    var chengJiDans: [ChengJiDanMap]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chengJiDans = DataManager.shared.allChengJiDan
        DataManager.shared.delegate = self
        navigationItem.rightBarButtonItems?.append(editButtonItem)
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
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let chengJiDan = chengJiDans[indexPath.row]
        do {
            try DataManager.shared.deleteChengJiDan(chengJiDan)
            chengJiDans.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch let error {
            SCLAlertView().showError("错误", subTitle: error.localizedDescription, closeButtonTitle: "确定")
        }
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
    
    @IBAction func helpTapped() {
        performSegue(withIdentifier: "showHelp", sender: nil)
    }
    
    func addChengJiDan(name: String) {
        if name.trimmed() == "" {
            SCLAlertView().showError("错误", subTitle: "名字不能为空！", closeButtonTitle: "确定")
        } else if DataManager.shared.queryChengJiDan("name == %@", args: name).count > 0 {
            SCLAlertView().showError("错误", subTitle: "该名字已被使用！", closeButtonTitle: "确定")
        } else {
            do {
                try DataManager.shared.addChengJiDan(withName: name)
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

extension ChengJiDanListViewController : DataManagerDelegate {
    func dataDidUpdate(kind: DataUpdateKind) {
        switch kind {
        case .added(let newChengJiDan):
            self.chengJiDans.append(newChengJiDan)
            self.tableView.insertRows(at: [IndexPath(row: self.chengJiDans.count - 1, section: 0)], with: .automatic)
        case .removed:
            break
        case .updated:
            chengJiDans = DataManager.shared.allChengJiDan
            tableView.reloadData()
        }
    }
}
