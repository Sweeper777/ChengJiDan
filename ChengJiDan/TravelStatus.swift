import Foundation

enum TravelStatus: Int, CustomDebugStringConvertible {
    case untrodden
    case passedThrough
    case landed
    case visited
    case spentTheNight
    case lived
    
    var debugDescription: String {
        switch self {
        case .untrodden:
            return "untrodden"
        case .passedThrough:
            return "passedThrough"
        case .landed:
            return "landed"
        case .visited:
            return "visited"
        case .spentTheNight:
            return "spentTheNight"
        case .lived:
            return "lived"
        }
    }
}
