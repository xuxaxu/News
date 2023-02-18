let currentArticleReducer: (inout Article?, CurrentArticleAction) -> [Effect<CurrentArticleAction>] = { article, action in
    switch action {
    case .setCurrentArticle(let newArticle):
        article = newArticle
    }
    return []
}

enum CurrentArticleAction {
    case setCurrentArticle(Article?)
}
