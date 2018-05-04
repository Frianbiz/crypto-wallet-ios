import UIKit
import MobileCoreServices

class ViewController: UIViewController {

    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    
    @IBAction func payHandler() {
        guard let json = self.serialize() else { return }
        
        let vc = UIActivityViewController(activityItems: [json], applicationActivities: [])
        vc.completionWithItemsHandler =
            { (activityType, completed, returnedItems, error) in
                guard
                    let returnedItems = returnedItems,
                    returnedItems.count > 0,
                    let textItem = returnedItems.first as? NSExtensionItem,
                    let textItemProvider = textItem.attachments?.first as? NSItemProvider,
                    textItemProvider.hasItemConformingToTypeIdentifier(String(kUTTypeURL))
                    else { return }
                
                textItemProvider.loadItem(forTypeIdentifier: String(kUTTypeURL), options: nil, completionHandler: { (result, error) in
                    if let url = result as? URL {
                        self.showSuccessAlert(url: url)
                    }
                })
        }
        present(vc, animated: true, completion: nil)
    }
    
    func showSuccessAlert(url: URL) {
        let alert = UIAlertController(
            title: "Yeah !",
            message: "La transaction a été effectuée",
            preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Bien monseigneur", style: .default))
        alert.addAction(UIAlertAction(title: "Voir sur etherscan", style: .default) { _ in
            UIApplication.shared.open(url)
            }
        )
        self.present(alert, animated: true, completion: nil)
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

