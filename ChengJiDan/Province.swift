import RealmSwift
import Realm

struct Province {
    let name: String
    let svgPathIndex: Int
    let cities: [String]
    
    
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
    
}
