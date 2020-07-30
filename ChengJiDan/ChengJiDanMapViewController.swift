import UIKit
import SwiftyXMLParser
import SCLAlertView
import FSImageViewer

class ChengJiDanMapViewController : UITableViewController {
    var chengJiDan: ChengJiDanMap?
    
    @IBOutlet var mapView: GeoJSONMapView!
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var passedThroughLabel: UILabel!
    @IBOutlet var landedLabel: UILabel!
    @IBOutlet var visitedLabel: UILabel!
    @IBOutlet var spentTheNightLabel: UILabel!
    @IBOutlet var livedLabel: UILabel!
    @IBOutlet var keyLabel: UILabel!
    
    var imageCache: UIImage?
    var shouldGenerateNewImage = true
    var mapLoaded = false

    override func viewDidLoad() {
        updateView()
        mapView.lowestLongitude = 73.5
        mapView.longitudeRange = 61.25
        mapView.lowestLatitudeMercator = 0.1548
        mapView.latitudeRangeMercator = 0.9582
        tableView.separatorColor = .clear
        tableView.allowsSelection = false
        title = chengJiDan?.name ?? ""
        let keyText = generateKeyText(fontSize: 13)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        paragraphStyle.alignment = .center
        keyText.addAttributes([.paragraphStyle: paragraphStyle], range: NSRange(location: 0, length: keyText.length))
        keyLabel.attributedText = keyText
        
        if chengJiDan == nil {
            navigationItem.rightBarButtonItems = []
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !mapLoaded {
            GeoJSONManager.loadChinaGeoJSON { [weak self] in
                self?.mapView.featureCollection = $0
            }
            mapLoaded = true
        }
    }
    
    @IBAction func editTapped() {
        performSegue(withIdentifier: "editChengJiDan", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = (segue.destination as? UINavigationController)?.topViewController as? ChengJiDanEditorViewController {
            vc.chengJiDan = chengJiDan
            vc.delegate = self
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 {
            return tableView.width * 0.9
        } else {
            return UITableView.automaticDimension
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { _ in
        }) { _ in
            self.tableView.reloadData()
        }
    }
    
    func updateView() {
        shouldGenerateNewImage = true
        mapView.colorDict = chengJiDan?.entryDict
            .mapValues { UIColor(named: $0.debugDescription) ?? .clear } ?? [:]
        mapView.colorDict["台湾省"] = chengJiDan?.colorForEachProvince[.taiwan]!
        scoreLabel.attributedText = generateScoreText(fontSize: 30)
        title = chengJiDan?.name ?? ""
        updateCityListLabels()
    }
    
    func generateScoreText(fontSize: CGFloat) -> NSAttributedString {
        let scoreText = NSMutableAttributedString(string: "城迹：\n", attributes: [.font: UIFont.systemFont(ofSize: fontSize)])
        scoreText.append(NSAttributedString(string: "\(chengJiDan?.totalScore ?? 0)", attributes: [.font: UIFont.systemFont(ofSize: fontSize * 5 / 3)]))
        scoreText.append(NSAttributedString(string: "分", attributes: [.font: UIFont.systemFont(ofSize: fontSize), .baselineOffset: fontSize / 4]))
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        scoreText.addAttributes([.paragraphStyle: paragraphStyle], range: NSRange(location: 0, length: scoreText.length))
        return scoreText
    }
    
    func generateKeyText(fontSize: CGFloat) -> NSMutableAttributedString {
        let keyText = NSMutableAttributedString()
        let keyTextFont = UIFont.systemFont(ofSize: fontSize)
        for status in TravelStatus.allCases where status != .untrodden {
            keyText.append(NSAttributedString(string: "█ ", attributes: [
                .font: keyTextFont,
                .foregroundColor: UIColor(named: status.debugDescription)!
            ]))
            keyText.append(NSAttributedString(string: status.description + "　", attributes: [
                .font: keyTextFont
            ]))
        }
        return keyText
    }
    
    func updateCityListLabels() {
        let statusLabelDict = [
            TravelStatus.passedThrough: passedThroughLabel!,
            .landed: landedLabel!,
            .visited: visitedLabel!,
            .spentTheNight: spentTheNightLabel!,
            .lived: livedLabel!
        ]
        
        func updateCityListLabel(status: TravelStatus) {
            guard let label = statusLabelDict[status] else { return }
            let text = NSMutableAttributedString(string: "\(status.description)（\(status.rawValue)分）：\n", attributes: [.font: UIFont.systemFont(ofSize: 18)])
            let cityList = chengJiDan?.entries.filter { $0.status == status }.map { $0.city } ?? []
            let cityListText = cityList.isEmpty ? "无" : cityList.joined(separator: "、")
            text.append(NSAttributedString(string: cityListText, attributes: [.font: UIFont.systemFont(ofSize: 13), .foregroundColor: UIColor.systemGray]))
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.paragraphSpacing = 5
            text.addAttributes([.paragraphStyle: paragraphStyle], range: NSRange(location: 0, length: text.length))
            label.attributedText = text
        }
        
        updateCityListLabel(status: .passedThrough)
        updateCityListLabel(status: .landed)
        updateCityListLabel(status: .visited)
        updateCityListLabel(status: .spentTheNight)
        updateCityListLabel(status: .lived)
    }
    
    @IBAction func exportTapped() {
        if imageCache != nil && !shouldGenerateNewImage {
            print("used cache!")
            pushFSImageViewer(withImage: imageCache!)
        } else {
            guard let generatedImage = self.exportChengJiDanAsImage() else { return }
            self.imageCache = generatedImage
            self.shouldGenerateNewImage = false
            
            print("generated new image!")
            self.pushFSImageViewer(withImage: generatedImage)
        }
        
    }
    
    func pushFSImageViewer(withImage image: UIImage) {
        let fsImage = FSBasicImage(image: image)
        let imageSource = FSBasicImageSource(images: [fsImage])
        let vc = FSImageViewerViewController(imageSource: imageSource)
        vc.backgroundColorVisible = .systemBackground
        vc.backgroundColorHidden = .systemBackground
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func exportChengJiDanAsImage() -> UIImage? {
        let size = CGSize(width: 1000, height: 1000)
        UIGraphicsBeginImageContext(size)
        UIColor.white.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        mapView.drawMap(
            borderColor: .black,
            frame: CGRect(
                origin: .zero,
                size: CGSize(width: size.width, height: size.width * 0.9)
            )
        )
        
        let scoreText = generateScoreText(fontSize: 50)
        let scoreTextBoundingRect = scoreText.boundingRect(with: size, options: [.usesDeviceMetrics, .usesLineFragmentOrigin], context: nil)
        let padding = 30.f
        let scoreTextX = padding * 3
        let scoreTextY = size.height - scoreTextBoundingRect.height - padding * 3
        let drawingRect = scoreTextBoundingRect.with(origin: CGPoint(x: scoreTextX, y: scoreTextY))
        
        let borderRect = drawingRect.insetBy(dx: -padding, dy: -padding)
        let scoreTextBorderPath = UIBezierPath(roundedRect: borderRect, cornerRadius: 20)

        let scoreTextBackgroundLayer = CAShapeLayer()
        scoreTextBackgroundLayer.path = scoreTextBorderPath.cgPath
        scoreTextBackgroundLayer.fillColor = UIColor.white.cgColor
        scoreTextBackgroundLayer.shadowRadius = 7
        scoreTextBackgroundLayer.shadowOpacity = 1
        scoreTextBackgroundLayer.render(in: UIGraphicsGetCurrentContext()!)
        scoreText.draw(with: drawingRect, options: [.usesDeviceMetrics, .usesLineFragmentOrigin], context: nil)
        
        let keyTextBoundingRect = CGRect(x: 439.3878255208333,
                                            y: 795.5247017952324,
                                            width: 500.6121744791667,
                                            height: 95.46875)
        let keyBorderPath = UIBezierPath(roundedRect: keyTextBoundingRect.insetBy(dx: -padding, dy: -padding), cornerRadius: 20)
        
        let keyTextBackgroundLayer = CAShapeLayer()
        keyTextBackgroundLayer.path = keyBorderPath.cgPath
        keyTextBackgroundLayer.fillColor = UIColor.white.cgColor
        keyTextBackgroundLayer.shadowRadius = 7
        keyTextBackgroundLayer.shadowOpacity = 1
        keyTextBackgroundLayer.render(in: UIGraphicsGetCurrentContext()!)
        
        let keyText = generateKeyText(fontSize: 40)
        keyText.draw(with: keyTextBoundingRect, options: [.usesDeviceMetrics, .usesLineFragmentOrigin], context: nil)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension ChengJiDanMap {
    var colorForEachProvince: [Province: UIColor] {
        Dictionary(elements: Province.allCases.map { ($0, color(forProvince: $0)) })
    }
    
    private func color(forProvince province: Province) -> UIColor {
        let statuses = province.cities.map { entryDict[$0] ?? .untrodden }
        let maxStatus = TravelStatus(rawValue: statuses.map { $0.rawValue }.max() ?? 0) ?? .untrodden
        let baseColor = UIColor(named: maxStatus.debugDescription) ?? .clear
        let visitedCount = statuses.filter { $0.rawValue > 0 }.count
        let totalNumber = province.cities.count
//        let percentage = visitedCount.f / totalNumber.f
        let percentage = min(1, visitedCount.f / min(totalNumber.f, 5))
        return baseColor.withAlphaComponent(percentage)
    }
}

extension ChengJiDanMapViewController : ChengJiDanEditorViewControllerDelegate {
    func didFinishEditing(editingResult: [CityStatusPair], newName: String?) {
        guard let nonNilChengJiDan = chengJiDan else { return }
        do {
            var newChengJiDan = ChengJiDanMap(name: newName ?? nonNilChengJiDan.name, entries: editingResult)
            try DataManager.shared.updateChengJiDan(oldChengJiDan: nonNilChengJiDan, newChengJiDan: &newChengJiDan)
            chengJiDan = newChengJiDan
            updateView()
        } catch let error {
            let alert = SCLAlertView()
            alert.showError("错误", subTitle: error.localizedDescription, closeButtonTitle: "确定")
        }
    }
}
