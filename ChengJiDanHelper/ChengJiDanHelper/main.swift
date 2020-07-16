import Foundation

func loadMap(fromAdcode adcode: String, includeSubregions: Bool) throws -> FeatureCollection {
    let data = try Data(contentsOf:URL(string:
        "https://geo.datav.aliyun.com/areas_v2/bound/\(adcode)\(includeSubregions ? "_full" : "").json")!)
    let decoder = JSONDecoder()
    let featureCollection = try decoder.decode(FeatureCollection.self, from: data)
    try data.write(to: URL(fileURLWithPath: "/Users/mulangsu/Desktop/geojson maps/\(adcode).geojson"))
    return featureCollection
}

