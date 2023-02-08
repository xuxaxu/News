import Foundation
import CoreData
import UIKit

protocol PersistanceService: AnyObject {
    func getAllArticles(
        completion: @escaping (Result<[Article], Error>) -> Void
    )
    func postAllArticles(_ items: [Article],
                          completion: @escaping (Result<Void, Error>) -> Void)
    func getImages(completion: @escaping (Result<[URL: UIImage], Error>) -> Void)
    func postImage(_ image: UIImage,
                   url: URL,
                   completion: @escaping (Result<Void, Error>) -> Void)
    func deleteAllImages(completion: @escaping (Result<Void, Error>) -> Void)
}


final class CoreDataPersistance: PersistanceService {
    
    private var container: NSPersistentContainer
    
    init() {
        self.container = NSPersistentContainer(name: CoreDataConstants.coreDataModelName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
    
    func getAllArticles(completion: @escaping (Result<[Article], Error>) -> Void) {
        do {
            let items = try getAllArticlesToContext()
            let articleItems = items.map { getArticle($0) }
            completion(.success(articleItems))
        } catch {
            completion(.failure(error))
        }
    }
    func postAllArticles(_ items: [Article], completion: @escaping (Result<Void, Error>) -> Void) {
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: CoreDataConstants.articlesEntityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do {
            let entity = try getEntityDescription()
            try container.viewContext.execute(deleteRequest)
            for i in 0..<items.count {
                getCoreDataArticleFromArticle(items[i], i, entity: entity)
            }
            saveContext(completion: completion)
        } catch {
            completion(.failure(error))
        }
    }
    
    private func getEntityDescription() throws -> NSEntityDescription {
        guard let entity = NSEntityDescription.entity(forEntityName: CoreDataConstants.articlesEntityName,
                                                      in: container.viewContext) else {
            throw CoreDataError.noEntity(name: CoreDataConstants.articlesEntityName)
        }
        return entity
    }
    private func getCoreDataArticleFromArticle(_ item: Article, _ index: Int, entity: NSEntityDescription) {
        let managedObject = CoreDataArticle(entity: entity, insertInto: container.viewContext)
        managedObject.index = Int16(index)
        managedObject.urlToImage = item.urlToImage?.absoluteString
        managedObject.url = item.url?.absoluteString
        managedObject.date = item.date
        managedObject.title = item.title
        managedObject.description_ = item.description
        managedObject.source = item.source
    }
    private func getCoreDataImageFromImage(_ image: UIImage, _ url: URL, entity: NSEntityDescription) {
        let managedObject = CoreDataImage(entity: entity, insertInto: container.viewContext)
        managedObject.url = url.absoluteString
        managedObject.image = image.pngData()
    }
    private func saveContext(completion: (Result<Void, Error>) -> Void) {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
                completion(.success(()))
            } catch {
                container.viewContext.rollback()
                completion(.failure(error))
            }
        }
    }
    @discardableResult
    private func getAllArticlesToContext() throws -> [CoreDataArticle] {
        return try container.viewContext.fetch(CoreDataArticle.fetchRequest())
    }
    
    func getArticle(_ coreDataArticle: CoreDataArticle) -> Article {
        return Article(source: coreDataArticle.source,
                       title: coreDataArticle.title ?? "",
                       description: coreDataArticle.description,
                       image: nil,
                       date: coreDataArticle.date,
                       url:  (coreDataArticle.url == nil) ? nil : URL(string: coreDataArticle.url!),
                       urlToImage: (coreDataArticle.urlToImage == nil) ? nil : URL(string: coreDataArticle.urlToImage!))
    }
    
    func getImages(completion: @escaping (Result<[URL : UIImage], Error>) -> Void) {
        do {
            let coreDataImages = try container.viewContext.fetch(CoreDataImage.fetchRequest())
            var images = [URL: UIImage]()
            for item in coreDataImages {
                if let url = URL(string: item.url), let data = item.image {
                    images[url] = UIImage(data: data)
                }
            }
            completion(.success(images))
        } catch {
            completion(.failure(error))
        }
    }
    
    func postImage(_ image: UIImage, url: URL, completion: @escaping (Result<Void, Error>) -> Void) {
        let strUrl = url.absoluteString
        do {
            let entity = try getEntityDescription()
            if let coreDataImage = try getImageToContext(url: strUrl) {
                coreDataImage.image = image.pngData()
            } else {
                let coreDataImage = CoreDataImage(entity: entity, insertInto: container.viewContext)
            }
            saveContext(completion: completion)
        } catch {
            completion(.failure(error))
        }
    }
    
    @discardableResult
    private func getImageToContext(url: String) throws -> CoreDataImage? {
        let fetchRequest = CoreDataImage.fetchRequest()
        fetchRequest.predicate = NSPredicate(format:  "url = %@", url as CVarArg)
        let managedObjects: [NSManagedObject]
        do {
            managedObjects = try container.viewContext.fetch(fetchRequest)
        } catch {
            throw error
        }
        guard let managedObject = managedObjects.first else {
            return nil
        }
        guard let coreDataImage = managedObject as? CoreDataImage else {
            throw CoreDataError.wrongAttribute(name: "некорректный тип сущности")
        }
        return coreDataImage
    }
    
    func deleteAllImages(completion: @escaping (Result<Void, Error>) -> Void) {
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: CoreDataConstants.imagesEntityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do {
            let entity = try getEntityDescription()
            try container.viewContext.execute(deleteRequest)
            saveContext(completion: completion)
        } catch {
            completion(.failure(error))
        }
    }

}
