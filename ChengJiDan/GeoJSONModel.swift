import CodableGeoJSON

struct ProvinceProperties: Codable {
    let name: String
}

typealias MapFeatureCollection = GeoJSONFeatureCollection<MultiPolygonGeometry, ProvinceProperties>

class GeoJSONManager {
    private static var china: MapFeatureCollection?
    private static let geoJSONLoaderQueue = DispatchQueue(label: "geoJSONLoader", qos: .background)
    
    private init() {}
    
    static func loadChinaGeoJSON(completion: @escaping (MapFeatureCollection) -> Void) {
        if let china = GeoJSONManager.china {
            DispatchQueue.main.async { completion(china) }
            return
        }
        geoJSONLoaderQueue.async {
            let data = try! Data(contentsOf: Bundle.main.url(forResource: "city level map", withExtension: "geojson")!)
            let featureCollection = try! JSONDecoder().decode(MapFeatureCollection.self, from: data)
            DispatchQueue.main.async {
                completion(featureCollection)
                GeoJSONManager.china = featureCollection
            }
        }
    }
}
