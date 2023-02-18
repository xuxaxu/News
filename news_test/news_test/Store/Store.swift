import Foundation
import UIKit

public final class Store<Value, Action>: ObservableObject {
    
    @Published public private(set) var state: Value {
        willSet {
            NotificationCenter.default.post(name: .StateChanges,
                                            object: newValue)
        }
    }
    private var cancellable: Cancellable?
    
    public init(state: Value, reducer: @escaping Reducer<Value, Action>) {
        self.state = state
        self.reducer = reducer
    }
    
    private let reducer: Reducer<Value, Action>
    
    public func send(_ action: Action) {
        let effects = reducer(&state, action)
        for effect in effects {
            if let actionEffect = effect() {
                self.send(actionEffect)
            }
        }
    }
    
    func view<LocalValue>(_ f: @escaping (Value) -> LocalValue) -> Store<LocalValue, Action> {
        let localStore = Store<LocalValue, Action>(state: f(self.state),
                                         reducer: { localValue, action in
            self.send(action)
            localValue = f(self.state)
            return []
        })
        localStore.cancellable = self.$state.sink { [weak localStore] newValue in
            localStore?.state = f(newValue)
        } as? any Cancellable
        return localStore
    }
}

extension Notification.Name {
    static let StateChanges = Notification.Name(
        rawValue: "com.News-test.Store.changesInMainState")
}


public func combine<Value, Action>(_ reducers: Reducer<Value, Action>...) -> Reducer<Value, Action> {
    return { state, action in
        let effects = reducers.flatMap{ $0(&state, action) }
        return effects
    }
}

public func pullback<LocalValue, GlobalValue, Action>(_ reducer: @escaping Reducer<LocalValue, Action>,
                                       get: @escaping (GlobalValue) -> LocalValue,
                                       set: @escaping (inout GlobalValue, LocalValue) -> Void) -> Reducer<GlobalValue, Action> {
    return { globalValue, action in
        var localValue = get(globalValue)
        let effect = reducer(&localValue, action)
        set(&globalValue, localValue)
        return effect
    }
}

public typealias Effect<Action> = () -> Action?

public typealias Reducer<Value, Action> = (inout Value, Action) -> [Effect<Action>]
