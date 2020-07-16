import Foundation

// MARK: - FeatureCollection
struct FeatureCollection: Codable {
    let type: String
    let features: [Feature]
}

// MARK: - Feature
struct Feature: Codable {
    let type: String
    let properties: Properties
    let geometry: Geometry
}

// MARK: - Geometry
struct Geometry: Codable {
    let type: String
    let coordinates: [[[[Double]]]]
}

// MARK: - Properties
struct Properties: Codable {
    let adcode: String
    let name: String
    let center: [Double]?
    let centroid: [Double]?
    let childrenNum: Int?
    let level: String?
    let parent: Parent?
    let subFeatureIndex: Int?
    let acroutes: [Int]?
    
    enum CodingKeys : CodingKey {
        case adcode
        case name
        case center
        case centroid
        case childrenNum
        case level
        case parent
        case subFeatureIndex
        case acroutes
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            adcode = try container.decode(String.self, forKey: .adcode)
        } catch {
            adcode = try container.decode(Int.self, forKey: .adcode).description
        }
        name = try container.decode(String.self, forKey: .name)
        center = try container.decodeIfPresent([Double].self, forKey: .center)
        centroid = try container.decodeIfPresent([Double].self, forKey: .centroid)
        childrenNum = try container.decodeIfPresent(Int.self, forKey: .childrenNum)
        level = try container.decodeIfPresent(String.self, forKey: .level)
        parent = try container.decodeIfPresent(Parent.self, forKey: .parent)
        acroutes = try container.decodeIfPresent([Int].self, forKey: .acroutes)
        subFeatureIndex = try container.decodeIfPresent(Int.self, forKey: .subFeatureIndex)
    }
}

// MARK: - Parent
struct Parent: Codable {
    let adcode: Int
}
