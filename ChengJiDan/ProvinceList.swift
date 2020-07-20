import Foundation

extension Province {
    static let anhui = Province(name: "安徽省")!
    static let beijing = Province(name: "北京市")!
    static let chongqing = Province(name: "重庆市")!
    static let fujian = Province(name: "福建省")!
    static let guangdong = Province(name: "广东省")!
    static let gansu = Province(name: "甘肃省")!
    static let guangxi = Province(name: "广西壮族自治区")!
    static let guizhou = Province(name: "贵州省")!
    static let hainan = Province(name: "海南省")!
    static let hebei = Province(name: "河北省")!
    static let henan = Province(name: "河南省")!
    static let hongKong = Province(name: "香港特别行政区")!
    static let heilongjiang = Province(name: "黑龙江省")!
    static let hunan = Province(name: "湖南省")!
    static let hubei = Province(name: "湖北省")!
    static let jilin = Province(name: "吉林省")!
    static let jiangsu = Province(name: "江苏省")!
    static let jiangxi = Province(name: "江西省")!
    static let liaoning = Province(name: "辽宁省")!
    static let macau = Province(name: "澳门特别行政区")!
    static let innerMongolia = Province(name: "内蒙古自治区")!
    static let ningxia = Province(name: "宁夏回族自治区")!
    static let qinghai = Province(name: "青海省")!
    static let shaanxi = Province(name: "陕西省")!
    static let sichuan = Province(name: "四川省")!
    static let shandong = Province(name: "山东省")!
    static let shanghai = Province(name: "上海市")!
    static let shanxi = Province(name: "山西省")!
    static let tianjin = Province(name: "天津市")!
    static let taiwan = Province(name: "台湾省")!
    static let xinjiang = Province(name: "新疆维吾尔自治区")!
    static let xizang = Province(name: "西藏自治区")!
    static let yunnan = Province(name: "云南省")!
    static let zhejiang = Province(name: "浙江省")!
}

extension Province : CaseIterable {
    typealias AllCases = [Province]
    
    static var allCases: [Province] = {
        let decoder = JSONDecoder()
        let data = try! Data(contentsOf: Bundle.main.url(forResource: "provinceList", withExtension: "json")!)
        return try! decoder.decode([Province].self, from: data)
    }()
}
