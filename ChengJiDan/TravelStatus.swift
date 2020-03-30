import Foundation

enum TravelStatus: Int, CustomDebugStringConvertible, CustomStringConvertible, CaseIterable {
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
    
    var description: String {
        switch self {
        case .untrodden:
            return "未经"
        case .passedThrough:
            return "驶过"
        case .landed:
            return "转乘"
        case .visited:
            return "访问"
        case .spentTheNight:
            return "小住"
        case .lived:
            return "居住"
        }
    }
}
