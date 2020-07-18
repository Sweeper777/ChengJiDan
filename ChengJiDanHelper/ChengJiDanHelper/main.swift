import Foundation

func combineMaps() {
    func loadMap(fromAdcode adcode: String, includeSubregions: Bool) throws -> FeatureCollection {
        let data = try Data(contentsOf:URL(string:
            "https://geo.datav.aliyun.com/areas_v2/bound/\(adcode)\(includeSubregions ? "_full" : "").json")!)
        let decoder = JSONDecoder()
        let featureCollection = try decoder.decode(FeatureCollection.self, from: data)
        try data.write(to: URL(fileURLWithPath: "/Users/mulangsu/Desktop/geojson maps/\(adcode).geojson"))
        return featureCollection
    }
    
    print("Downloading whole country map...")
    let wholeCountry = try loadMap(fromAdcode: "100000", includeSubregions: true)
    var subMaps = [FeatureCollection]()
    for province in wholeCountry.features {
        guard !province.properties.name.isEmpty else { continue }
        let includeSubregions = !["北京市", "重庆市", "天津市", "上海市", "香港", "澳门", "台湾省"]
            .contains(province.properties.name)
        print("Downloading map of \(province.properties.name)...")
        subMaps.append(try loadMap(fromAdcode: province.properties.adcode, includeSubregions: includeSubregions))
        
    }
    print("Downloaded all the submaps. Combining...")
    let allFeatures = subMaps.map(\.features).reduce([], +)
    let bigFeatureCollection = FeatureCollection(type: "FeatureCollection", features: allFeatures)
    print("All combined! Writing data...")
    let encoder = JSONEncoder()
    let data = try encoder.encode(bigFeatureCollection)
    try data.write(to: URL(fileURLWithPath: "/Users/mulangsu/Desktop/geojson maps/city level map.geojson"))
}


