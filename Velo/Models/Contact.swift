import Foundation

struct Contact: Fetchable, Searchable {
    var id: Int
    var firstName: String
    var lastName: String?
    var communicationItems: [CommunicationItem]?
    var customFields: [CustomField]?
    
    var name: String {
        firstName + " " + (lastName ?? "")
    }
    
    var searchValue: String {
        firstName + " " + (lastName ?? "")
    }
    
    static var path: String = "/company/contacts"
    
    static let nickExample: Self = .init(
        id: 32569,
        firstName: "Nick",
        lastName: "Velo IT Group"
    )
}

struct Reference: Identifiable, Codable, Hashable {
    var id: Int
    var name: String
}

struct CommunicationItem: Identifiable, Codable, Hashable {
    var id: Int
    var type: Reference
    var value: String
    var contactId: Int?
    var defaultFlag: Bool
    var domain: String?
    var communicationType: String
}

struct CustomField: Identifiable, Codable, Hashable {
    var id: Int
    var caption: String
    var type: String
    var numberOfDecimals: Int
}
