import Foundation

public let intReducer: (inout Int, PageAction) -> [Effect<PageAction>] = { num, action in
    switch action {
    case .resetPage:
        num = 0
    case .incrementPage:
        num += 1
    }
    return []
}

public enum PageAction {
    case incrementPage
    case resetPage
}
