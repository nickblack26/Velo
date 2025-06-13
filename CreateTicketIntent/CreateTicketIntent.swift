//
//  CreateTicketIntent.swift
//  CreateTicketIntent
//
//  Created by Nick Black on 6/12/25.
//

import AppIntents

struct CreateTicketIntent: AppIntent {
//    public static var parameterSummary: SummaryContent {
//
//    }
    
    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$summary) for \(\.$company) to \(\.$board) with \(\.$status)")
    }
    
    public static var title: LocalizedStringResource { "New Ticket" }
    public static var description = IntentDescription("Creates a new ticket.")
    
    @Parameter(title: "Summary")
    public var summary: String
    
    @Parameter(title: "Company", default: Company.veloExample)
    public var company: Company
    
    @Parameter(title: "Contact")
    public var contact: String?
    
    @Parameter(title: "Board")
    public var board: String?
    
    @Parameter(title: "Status")
    public var status: String?
    
    @MainActor
    func perform() async throws -> some IntentResult {
        print("performing result")
        return .result()
    }
}
