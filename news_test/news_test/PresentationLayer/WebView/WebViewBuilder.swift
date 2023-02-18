import Foundation
import UIKit

class WebViewBuilder {
    private let presenter: WebViewPresenter
    public let viewController: WebViewController
    
    init(getUrlAction: @escaping () -> URL?) {
        self.presenter = WebViewPresenter(getUrlAction: getUrlAction)
        self.viewController = WebViewController(output: presenter)
        presenter.view = viewController
    }
    
}
