import UIKit
import DCTextEngine

class HelpViewController: UIViewController {
    @IBOutlet var helpTextView: UITextView!
    
    override func viewDidLoad() {
        let engine = DCTextEngine.withMarkdown()!
        engine.addPattern("<picture>") { _,_ in
            let options = DCTextOptions()
            options.attachment = NSTextAttachment(image: UIImage(systemName: "photo")!)
            return options
        }
        engine.addPattern("<share>") { _,_ in
            let options = DCTextOptions()
            options.attachment = NSTextAttachment(image: UIImage(systemName: "square.and.arrow.up")!)
            return options
        }
        guard let markdownString = try? String(contentsOfFile: Bundle.main.path(forResource: "help", ofType: "md")!) else {
            return
        }
        let attributedString = engine.parse(markdownString)
        helpTextView.attributedText = attributedString
    }
    
    @IBAction func doneTapped() {
        dismiss(animated: true, completion: nil)
    }
}
