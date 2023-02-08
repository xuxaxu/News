import Foundation
import CoreData

public class CoreDataImage: NSManagedObject {

}

extension CoreDataImage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataImage> {
        return NSFetchRequest<CoreDataImage>(entityName: CoreDataConstants.imagesEntityName)
    }

    @NSManaged public var url: String
    @NSManaged public var image: Data?
}
