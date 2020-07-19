import Foundation

func combineMaps() throws{
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

func readLocalMap() throws -> FeatureCollection {
    let data = try Data(contentsOf: URL.init(fileURLWithPath: "/Users/mulangsu/Desktop/city lists/city level map.geojson"))
    let decoder = JSONDecoder()
    let featureCollection = try decoder.decode(FeatureCollection.self, from: data)
    return featureCollection
}
func readProvinceList() throws -> [Province] {
    let data = try Data(contentsOf: URL.init(fileURLWithPath: "/Users/mulangsu/Desktop/city lists/provinceList.json"))
    let decoder = JSONDecoder()
    let provinces = try decoder.decode([Province].self, from: data)
    return provinces
}
let map = try readLocalMap()
let provinces = try readProvinceList()
let cityListFromMap = map.features.map(\.properties.name).sorted().joined(separator: "\n")
let cityListFromProvinces = provinces.flatMap(\.cities).sorted().joined(separator: "\n")
try cityListFromMap.write(to: URL(fileURLWithPath: "/Users/mulangsu/Desktop/city lists/map city list.txt"), atomically: true, encoding: .utf8)
try cityListFromProvinces.write(to: URL(fileURLWithPath: "/Users/mulangsu/Desktop/city lists/province list city list.txt"), atomically: true, encoding: .utf8)
print("Done!")
