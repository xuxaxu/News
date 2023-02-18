import Foundation

class WebViewPresenter: WebViewOutput {
    
    public weak var view: WebViewInput? {
        didSet {
            view?.update(with: .loading)
        }
    }
    private var getUrlAction: () -> URL?
    
    init(getUrlAction: @escaping () -> URL?) {
        self.getUrlAction = getUrlAction
    }
    func getData() {
        if let url = getUrlAction() {
            view?.update(with: .success(url))
        }
    }
}
