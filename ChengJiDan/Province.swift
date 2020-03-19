import RealmSwift
import Realm

struct Province {
    let name: String
    let svgPathIndex: Int
    let cities: [String]
    
    init?(city: String) {
        if let p = Province.dictionaryByCityName[city] {
            self = p
        } else {
            return nil
        }
    }
    
    init?(name: String) {
        if let p = Province.dictionaryByName[name] {
            self = p
        } else {
            return nil
        }
    }
    
    private static let dictionaryByName: [String: Province] = Dictionary(elements: Province.allCases.map { ($0.name, $0) })
    private static let dictionaryByCityName: [String: Province] = Dictionary(elements:
        Province.allCases.flatMap { p in
            p.cities.map { ($0, p) }
        }
    )
}

extension Province: CustomDebugStringConvertible {
    var debugDescription: String {
        "Province: \(name)"
    }
}

struct CityStatusPair {
    let city: String
    let status: TravelStatus
}

extension CityStatusPair : CustomDebugStringConvertible {
    var debugDescription: String {
        "\(city): \(status)"
    }
}

struct ChengJiDanMap {
    let name: String
    let entries: [CityStatusPair]
}

class CityStatusPairObject: Object {
    @objc dynamic var city = ""
    @objc dynamic var statusInt = 0
    
    var cityStatusPair: CityStatusPair {
        CityStatusPair(city: city, status: TravelStatus(rawValue: statusInt) ?? .untrodden)
    }
    
    init(from cityStatusPair: CityStatusPair) {
        city = cityStatusPair.city
        statusInt = cityStatusPair.status.rawValue
    }
    
    required init() { }
}

class ChengJiDanMapObject: Object {
    @objc dynamic var name = ""
    let entries = List<CityStatusPairObject>()
    
    var chengJiDanMap: ChengJiDanMap {
        ChengJiDanMap(name: name, entries: entries.map { $0.cityStatusPair })
    }
    
    init(from chengJiDanMap: ChengJiDanMap) {
        name = chengJiDanMap.name
        entries.append(objectsIn: chengJiDanMap.entries.map(CityStatusPairObject.init))
    }
    
    required init() {}
}
