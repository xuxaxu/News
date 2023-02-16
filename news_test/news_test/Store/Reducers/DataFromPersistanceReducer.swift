public let persistanceReducer: (inout Bool, DataFromPersistaneAction) -> Void = { dataFromPersistance, action in
    switch action {
    case .setFromPersistance:
        dataFromPersistance = true
    case .setFromNet:
        dataFromPersistance = false
    }
}

public enum DataFromPersistaneAction {
    case setFromPersistance
    case setFromNet
}
