import AppIntents

struct CreateTicketIntent: AppIntent {
    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$summary) for \(\.$company) and \(\.$contact) to \(\.$board) with \(\.$status)")
    }
    
    public static var title: LocalizedStringResource { "New Ticket" }
    public static var description = IntentDescription("Creates a new ticket.")
    
    @Parameter(title: "Summary")
    public var summary: String
    
    @Parameter(title: "Company", default: Company.veloExample)
    public var company: Company
    
    @Parameter(title: "Contact", default: Contact.nickExample)
    public var contact: Contact?
    
    @Parameter(title: "CompanyEntity")
    public var companyEntity: CompanyEntity
    
    @Parameter(title: "Board", default: Board.triageExample)
    public var board: Board?
    
    @Parameter(title: "Status")
    public var status: String?
    
    @MainActor
    func perform() async throws -> some IntentResult {
        let ticket = Ticket(
            id: -1,
            summary: summary,
            company: company,
            board: board
        )
        print(try JSONEncoder().encode(ticket))
        do {
            let ticket = try await Ticket.create(data: ticket)
//            return .result(value: ticket)
        } catch {
            print(error)
//            return .result(value: error)
        }
        return .result(dialog: .init("Created Successfully"))
    }
}
