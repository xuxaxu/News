public let persistanceReducer: (inout Bool, DataFromPersistanceAction) -> [Effect<DataFromPersistanceAction>] = { dataFromPersistance, action in
    switch action {
    case .setFromPersistance:
        dataFromPersistance = true
    case .setFromNet:
        dataFromPersistance = false
    }
    return []
}

public enum DataFromPersistanceAction {
    case setFromPersistance
    case setFromNet
}
