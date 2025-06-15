import Foundation

struct PaymentType: Fetchable {
    var id: Int
    var name: String
    
    static var path: String = "/expense/paymentTypes"
}
