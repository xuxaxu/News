import Foundation

public let intReducer: (inout Int, PageAction) -> Void = { num, action in
    switch action {
    case .resetPage:
        num = 0
    case .incrementPage:
        num += 1
    }
}

public enum PageAction {
    case incrementPage
    case resetPage
}
