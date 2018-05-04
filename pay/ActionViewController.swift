import UIKit
import MobileCoreServices
import Web3
import PromiseKit

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
        
        let web3 = Web3(rpcURL: "https://ropsten.infura.io/IC6bcZSzkOq3h3LDblZA")
        
        var hexPrivateKey = "xxx"
        
        
        let privateKey = try! EthereumPrivateKey(hexPrivateKey: hexPrivateKey)
        
        firstly {
            web3.eth.getTransactionCount(address: privateKey.address, block: .latest)
            }.then { nonce in
                Promise { seal in
                    var tx = try EthereumTransaction(
                        nonce: nonce,
                        gasPrice: EthereumQuantity(quantity: 21.gwei),
                        gasLimit: 21000,
                        to: EthereumAddress(hex: self.to!, eip55: true),
                        value: EthereumQuantity(quantity: Int(self.amount!)!.gwei),
                        chainId: 3
                    )
                    try tx.sign(with: privateKey)
                    seal.resolve(tx, nil)
                }
            }.then { tx in
                web3.eth.sendRawTransaction(transaction: tx)
            }.done { hash in
                let etherscan = "https://ropsten.etherscan.io/tx/\(hash.hex())"
                let url = URL(string: etherscan)
                
                let item = NSItemProvider(item: url as NSSecureCoding?, typeIdentifier: String(kUTTypeURL))
                
                let extensionItem = NSExtensionItem()
                extensionItem.attachments = [item]
                
                extensionContext.completeRequest(returningItems: [ extensionItem ], completionHandler: nil)
                
                print(etherscan)
            }.catch { error in
                print(error)
        }
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
