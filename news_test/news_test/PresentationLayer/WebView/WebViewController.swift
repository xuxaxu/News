import UIKit
import WebKit

class WebViewController: UIViewController {
    
    private var output: WebViewOutput
    
    init(output: WebViewOutput) {
        self.output = output
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let webView = WKWebView()
        webView.allowsBackForwardNavigationGestures = true
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension WebViewController: WebViewInput {
    func update(with state: WebViewState) {
        switch state {
        case .error:
            dismiss(animated: true)
        case .loading:
            break
        case .success(let url):
            guard let webView = view as? WKWebView else {
                return
            }
            webView.load(URLRequest(url: url))
        }
    }
}
