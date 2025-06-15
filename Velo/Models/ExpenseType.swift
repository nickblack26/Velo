import Foundation

struct ExpenseType: Fetchable {
    var id: Int
    var name: String
    
    static var path: String = "/expense/types"
}
