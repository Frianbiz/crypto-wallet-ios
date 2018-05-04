import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    
    @IBAction func payHandler() {
        guard let json = self.serialize() else { return }
        
        let vc = UIActivityViewController(activityItems: [json], applicationActivities: [])
        vc.completionWithItemsHandler =
            { (activityType, completed, returnedItems, error) in
                print(" >> ", activityType, completed, returnedItems, error)
        }
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

