import Foundation
import AppIntents

struct Company: Persistable, Searchable, AppEntity, IndexedEntity {
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

struct CompanyEntity: AppEntity {
    static let defaultQuery = CompanyEntityQuery()
        
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Search Request"
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(company.name) tickets search request")
    }
    
    var id: String
    
    @Property var company: Company
}

struct CompanyEntityQuery: EntityQuery {
    func entities(for identifiers: [CompanyEntity.ID]) async throws -> [CompanyEntity] {
        var results: [CompanyEntity] = []
        for identifier in identifiers {
//            guard let request = await searchEngine.requests[identifier] else { continue }

//            results.append(request)
        }

        return results
    }

}

struct CompanyQuery: EntityQuery, EntityStringQuery, EnumerableEntityQuery {
    func suggestedEntities() async throws -> [Company] {try await Company.getItems(queryItems: [
        .init(name: "conditions", value: "status/name = 'Active' and deletedFlag = false"),
        .init(name: "childConditions", value: "types/id = 1"),
        .init(name: "orderBy", value: "name"),
        .init(name: "pageSize", value: "5"),
        .init(name: "fields", value: "id,name"),
    ])
    }
    
    func allEntities() async throws -> [Company] {
        try await Company.getItems(queryItems: [
            .init(name: "conditions", value: "status/name = 'Active' and deletedFlag = false"),
            .init(name: "childConditions", value: "types/id = 1"),
            .init(name: "orderBy", value: "name"),
            .init(name: "fields", value: "id,name"),
        ])
    }
    
    func entities(matching string: String) async throws -> [Company] {
        try await Company.getItems(queryItems: [
            .init(name: "conditions", value: "status/name = 'Active' and deletedFlag = false and (name contains '\(string)' or identifier contains '\(string)')"),
            .init(name: "childConditions", value: "types/id = 1"),
            .init(name: "orderBy", value: "name"),
            .init(name: "fields", value: "id,name"),
        ])
    }
    
    func results() async throws -> [Company] {
        try await Company.getItems(queryItems: [
            .init(name: "conditions", value: "status/name = 'Active' and deletedFlag = false"),
            .init(name: "childConditions", value: "types/id = 1"),
            .init(name: "orderBy", value: "name"),
            .init(name: "fields", value: "id,name"),
        ])
    }
    
    func entities(for identifiers: [Company.ID]) async throws -> [Company] {
        try await Company.getItems(queryItems: [
            .init(name: "conditions", value: "status/name = 'Active' and deletedFlag = false"),
            .init(name: "childConditions", value: "types/id = 1"),
            .init(name: "orderBy", value: "name"),
            .init(name: "fields", value: "id,name"),
        ])
    }
    
    func defaultResult() async -> Company {
        Company.veloExample
    }
}
