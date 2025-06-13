//
//  Ticket.swift
//  Velo
//
//  Created by Nick Black on 6/10/25.
//

import Foundation

struct Ticket: Fetchable, Searchable {
    var id: Int
    var summary: String
    var contact: Reference?
    var company: Reference?
    var status: Reference?
    var board: Reference?
    
    static let path: String = "/service/tickets"
    
    var searchValue: String {
        summary
    }
}
