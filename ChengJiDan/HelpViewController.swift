import UIKit
import DCTextEngine

class HelpViewController: UIViewController {
    @IBOutlet var helpTextView: UITextView!
    
    override func viewDidLoad() {
        let engine = DCTextEngine.withMarkdown()!
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
