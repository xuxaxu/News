import Foundation
import UIKit

public final class Store<Value, Action>: ObservableObject {
    
    @Published public private(set) var state: Value
    
    public init(state: Value, reducer: @escaping (inout Value, Action) -> Void) {
        self.state = state
        self.reducer = reducer
    }
    
    private let reducer: (inout Value, Action) -> Void
    
    public func execute(_ action: Action) {
        reducer(&state, action)
        NotificationCenter.default.post(name: .StateChanges,
                                        object: state)
    }
}

extension Notification.Name {
    static let StateChanges = Notification.Name(
        rawValue: "com.News-test.Store.changesInMainState")
}


public func combine<Value, Action>(_ reducers: (inout Value, Action) -> Void...) -> (inout Value, Action) -> Void {
    return { state, action in
        for reducer in reducers {
            reducer(&state, action)
        }
    }
}

public func pullback<LocalValue, GlobalValue, Action>(_ reducer: @escaping (inout LocalValue, Action) -> Void,
                                       get: @escaping (GlobalValue) -> LocalValue,
                                       set: @escaping (inout GlobalValue, LocalValue) -> Void) -> (inout GlobalValue, Action) -> Void {
    return { globalValue, action in
        var localValue = get(globalValue)
        reducer(&localValue, action)
        set(&globalValue, localValue)
    }
}
