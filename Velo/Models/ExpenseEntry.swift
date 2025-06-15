import Foundation

struct ExpenseEntry: Persistable, Searchable {
    var id: Int
    var expenseReport: ExpenseReport
    var type: Reference
    var member: Member?
    var amount: Decimal
    var notes: String
    var date: Date
    var chargeToId: Int?
    var chargeToType: ChargeType?
    var billableOption: BillableOption?
    var paymentMethod: PaymentType?
    var classification: Classification?
    
    static var path: String = "/expense/entries"
    
    var searchValue: String {
        notes
    }
    
    enum ChargeType: String, Codable {
        case Company,
             ServiceTicket,
             ProjectTicket,
             ChargeCode,
             Activity
    }
    
    enum BillableOption: String, CaseIterable, Codable {
        case Billable,
             DoNotBill,
             NoCharge,
             NoDefault
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.expenseReport = try container.decode(ExpenseReport.self, forKey: .expenseReport)
        self.type = try container.decode(Reference.self, forKey: .type)
        self.member = try container.decodeIfPresent(Member.self, forKey: .member)
        self.amount = try container.decode(Decimal.self, forKey: .amount)
        self.notes = try container.decode(String.self, forKey: .notes)
        self.chargeToId = try container.decodeIfPresent(Int.self, forKey: .chargeToId)
        self.chargeToType = try container.decodeIfPresent(ExpenseEntry.ChargeType.self, forKey: .chargeToType)
        self.billableOption = try container.decodeIfPresent(ExpenseEntry.BillableOption.self, forKey: .billableOption)
        self.paymentMethod = try container.decodeIfPresent(PaymentType.self, forKey: .paymentMethod)
        self.classification = try container.decodeIfPresent(Classification.self, forKey: .classification)
        
        let isoFormatter = ISO8601DateFormatter()
        self.date = isoFormatter.date(from: try container.decode(String.self, forKey: .date)) ?? .now
    }
}
