import Foundation

struct Classification: Fetchable {
    var id: Int
    var name: String
    
    static var path: String = "/expense/classifications"
}
