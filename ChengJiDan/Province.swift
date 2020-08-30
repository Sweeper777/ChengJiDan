import RealmSwift
import Realm

struct Province : Codable {
    let name: String
    let shortName: String
    let svgPathIndex: Int
    let cities: [String]
    let abbreviation: String
    
    init(name: String, shortName: String, svgPathIndex: Int, cities: [String]) {
        self.name = name
        self.shortName = shortName
        self.svgPathIndex = svgPathIndex
        self.cities = cities
        self.abbreviation = ""
    }
    
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
    
    private static let dictionaryByName: [String: Province] = Dictionary(uniqueKeysWithValues: Province.allCases.map { ($0.name, $0) })
    private static let dictionaryByCityName: [String: Province] = Dictionary(uniqueKeysWithValues:
        Province.allCases.flatMap { p in
            p.cities.map { ($0, p) }
        }
    )
}

extension Province : Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
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
    let entryDict: [String: TravelStatus]
    
    var objectRef: ChengJiDanMapObject?
    
    init(name: String, entries: [CityStatusPair]) {
        self.name = name
        self.entries = entries
        self.entryDict = Dictionary(uniqueKeysWithValues: entries.map { ($0.city, $0.status) })
    }
    
    init(objectRef: ChengJiDanMapObject) {
        self.init(name: objectRef.name, entries: objectRef.entries.map { $0.cityStatusPair })
        self.objectRef = objectRef
    }
    
    var totalScore: Int {
        entries.map { $0.status.rawValue }.reduce(0, +)
    }
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
        ChengJiDanMap(objectRef: self)
    }
    
    init(from chengJiDanMap: ChengJiDanMap) {
        name = chengJiDanMap.name
        entries.append(objectsIn: chengJiDanMap.entries.map(CityStatusPairObject.init))
    }
    
    required init() {}
}
