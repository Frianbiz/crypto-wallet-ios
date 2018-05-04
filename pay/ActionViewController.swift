import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {

    var amount: String?
    var to: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.parseItems { to, amount in
            self.to = to
            self.amount = amount
        }
    }
    
    @IBAction func doneHandler() {
        guard let extensionContext = self.extensionContext else { return }
        extensionContext.completeRequest(returningItems: nil, completionHandler: nil)
    }
    
    @IBAction func payHandler() {
        guard let extensionContext = self.extensionContext else { return }
        
        let url = URL(string: "https://ropsten.etherscan.io/tx/0xb2c34d9cffcd0e45c4f7d17dc9cd82c2ce3c3f800e5aa53a3b897b70a004e429")
        let item = NSItemProvider(item: url as NSSecureCoding?, typeIdentifier: String(kUTTypeURL))
        
        let extensionItem = NSExtensionItem()
        extensionItem.attachments = [item]
        
        extensionContext.completeRequest(returningItems: [ extensionItem ], completionHandler: nil)

    }
    
    func parseItems(completion: @escaping (String, String) -> Void) {
        self.extensionContext?.inputItems
            .compactMap({ $0 as? NSExtensionItem})
            .compactMap({ $0.attachments as? [NSItemProvider] })
            .compactMap({ $0 })
            .first?
            .first?
            .loadItem(forTypeIdentifier: String(kUTTypeText), options: nil) { (result, error) in
                do {
                    if let jsonString = result as? String,
                        let data = jsonString.data(using: .utf8),
                        let json = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? Dictionary<String, String>,
                        let to = json["to"],
                        let amount = json["amount"] {
                        completion(to, amount)
                    }
                } catch {
                    print(error)
                }
        }
    }
}
