import CoreData

extension PersistanceService where ItemType == Article {
    static func fillCoreDataArticleFromArticle(_ item: Article, _ index: Int, _ managedObject: inout CoreDataArticle) {
        
        managedObject.index = Int16(index)
        managedObject.urlToImage = item.urlToImage?.absoluteString
        managedObject.url = item.url?.absoluteString
        managedObject.date = item.date
        managedObject.title = item.title
        managedObject.description_ = item.description
        managedObject.source = item.source
    }
    static func getArticle(_ coreDataArticle: CoreDataArticle) -> ItemType {
        return Article(source: coreDataArticle.source,
                       title: coreDataArticle.title ?? "",
                       description: coreDataArticle.description,
                       image: nil,
                       date: coreDataArticle.date,
                       url:  (coreDataArticle.url == nil) ? nil : URL(string: coreDataArticle.url!),
                       urlToImage: (coreDataArticle.urlToImage == nil) ? nil : URL(string: coreDataArticle.urlToImage!))
    }
}
