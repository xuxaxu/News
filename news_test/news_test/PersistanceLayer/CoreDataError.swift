import Foundation

enum CoreDataError: Error {
    case noEntity(name: String)
    case wrongAttribute(name: String)
    case noObjects(condition: String)
    var localizedDescription: String {
        switch self {
        case .noEntity(let name):
            return "сущности \(name) нет в CoreData"
        case .wrongAttribute(let name):
            return "некорректное имя или значение поля \(name) в CoreData"
        case .noObjects(let condition):
            return "нет объектов в CoreData, удовлетворяющих \(condition)"
        }
    }
}
