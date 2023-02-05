import Foundation

protocol ArticleNetworkParser {
    func parse(article: NetworkArticle) -> Article?
}

class ArticleNetworkParserImp: ArticleNetworkParser {
    func parse(article: NetworkArticle) -> Article? {
        guard let title = article.title else {
            return nil
        }
        let date = Date()
        let url = (article.url == nil) ? nil : URL(string: article.url!)
        var articleDomain = Article(source: article.source?.name,
                                    title: title,
                                    description: article.description,
                                    image: nil,
                                    date: date,
                                    url: url)
        return articleDomain
    }
}
