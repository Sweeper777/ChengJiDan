import CodableGeoJSON

struct ProvinceProperties: Codable {
    let name: String
}

typealias MapFeatureCollection = GeoJSONFeatureCollection<MultiPolygonGeometry, ProvinceProperties>
