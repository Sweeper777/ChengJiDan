import Realm
import RealmSwift

class DataManager {
    private let chengJiDanMaps: Results<ChengJiDanMapObject>
    private let realm: Realm!
    
    var allChengJiDan: [ChengJiDanMap] {
        Array(chengJiDanMaps).map { $0.chengJiDanMap }
    }
    
    private init() {
        do {
            realm = try Realm()
            chengJiDanMaps = realm.objects(ChengJiDanMapObject.self)
        } catch let error {
            print(error)
            fatalError()
        }
    }
    
}
