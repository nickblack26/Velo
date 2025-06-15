import Foundation

struct Member: Persistable {
    static var path: String = "/system/members"
    
    var id: Int
    var identifier: String
    var firstName: String?
    var lastName: String?
    
    var name: String {
        (firstName ?? "") + " " + (lastName ?? "")
    }

    static let example: Self = .init(
        id: 310,
        identifier: "nblack",
        firstName: "Nick",
        lastName: "Black"
    )
}
