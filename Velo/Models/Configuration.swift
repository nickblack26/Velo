import Foundation

struct Configuration: Fetchable, Searchable {
    var id: Int
    var name: String
    var type: Reference?;
    var status: Reference?;
    var company: Reference?;
    var contact: Reference?;
    var site: Reference?;
    
    var searchValue: String {
        name
    }
    
    static var path: String = "/company/configurations"
}
