import Foundation

protocol WebViewInput: AnyObject {
    func update(with state: WebViewState)
}

enum WebViewState {
    case loading
    case error
    case success(URL)
}
