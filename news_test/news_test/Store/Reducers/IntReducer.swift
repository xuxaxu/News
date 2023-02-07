import Foundation

let intReducer: (inout Int, PageAction) -> Void = { num, action in
    switch action {
    case .resetPage:
        num = 1
    case .incrementPage:
        num += 1
    }
}
