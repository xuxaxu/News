import Foundation
import CoreData
import UIKit

protocol PersistanceService: AnyObject {
    associatedtype ItemType
    func getAllItems(
        completion: @escaping (Result<[ItemType], Error>) -> Void
    )
    func postAllItems(_ items: [ItemType],
                          completion: @escaping (Result<Void, Error>) -> Void)
    func getImages(completion: @escaping (Result<[URL: UIImage], Error>) -> Void)
    func postImage(_ image: UIImage,
                   url: URL,
                   completion: @escaping (Result<Void, Error>) -> Void)
    func deleteAllImages(completion: @escaping (Result<Void, Error>) -> Void)
}


final class CoreDataPersistance<ItemType>: PersistanceService {
    
    private var container: NSPersistentContainer
    private let itemToCoreDataItem: (_ item: ItemType,
                                     _ index: Int,
                                     _ managedObject: inout CoreDataArticle) -> Void
    private let coreDataItemToItem: (_ coreDataItem: CoreDataArticle) -> ItemType
    
    init(itemToCoreDataItem: @escaping (_ item: ItemType,
                              _ index: Int,
                              _ managedObject: inout CoreDataArticle) -> Void,
         coreDataItemToItem: @escaping (_ coreDataItem: CoreDataArticle) -> ItemType) {
        self.itemToCoreDataItem = itemToCoreDataItem
        self.coreDataItemToItem = coreDataItemToItem
        self.container = NSPersistentContainer(name: CoreDataConstants.coreDataModelName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
    
    func getAllItems(completion: @escaping (Result<[ItemType], Error>) -> Void) {
        do {
            let items = try getAllItemsToContext()
            let articleItems = items.sorted(by: { $0.index < $1.index }).map { coreDataItemToItem($0) }
            completion(.success(articleItems))
        } catch {
            completion(.failure(error))
        }
    }
    func postAllItems(_ items: [ItemType], completion: @escaping (Result<Void, Error>) -> Void) {
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: CoreDataConstants.articlesEntityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do {
            let entity = try getItemsEntityDescription()
            try container.viewContext.execute(deleteRequest)
            for i in 0..<items.count {
                var managedObject = CoreDataArticle(entity: entity, insertInto: container.viewContext)
                itemToCoreDataItem(items[i], i, &managedObject)
            }
            saveContext(completion: completion)
        } catch {
            completion(.failure(error))
        }
    }
    
    private func getItemsEntityDescription() throws -> NSEntityDescription {
        guard let entity = NSEntityDescription.entity(forEntityName: CoreDataConstants.articlesEntityName,
                                                      in: container.viewContext) else {
            throw CoreDataError.noEntity(name: CoreDataConstants.articlesEntityName)
        }
        return entity
    }
    private func getImageEntityDescription() throws -> NSEntityDescription {
        guard let entity = NSEntityDescription.entity(forEntityName: CoreDataConstants.imagesEntityName,
                                                      in: container.viewContext) else {
            throw CoreDataError.noEntity(name: CoreDataConstants.imagesEntityName)
        }
        return entity
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
    private func getAllItemsToContext() throws -> [CoreDataArticle] {
        return try container.viewContext.fetch(CoreDataArticle.fetchRequest())
    }
    
    
    @discardableResult
    private func getAllImagesToContext() throws -> [CoreDataImage] {
        return try container.viewContext.fetch(CoreDataImage.fetchRequest())
    }
    func getImages(completion: @escaping (Result<[URL : UIImage], Error>) -> Void) {
        do {
            let coreDataImages = try getAllImagesToContext()
            var images = [URL: UIImage]()
            for item in coreDataImages {
                if let strUrl = item.url, let url = URL(string: strUrl), let data = item.image {
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
            let entity = try getImageEntityDescription()
            if let coreDataImage = try getImageToContext(url: strUrl) {
                coreDataImage.image = image.pngData()
            } else {
                let coreDataImage = CoreDataImage(entity: entity, insertInto: container.viewContext)
                coreDataImage.url = strUrl
                coreDataImage.image = image.pngData()
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
            try container.viewContext.execute(deleteRequest)
            saveContext(completion: completion)
        } catch {
            completion(.failure(error))
        }
    }

}
