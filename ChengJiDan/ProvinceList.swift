import Foundation

extension Province {
    static let anhui = Province(name: "安徽省", svgPathIndex: 0, cities: [
        "安庆市",
        "蚌埠市",
        "亳州市",
        "池州市",
        "滁州市",
        "阜阳市",
        "合肥市",
        "淮北市",
        "淮南市",
        "黄山市",
        "六安市",
        "马鞍山市",
        "宿州市",
        "铜陵市",
        "芜湖市",
        "宣城市",
    ])
    static let beijing = Province(name: "北京市", svgPathIndex: 1, cities: [
        "北京市",
    ])
    static let chongqing = Province(name: "重庆市", svgPathIndex: 2, cities: [
        "重庆市",
    ])
    static let fujian = Province(name: "福建省", svgPathIndex: 3, cities: [
        "福州市",
        "厦门市",
        "莆田市",
        "三明市",
        "泉州市",
        "漳州市",
        "南平市",
        "龙岩市",
        "宁德市",
    ])
    static let guangdong = Province(name: "广东省", svgPathIndex: 4, cities: [
        "广州市",
        "韶关市",
        "深圳市",
        "珠海市",
        "汕头市",
        "佛山市",
        "江门市",
        "湛江市",
        "茂名市",
        "肇庆市",
        "惠州市",
        "梅州市",
        "汕尾市",
        "河源市",
        "阳江市",
        "清远市",
        "东莞市",
        "中山市",
        "潮州市",
        "揭阳市",
        "云浮市",
    ])
    static let gansu = Province(name: "甘肃省", svgPathIndex: 5, cities: [
        "兰州市",
        "嘉峪关市",
        "金昌市",
        "白银市",
        "天水市",
        "武威市",
        "张掖市",
        "平凉市",
        "酒泉市",
        "庆阳市",
        "定西市",
        "陇南市",
    ])
    static let guangxi = Province(name: "广西壮族自治区", svgPathIndex: 6, cities: [
    ])
    static let guizhou = Province(name: "贵州省", svgPathIndex: 7, cities: [
    ])
    static let hainan = Province(name: "海南省", svgPathIndex: 8, cities: [
    ])
    static let hebei = Province(name: "河北省", svgPathIndex: 9, cities: [
    ])
    static let henan = Province(name: "河南省", svgPathIndex: 10, cities: [
    ])
    static let hongKong = Province(name: "香港特别行政区", svgPathIndex: 11, cities: [
        "香港特别行政区"
    ])
    static let heilongjiang = Province(name: "黑龙江省", svgPathIndex: 12, cities: [
    ])
    static let hunan = Province(name: "湖南省", svgPathIndex: 13, cities: [
    ])
    static let hubei = Province(name: "湖北省", svgPathIndex: 14, cities: [
    ])
    static let jilin = Province(name: "吉林省", svgPathIndex: 15, cities: [
    ])
    static let jiangsu = Province(name: "江苏省", svgPathIndex: 16, cities: [
    ])
    static let jiangxi = Province(name: "江西省", svgPathIndex: 17, cities: [
    ])
    static let liaoning = Province(name: "辽宁省", svgPathIndex: 18, cities: [
    ])
    static let macau = Province(name: "澳门特别行政区", svgPathIndex: 19, cities: [
        "澳门特别行政区"
    ])
    static let innerMongolia = Province(name: "内蒙古自治区", svgPathIndex: 20, cities: [
    ])
    static let ningxia = Province(name: "宁夏回族自治区", svgPathIndex: 21, cities: [
    ])
    static let qinghai = Province(name: "青海省", svgPathIndex: 22, cities: [
    ])
    static let shaanxi = Province(name: "陕西省", svgPathIndex: 23, cities: [
    ])
    static let sichuan = Province(name: "四川省", svgPathIndex: 24, cities: [
    ])
    static let shandong = Province(name: "山东省", svgPathIndex: 25, cities: [
    ])
    static let shanghai = Province(name: "上海市", svgPathIndex: 26, cities: [
        "上海市"
    ])
    static let shanxi = Province(name: "山西省", svgPathIndex: 27, cities: [
    ])
    static let tianjin = Province(name: "天津市", svgPathIndex: 28, cities: [
    ])
    static let taiwan = Province(name: "台湾省", svgPathIndex: 29, cities: [
    ])
    static let xinjiang = Province(name: "新疆维吾尔自治区", svgPathIndex: 30, cities: [
    ])
    static let xizang = Province(name: "西藏自治区", svgPathIndex: 31, cities: [
    ])
    static let yunnan = Province(name: "云南省", svgPathIndex: 32, cities: [
    ])
    static let zhejiang = Province(name: "浙江省", svgPathIndex: 33, cities: [
    ])
}

extension Province : CaseIterable {
    typealias AllCases = [Province]
    
    static var allCases: [Province] {
        [
            anhui, beijing, chongqing, fujian, guangdong, gansu, guangxi, guizhou,
            hainan, hebei, henan, hongKong, heilongjiang, hunan, hubei, jilin, jiangsu,
            jiangxi, liaoning, macau, innerMongolia, ningxia, qinghai, shaanxi, sichuan,
            shandong, shanghai, shanxi, tianjin, taiwan, xinjiang, xizang, yunnan, zhejiang
        ]
    }
}
