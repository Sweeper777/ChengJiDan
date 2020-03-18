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

