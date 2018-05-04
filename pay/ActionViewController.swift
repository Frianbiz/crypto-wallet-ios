import UIKit
import MobileCoreServices
import Geth
import web3swift
import Alamofire

class ActionViewController: UIViewController {
    
    var amount: String?;
    var to: String?;
    
    
    struct Constants {
        static let contractAddress = "0xc4a278103162f47d8aa0212644044564062b09f1"
        static let toAccountAddress = "0x39db95b4f60bd75846c46df165d9e854b3cf1b56"
        static let transferFunctionName = "transfer"
        static let transferAmount = 1
        static let gasPrice = GethNewBigInt(20000000000)!
        static let gasLimit = GethNewBigInt(4300000)!
        
        static let serverURL = "https://ropsten.infura.io/IC6bcZSzkOq3h3LDblZA"
        //static let trasferURL = "contract/send"
        //static let nonceURL = "account/getTransactionCount"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //contractAddressTextField.text = Constants.contractAddress
        //toAccountTextField.text = Constants.toAccountAddress
        //amountTextField.text = String(Constants.transferAmount)
        
        //accountAddressTextField.text = EthAccountCoordinator.default.account?.getAddress().getHex()
        
        self.parseItems { to, amount in
            print(to, amount)
        }
    }
    
    @IBAction func done() {
        guard let extensionContext = self.extensionContext else { return }
        extensionContext.completeRequest(returningItems: extensionContext.inputItems, completionHandler: nil)
    }
    
    @IBAction func payHandler() {
        
        let configuration = EthAccountConfiguration(namespace: "wallet", password: "qwerty")
        let (keystore, _) = EthAccountCoordinator.default.launch(configuration)
        
        var addressError: NSError? = nil
        let amountToTransfer = "5"
        let gethToAccountAddress: GethAddress! = GethNewAddressFromHex("0x39db95b4f60bd75846c46df165d9e854b3cf2b56", &addressError)
        guard let amount = GethBigInt.bigInt(amountToTransfer) else {
            print("Invalid amount")
            return
        }
        let transferFunction = EthFunction(name: "transfer", inputParameters: [gethToAccountAddress, amount])
        let encodedTransferFunction = web3swift.encode(transferFunction)
        
        do {
            let nonce: Int64 = 4 // Update this to valid nonce
            
            let signedTransaction = web3swift.sign(address: contractAddress, encodedFunctionData: encodedTransferFunction, nonce: nonce, gasLimit: Constants.gasLimit, gasPrice: Constants.gasPrice)
            
            if let signedTransactionData = try signedTransaction?.encodeRLP() {
                let encodedSignedTransaction = signedTransactionData.base64EncodedString()
                print("Encoded transaction sent to server \(encodedSignedTransaction)")
                
                executeContract(encodedSignedTransaction, completion: { (result, error) in
                    if let error = error {
                        print("Failed to get valid response from server \(error)")
                        return
                    }
                    guard let transactionHash = result else {
                        print("Failed to get valid result froms server")
                        return
                    }
                    
                    print("Result of transfer is \(transactionHash)")
                })
                
            } else {
                print("Failed to sign/encode")
            }
        } catch {
            print("Failed in encoding transaction ")
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



    
    
    
    // MARK:- Web API calls
    extension ActionViewController {
        
        
        /*
        
        func getNonce(_ accountAddress: String, completion: @escaping (Int64?, Error?) -> Void) {
            
            // If you have geth ethereum client connected to node you can get nonce
            /*
             let ethClient: GethEthereumClient! = GethNewEthereumClient("", &_toAddressError)!
             let context = GethNewContext()
             try ethClient.getPendingNonce(at: context, account: account.getAddress(), nonce: &nonce)
             */
            
            
            // Here we have server API which takes your account address as parameter and returns nonce
            
            let urlString = Constants.serverURL + Constants.nonceURL
            
            let parameters: Parameters = [
                "address" : accountAddress,
                ]
            
            Alamofire.request(urlString, method: .get, parameters: parameters, encoding: JSONEncoding.default).responseData { (response) in
                if let data = response.result.value, let nonce = Int64(String(describing: data)) {
                    completion(nonce, nil)
                } else {
                    // Pass appropriate error here
                    completion(nil, nil)
                }
            }
        }
 */
        
        func executeContract(_ signedTransaction: String, completion: @escaping (String?, Error?) -> Void) {
            let urlString = Constants.serverURL //+ Constants.trasferURL
            
            let parameters: Parameters = [
                "signedTx" : signedTransaction,
                ]
            
            Alamofire.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseData { (response) in
                if let data = response.result.value {
                    let transactionHash = String(describing: data)
                    completion(transactionHash, nil)
                } else {
                    // Pass appropriate error here
                    completion(nil, nil)
                }
            }
            
        }
}

