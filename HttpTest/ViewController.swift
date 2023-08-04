import UIKit
import TrustKit

class ViewController: UIViewController, URLSessionDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configuração do TrustKit
        let trustKitConfig: [String: Any] = [
            kTSKPinnedDomains: [
                "www.audimo.com": [
                    kTSKPublicKeyHashes: [
                        "axmGTWYycVN5oCjh3GJrxWVndLSZjypDO6evrHMwbXg=",
                        "WoiWRyIOVNa9ihaBciRSC7XHjliYS9VwUGOIud4PB18="
                    ],
                    kTSKIncludeSubdomains: true
                ]
            ]
        ]

        TrustKit.initSharedInstance(withConfiguration: trustKitConfig)

        // Prepare URL
        let url = URL(string: "https://www.audimo.com/backend/login")
        guard let requestUrl = url else { fatalError() }

        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"

        // HTTP Request Parameters which will be sent in HTTP Request Body
        let postString = "username=testeca@ubook.com&password=123mudar";

        // Set HTTP Request Body
        request.httpBody = postString.data(using: String.Encoding.utf8);

        // Perform HTTP Request
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: request) { (data, response, error) in
            // Check for Error
            if let error = error {
                print("Error took place \(error)")
                return
            }

            // Convert HTTP Response Data to a String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Response data string:\n \(dataString)")
            }
        }
        task.resume()
    }

    // URLSessionDelegate method to handle SSL authentication challenge
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if TrustKit.sharedInstance().pinningValidator.handle(challenge, completionHandler: completionHandler) == false {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
