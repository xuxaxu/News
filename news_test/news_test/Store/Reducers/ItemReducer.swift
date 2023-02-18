import Foundation

func itemReducer<Element>(_ arr: inout [Element], _ action: ItemAction<Element>) -> [Effect<ItemAction<Element>>] {
        switch action {
        case .addElement(let element):
            addElement(&arr, element)
        case .clear:
            clear(&arr)
        }
        func addElement(_ items: inout [Element], _ item: Element) {
            items.append(item)
        }
        
        func clear(_ items: inout [Element]) {
            items = []
        }
        return []
    }

public enum ItemAction<Item> {
    case addElement(Item)
    case clear
}
