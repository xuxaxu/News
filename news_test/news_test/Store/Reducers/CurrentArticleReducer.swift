let currentArticleReducer: (inout Article?, CurrentArticleAction) -> Void = { article, action in
    switch action {
    case .setCurrentArticle(let newArticle):
        article = newArticle
    }
}

enum CurrentArticleAction {
    case setCurrentArticle(Article?)
}
