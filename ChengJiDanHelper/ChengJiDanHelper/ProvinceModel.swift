struct Province : Codable {
    let name: String
    let shortName: String
    let svgPathIndex: Int
    let cities: [String]
    let abbreviation: String
    
    init(name: String, shortName: String, svgPathIndex: Int, cities: [String]) {
        self.name = name
        self.shortName = shortName
        self.svgPathIndex = svgPathIndex
        self.cities = cities
        self.abbreviation = ""
    }
}
