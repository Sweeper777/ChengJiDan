import Realm
import RealmSwift

class DataManager {
    private let chengJiDanMaps: Results<ChengJiDanMapObject>
    private let realm: Realm!
    weak var delegate: DataManagerDelegate?
    
    var allChengJiDan: [ChengJiDanMap] {
        Array(chengJiDanMaps).map { $0.chengJiDanMap }
    }
    
    private init() {
        do {
            realm = try Realm()
            chengJiDanMaps = realm.objects(ChengJiDanMapObject.self).sorted(byKeyPath: "name")
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
    
    func addChengJiDan(withName name: String) throws {
        let chengJiDan = ChengJiDanMapObject()
        chengJiDan.name = name
        try realm.write {
            realm.add(chengJiDan)
        }
        delegate?.dataDidUpdate(kind: .added(chengJiDan.chengJiDanMap))
    }
    
    func queryChengJiDan(_ format: String, args: Any...) -> [ChengJiDanMap] {
        return chengJiDanMaps.filter(NSPredicate(format: format, argumentArray: args))
            .map { $0.chengJiDanMap }
    }
    
    func updateChengJiDan(oldChengJiDan: ChengJiDanMap, newChengJiDan: inout ChengJiDanMap) throws {
        try realm.write {
            oldChengJiDan.objectRef?.name = newChengJiDan.name
            oldChengJiDan.objectRef?.entries.forEach(realm.delete)
            newChengJiDan.entries.map(CityStatusPairObject.init).forEach { oldChengJiDan.objectRef?.entries.append($0) }
            newChengJiDan.objectRef = oldChengJiDan.objectRef
        }
        delegate?.dataDidUpdate(kind: .updated(old: oldChengJiDan, new: newChengJiDan))
    }
    
    func deleteChengJiDan(_ chengJiDan: ChengJiDanMap) throws {
        try realm.write {
            deleteChengJiDanImpl(chengJiDan)
        }
        delegate?.dataDidUpdate(kind: .removed(chengJiDan))
    }
    
    private func addChengJiDanImpl(_ chengJiDan: inout ChengJiDanMap) {
        let object = ChengJiDanMapObject(from: chengJiDan)
        realm.add(object)
        chengJiDan.objectRef = object
    }
    
    private func deleteChengJiDanImpl(_ chengJiDan: ChengJiDanMap) {
        chengJiDan.objectRef.map { realm.delete($0) }
    }
}

protocol DataManagerDelegate : class {
    func dataDidUpdate(kind: DataUpdateKind)
}

enum DataUpdateKind {
    case added(ChengJiDanMap)
    case removed(ChengJiDanMap)
    case updated(old: ChengJiDanMap, new: ChengJiDanMap)
}
