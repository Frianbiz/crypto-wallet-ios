import UIKit
import MobileCoreServices
import Web3
import PromiseKit

class ActionViewController: UIViewController {

    var amount: String?;
    var to: String?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.parseItems { to, amount in
            print(to, amount)
        }
    }
    
    @IBAction func done() {
        guard let extensionContext = self.extensionContext else { return }
        extensionContext.completeRequest(returningItems: extensionContext.inputItems, completionHandler: nil)
    }
    
    @IBAction func payHandler() {
        let web3 = Web3(rpcURL: "https://ropsten.infura.io/IC6bcZSzkOq3h3LDblZA")
        
        var hexPrivateKey = "xxx"
        var toHex = "xxx"
        
        let privateKey = try! EthereumPrivateKey(hexPrivateKey: hexPrivateKey)
        
        firstly {
            web3.eth.getTransactionCount(address: privateKey.address, block: .latest)
            }.then { nonce in
                Promise { seal in
                    var tx = try EthereumTransaction(
                        nonce: nonce,
                        gasPrice: EthereumQuantity(quantity: 21.gwei),
                        gasLimit: 21000,
                        to: EthereumAddress(hex: toHex, eip55: true),
                        value: EthereumQuantity(quantity: 100.gwei),
                        chainId: 3
                    )
                    try tx.sign(with: privateKey)
                    seal.resolve(tx, nil)
                }
            }.then { tx in
                web3.eth.sendRawTransaction(transaction: tx)
            }.done { hash in
                let etherscan = "https://ropsten.etherscan.io/tx/\(hash.hex())"
                print(etherscan)
            }.catch { error in
                print(error)
        }
    }
    
    func parseItems(completion: @escaping (String, String) -> Void) {
        guard let items = self.extensionContext?.inputItems as? [NSExtensionItem] else { return }
        
        for item in items {
            if let itemProviders = item.attachments as? [NSItemProvider] {
                for itemProvider in itemProviders {
                    if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeText as String) {
                        itemProvider.loadItem(forTypeIdentifier: kUTTypeText as String, options: nil, completionHandler: { (result, error) -> Void in
                            if let jsonString = result as? String {
                                do {
                                    if let data = jsonString.data(using: .utf8),
                                        let json = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? Dictionary<String, String> {
                                        
                                        if let to = json["to"], let amount = json["amount"] {
                                            completion(to, amount)
                                        }
                                    }
                                } catch {
                                    print(error)
                                }
                            }
                        })
                    }
                }
            }
        }
    }
}
