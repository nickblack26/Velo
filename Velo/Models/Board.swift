//
//  Board.swift
//  Velo
//
//  Created by Nick Black on 6/13/25.
//

import Foundation
import AppIntents

struct Board: Persistable, Searchable, AppEntity, IndexedEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Board"
    static let defaultQuery = BoardQuery()
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
    
    var id: Int
    var name: String
    
    var searchValue: String {
        name
    }
    
    static var path: String = "/service/boards"
    
    static let triageExample: Self = .init(id: 30, name: "Triage")
}

struct BoardQuery: EntityQuery, EntityStringQuery, EnumerableEntityQuery {
    func suggestedEntities() async throws -> [Board] {
        try await Board.getItems(queryItems: [
            .init(name: "orderBy", value: "name"),
            .init(name: "pageSize", value: "1000"),
            .init(name: "fields", value: "id,name"),
        ])
    }
    
    func allEntities() async throws -> [Board] {
        try await Board.getItems(queryItems: [
            .init(name: "orderBy", value: "name"),
            .init(name: "pageSize", value: "1000"),
            .init(name: "fields", value: "id,name"),
        ])
    }
    
    func entities(matching string: String) async throws -> [Board] {
        try await Board.getItems(queryItems: [
            .init(name: "conditions", value: "name contains '\(string)'"),
            .init(name: "orderBy", value: "name"),
            .init(name: "pageSize", value: "1000"),
            .init(name: "fields", value: "id,name"),
        ])
    }
    
    func results() async throws -> [Board] {
        try await Board.getItems(queryItems: [
            .init(name: "orderBy", value: "name"),
            .init(name: "pageSize", value: "1000"),
            .init(name: "fields", value: "id,name"),
        ])
    }
    
    func entities(for identifiers: [Company.ID]) async throws -> [Board] {
        try await Board.getItems(queryItems: [
            .init(name: "conditions", value: "id in (\(identifiers.map({ String($0) }).joined(separator: ","))"),
            .init(name: "orderBy", value: "name"),
            .init(name: "pageSize", value: "1000"),
            .init(name: "fields", value: "id,name"),
        ])
    }
    
    func defaultResult() async -> Board {
        Board.triageExample
    }
}
