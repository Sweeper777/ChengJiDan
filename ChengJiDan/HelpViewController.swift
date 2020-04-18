import UIKit
import DCTextEngine

class HelpViewController: UIViewController {
    @IBOutlet var helpTextView: UITextView!
    
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
        
        
        engine.addPattern("<picture>", options: pictureOptions)
        engine.addPattern("<share>", options: shareOptions)
        guard let markdownString = try? String(contentsOfFile: Bundle.main.path(forResource: "help", ofType: "md")!) else {
            return
        }
        let attributedString = NSMutableAttributedString(attributedString: engine.parse(markdownString))
        attributedString.addAttributes([.foregroundColor: UIColor.label], range: NSRange(location: 0, length: attributedString.length))
        helpTextView.attributedText = attributedString
    }
    
    @IBAction func doneTapped() {
        dismiss(animated: true, completion: nil)
    }
}
