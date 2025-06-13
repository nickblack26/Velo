import Foundation

struct Company: Fetchable, Searchable {
    var id: Int
    var name: String
    
    var searchValue: String {
        name
    }
    
    static var path: String = "/company/companies"
    
    static let veloExample: Self = .init(id: 250, name: "Velo IT Group")
}
