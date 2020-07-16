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
}

// MARK: - Parent
struct Parent: Codable {
    let adcode: Int
}
