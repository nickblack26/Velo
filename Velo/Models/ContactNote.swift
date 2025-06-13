import Foundation

struct ContactNote: Fetchable, Searchable {
    let id: Int
    let contactID: Int
    let text: String
    let type: Reference?
    let flagged: Bool?
    let enteredBy: String?
    let info: [String:String]?
    
    var searchValue: String {
        text
    }
    
    static var path: String = "/company/contacts/\(32569)/notes"

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case contactID = "contactId"
        case text = "text"
        case type = "type"
        case flagged = "flagged"
        case enteredBy = "enteredBy"
        case info = "_info"
    }
}
