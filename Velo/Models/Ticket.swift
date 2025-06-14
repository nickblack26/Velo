import Foundation

struct Ticket: Persistable, Searchable {
    var id: Int
    var summary: String
    
    var contact: Contact?
    var company: Company?
    var board: Board?
    
    var status: Reference?
    
    static let path: String = "/service/tickets"
    
    var searchValue: String {
        summary
    }
}
