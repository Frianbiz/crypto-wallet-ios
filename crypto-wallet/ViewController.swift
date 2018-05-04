import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    
    @IBAction func payHandler() {
        
        guard let json = self.serialize() else { return }
        
        let vc = UIActivityViewController(activityItems: [json], applicationActivities: [])
        vc.excludedActivityTypes = [
            .postToFacebook,
            .postToTwitter,
            .postToWeibo,
            .message,
            .mail,
            .print,
            .copyToPasteboard,
            .assignToContact,
            .saveToCameraRoll,
            .addToReadingList,
            .postToFlickr,
            .postToVimeo,
            .postToTencentWeibo,
            .airDrop,
            .openInIBooks,
            .markupAsPDF
        ]
        
        present(vc, animated: true, completion: nil)
    }
    
    func serialize() -> String? {
        var json: String?
        do {
            let item: Dictionary<String, String> = [
                "amount": self.amountTextField.text ?? "0",
                "to": self.toTextField.text ?? "0x000"
            ]
            
            let jsonData = try JSONSerialization.data(withJSONObject: item)
            
            json = String(data: jsonData, encoding: String.Encoding.utf8)
        } catch {
            
        }
        return json
    }

}

