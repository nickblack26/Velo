import Foundation
import AppIntents

struct Company: Fetchable, Searchable, AppEntity, IndexedEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Company"
    static let defaultQuery = CompanyQuery()
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
    
    var id: Int
    var name: String
    
    var searchValue: String {
        name
    }
    
    static var path: String = "/company/companies"
    
    static let veloExample: Self = .init(id: 250, name: "Velo IT Group")
}


struct CompanyQuery: EntityQuery, EntityStringQuery, EnumerableEntityQuery {
    init() {
        print("Company Query")
    }
    
    func suggestedEntities() async throws -> [Company] {
        print("suggested entities")
        return try await Company.getItems(queryItems: [
            .init(name: "conditions", value: "status/name = 'Active' and deletedFlag = false"),
            .init(name: "childConditions", value: "types/id = 1"),
            .init(name: "orderBy", value: "name"),
            .init(name: "pageSize", value: "5")
//            .init(name: "fields", value: "id,name,identifier,phoneNumber,territory"),
        ])
    }
    
    func allEntities() async throws -> [Company] {
        print("All entities")
        return try await Company.getItems(queryItems: [
            .init(name: "conditions", value: "status/name = 'Active' and deletedFlag = false"),
            .init(name: "childConditions", value: "types/id = 1"),
            .init(name: "orderBy", value: "name"),
//            .init(name: "fields", value: "id,name,identifier,phoneNumber,territory"),
        ])
    }
    
    func entities(matching string: String) async throws -> [Company] {
        print(string)
        return try await Company.getItems(queryItems: [
            .init(name: "conditions", value: "status/name = 'Active' and deletedFlag = false and (name contains \(string) or identifier contains \(string))"),
            .init(name: "childConditions", value: "types/id = 1"),
            .init(name: "orderBy", value: "name"),
//            .init(name: "fields", value: "id,name,identifier,phoneNumber,territory"),
        ])
    }
    
    func results() async throws -> [Company] {
        print("results()")
        return try await Company.getItems(queryItems: [
            .init(name: "conditions", value: "status/name = 'Active' and deletedFlag = false"),
            .init(name: "childConditions", value: "types/id = 1"),
            .init(name: "orderBy", value: "name"),
//            .init(name: "fields", value: "id,name,identifier,phoneNumber,territory"),
        ])
    }
    
    func entities(for identifiers: [Company.ID]) async throws -> [Company] {
        print(identifiers)
        return try await Company.getItems(queryItems: [
            .init(name: "conditions", value: "status/name = 'Active' and deletedFlag = false"),
            .init(name: "childConditions", value: "types/id = 1"),
            .init(name: "orderBy", value: "name"),
//            .init(name: "fields", value: "id,name,identifier,phoneNumber,territory"),
        ])
    }
    
    func defaultResult() async -> Company {
        Company.veloExample
    }
}
