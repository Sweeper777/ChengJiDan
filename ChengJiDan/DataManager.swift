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
    
    private static var _shared: DataManager?
    
    static var shared: DataManager {
        _shared = _shared ?? DataManager()
        return _shared!
    }
    
    func addChengJiDan(withName name: String) throws -> ChengJiDanMap {
        let chengJiDan = ChengJiDanMapObject()
        chengJiDan.name = name
        try realm.write {
            realm.add(chengJiDan)
        }
        return chengJiDan.chengJiDanMap
    }
    
    func queryChengJiDan(_ format: String, args: Any...) -> [ChengJiDanMap] {
        return chengJiDanMaps.filter(NSPredicate(format: format, argumentArray: args))
            .map { $0.chengJiDanMap }
    }
    
    func updateChengJiDan(oldChengJiDan: ChengJiDanMap, newChengJiDan: ChengJiDanMap) throws {
        try realm.write {
            deleteChengJiDanImpl(oldChengJiDan)
            addChengJiDanImpl(newChengJiDan)
        }
    }
    
    private func addChengJiDanImpl(_ chengJiDan: ChengJiDanMap) {
        realm.add(ChengJiDanMapObject(from: chengJiDan))
    }
    
    private func deleteChengJiDanImpl(_ chengJiDan: ChengJiDanMap) {
        chengJiDan.objectRef.map { realm.delete($0) }
    }
}
