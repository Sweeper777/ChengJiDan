import UIKit
import DCTextEngine
import GoogleMobileAds

class HelpViewController: UIViewController {
    @IBOutlet var helpTextView: UITextView!
    @IBOutlet var ad: GADBannerView!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        let engine = DCTextEngine.withMarkdown()!
        
        let pictureOptions = { () -> DCTextOptions in
            let options = DCTextOptions()
            let attachment = NSTextAttachment()
            attachment.image = UIImage(systemName: "photo")!.withTintColor(self.helpTextView.tintColor)
            options.attachment = attachment
            return options
        }()
        
        let shareOptions = { () -> DCTextOptions in
            let options = DCTextOptions()
            let attachment = NSTextAttachment()
            attachment.image = UIImage(systemName: "square.and.arrow.up")!.withTintColor(self.helpTextView.tintColor)
            options.attachment = attachment
            return options
        }()
        
        let versionOptions = { () -> DCTextOptions in
            let options = DCTextOptions()
            options.replaceText = Bundle.main.appVersion
            return options
        }()
        
        engine.addPattern("<picture>", options: pictureOptions)
        engine.addPattern("<share>", options: shareOptions)
        engine.addPattern("<version>", options: versionOptions)
        
        engine.addPattern("<title> [^\n]+") { (regex, text) -> DCTextOptions? in
            let options = DCTextOptions()
            options.font = UIFont.preferredFont(forTextStyle: .largeTitle)
            options.replaceText = String(text?.dropFirst(8) ?? "")
            return options
        }
        
        guard let markdownString = try? String(contentsOfFile: Bundle.main.path(forResource: "help", ofType: "md")!) else {
            return
        }
        let attributedString = NSMutableAttributedString(attributedString: engine.parse(markdownString))
        attributedString.addAttributes([.foregroundColor: UIColor.label], range: NSRange(location: 0, length: attributedString.length))
        helpTextView.attributedText = attributedString
        
        ad.adUnitID = adUnitIdBanner
        ad.rootViewController = self
        ad.load(GADRequest())
        ad.delegate = self
    }
    
    @IBAction func doneTapped() {
        dismiss(animated: true, completion: nil)
    }
}

extension HelpViewController : GADBannerViewDelegate {
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print(error)
        bottomConstraint.constant = 8
    }
}
