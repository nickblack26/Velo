import Foundation
import AppIntents

struct Contact: Persistable, Searchable, AppEntity, IndexedEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Contact"
    static let defaultQuery = ContactQuery()
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
    
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
        lastName: "Black"
    )
}

struct ContactQuery: EntityQuery, EntityStringQuery, EnumerableEntityQuery {
    func suggestedEntities() async throws -> [Contact] {
        try await Contact.getItems(queryItems: [
            .init(name: "conditions", value: "inactiveFlag = false"),
            .init(name: "childConditions", value: "types/id = 17 or types/id = 21"),
            .init(name: "orderBy", value: "firstName"),
            .init(name: "pageSize", value: "5"),
            .init(name: "fields", value: "id,firstName,lastName"),
        ])
    }
    
    func allEntities() async throws -> [Contact] {
        try await Contact.getItems(queryItems: [
            .init(name: "conditions", value: "inactiveFlag = false"),
            .init(name: "childConditions", value: "types/id = 17 or types/id = 21"),
            .init(name: "orderBy", value: "firstName"),
            .init(name: "pageSize", value: "1000"),
            .init(name: "fields", value: "id,firstName,lastName"),
        ])
    }
    
    func entities(matching string: String) async throws -> [Contact] {
        let query = string.split(separator: " ")
        if query.count > 1 {
            return try await Contact.getItems(queryItems: [
                .init(name: "conditions", value: "inactiveFlag = false and (firstName contains '\(query[0])' and lastName contains '\(query[1])')"),
                .init(name: "childConditions", value: "types/id = 17 or types/id = 21"),
                .init(name: "orderBy", value: "firstName"),
                .init(name: "fields", value: "id,firstName,lastName"),
            ])
        }
        return try await Contact.getItems(queryItems: [
            .init(name: "conditions", value: "inactiveFlag = false and (firstName contains '\(string)' or lastName contains '\(string)')"),
            .init(name: "childConditions", value: "types/id = 17 or types/id = 21"),
            .init(name: "orderBy", value: "firstName"),
            .init(name: "fields", value: "id,firstName,lastName"),
        ])
    }
    
    func results() async throws -> [Contact] {
        try await Contact.getItems(queryItems: [
            .init(name: "conditions", value: "inactiveFlag = false"),
            .init(name: "childConditions", value: "types/id = 17 or types/id = 21"),
            .init(name: "orderBy", value: "firstName"),
            .init(name: "fields", value: "id,firstName,lastName"),
        ])
    }
    
    func entities(for identifiers: [Contact.ID]) async throws -> [Contact] {
        try await Contact.getItems(queryItems: [
            .init(name: "conditions", value: "inactiveFlag = false and id in (\(identifiers.map({String($0)}).joined(separator: ",")))"),
            .init(name: "childConditions", value: "types/id = 17 or types/id = 21"),
            .init(name: "orderBy", value: "firstName"),
            .init(name: "fields", value: "id,firstName,lastName"),
        ])
    }
    
    func defaultResult() async -> Contact {
        Contact.nickExample
    }
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
