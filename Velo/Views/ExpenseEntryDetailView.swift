import SwiftUI
import PhotosUI

struct ExpenseEntryDetailView: View {
    @State private var chargeCodes: [ChargeCode] = []
    @State private var expenseTypes: [ExpenseType] = []
    @State private var paymentTypes: [PaymentType] = []
    @State private var classifications: [Classification] = []
    @State private var members: [Member] = []
    
    @State private var chargeToId: Int?
    @State private var memberToId: Int? = 310
    @State private var expenseTypeId: Int? = 47
    @State private var expensePaymentTypeId: Int? = 2
    @State private var classificationId: Int? = 2
    @State private var billableOption: ExpenseEntry.BillableOption = .Billable
    @State private var amount: Decimal = 0
    @State private var notes: String = ""
    @State private var date: Date = .now
    
    @State private var pickerItems = [PhotosPickerItem]()
    @State private var selectedImages = [Image]()
    var id: ExpenseEntry.ID
    
    init(id: ExpenseEntry.ID) {
        self.id = id
    }
    
    var body: some View {
        Form {
            Section("Overview") {
                Picker(
                    "Charge To",
                    selection: Binding(value: $chargeToId)
                ) {
                    ForEach(chargeCodes) { code in
                        Text(code.name)
                            .tag(code.id)
                    }
                }
                .task {
                    do {
                        self.chargeCodes = try await ChargeCode.getItems(
                            queryItems: [
                                .init(name: "conditions", value: "expenseEntryFlag = true"),
                                .init(name: "orderBy", value: "name"),
                                .init(name: "fields", value: "id,name")
                            ]
                        )
                    } catch {
                        print("chargeCodes error: ", error)
                    }
                }
                
                DatePicker(
                    "Date",
                    selection: $date,
                    displayedComponents: .date
                )
                
                Picker(
                    "Member",
                    selection: Binding(value: $memberToId)
                ) {
                    ForEach(members) { member in
                        Text(member.name)
                            .tag(member.id)
                    }
                }
                .task {
                    do {
                        self.members = try await Member.getItems(queryItems: [
                            .init(name: "conditions", value: "inactiveFlag = false"),
                            .init(name: "fields", value: "id,firstName,lastName,identifier"),
                            .init(name: "orderBy", value: "firstName"),
                            .init(name: "pageSize", value: "1000"),
                        ])
                    } catch {
                        print(error)
                    }
                }
            }
            
            Section("Expense Entry") {
                TextField(
                    "Amount",
                    value: $amount,
                    format: .currency(
                        code: Locale.current.currency?.identifier ?? "USD"
                    )
                )
                #if !os(macOS)
                .keyboardType(.decimalPad)
                #endif
                
                TextField(
                    "Notes",
                    text: $notes,
                    prompt: Text("Notes"),
                    axis: .vertical
                )
                .lineLimit(3, reservesSpace: true)
                
                Picker(
                    "Expense Type",
                    selection: Binding(value: $expenseTypeId)
                ) {
                    ForEach(expenseTypes) { item in
                        Text(item.name)
                            .tag(item.id)
                    }
                }
                .task {
                    do {
                        self.expenseTypes = try await ExpenseType.getItems(
                            queryItems: [
                                .init(name: "conditions", value: "inactiveFlag = false"),
                                .init(name: "orderBy", value: "name"),
                                .init(name: "fields", value: "id,name")
                            ],
                        )
                    } catch {
                        print("expenseTypes error: ", error)
                    }
                }
                
                Picker(
                    "Payment Method",
                    selection: Binding(
                        value: $expensePaymentTypeId
                    )
                ) {
                    ForEach(paymentTypes) { item in
                        Text(item.name)
                            .tag(item.id)
                    }
                }
                .task {
                    do {
                        self.paymentTypes = try await PaymentType.getItems(
                            queryItems: [
                                .init(name: "orderBy", value: "name"),
                                .init(name: "fields", value: "id,name")
                            ]
                        )
                    } catch {
                        print("expenseTypes error: ", error)
                    }
                }
                
                Picker(
                    "Classification",
                    selection: Binding(
                        value: $classificationId
                    )
                ) {
                    ForEach(classifications) { item in
                        Text(item.name)
                            .tag(item.id)
                    }
                }
                .task {
                    do {
                        self.classifications = try await Classification.getItems(
                            queryItems: [
                                .init(name: "orderBy", value: "name"),
                                .init(name: "fields", value: "id,name")
                            ]
                        )
                    } catch {
                        print("expenseTypes error: ", error)
                    }
                }
                
                Picker(
                    "Billable Option",
                    selection: $billableOption
                ) {
                    ForEach(
                        ExpenseEntry.BillableOption.allCases,
                        id: \.self
                    ) { item in
                        Text(item.rawValue)
                    }
                }
            }
            
            Section("Attachments") {
                ForEach(0..<selectedImages.count, id: \.self) { i in
                    selectedImages[i]
                        .resizable()
                        .scaledToFit()
                }
                
                PhotosPicker(selection: $pickerItems) {
                    Button("Add attachment", systemImage: "plus") {
                        
                    }
                }
            }
        }
        .navigationTitle(notes)
        .onChange(of: pickerItems) {
            Task {
                selectedImages.removeAll()
                
                for item in pickerItems {
                    if let loadedImage = try await item.loadTransferable(type: Image.self) {
                        selectedImages.append(loadedImage)
                    }
                }
            }
        }
        .task {
            do {
                let entry = try await ExpenseEntry.getItem(id: id)
                
                self.chargeToId = entry.chargeToId
                self.memberToId = entry.member?.id
                self.expenseTypeId = entry.type.id
                self.expensePaymentTypeId = entry.paymentMethod?.id
                self.classificationId = entry.classification?.id
                self.amount = entry.amount
                self.billableOption = entry.billableOption ?? .Billable
                self.notes = entry.notes
                self.date = entry.date
                
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ExpenseEntryDetailView(id: 8194)
    }
}

extension Binding where Value == Int {
    init(value: Binding<Int?>, defaultValue: Int? = nil) {
        self.init {
            value.wrappedValue ?? defaultValue ?? 1
        } set: { newValue in
            value.wrappedValue = newValue
        }
    }
    
    init(value: Binding<Int?>?, defaultValue: Int? = nil) {
        self.init {
            value?.wrappedValue ?? defaultValue ?? 1
        } set: { newValue in
            value?.wrappedValue = newValue
        }
    }
}


struct FetchablePickerView<Item: Persistable, Content: View>: View {
    @State private var isLoading: Bool = false
    @State private var items: [Item] = []
    
    @State private var selectedItem: Item.ID?
    
    var queryItems: [URLQueryItem]?
    var titleKey: String
    
    @ViewBuilder var itemView: (Item) -> Content
    
    init(
        titleKey: String,
        selectedItem: Item.ID?,
        queryItems: [URLQueryItem]? = nil,
        @ViewBuilder itemView: @escaping (Item) -> Content
    ) {
        self._selectedItem = .init(initialValue: selectedItem)
        self.itemView = itemView
        self.queryItems = queryItems
        self.titleKey = titleKey
    }
    
    var body: some View {
        Picker(
            titleKey,
            selection: Binding(
                get: {
                    self.selectedItem
                },
                set: { newValue in
                    self.selectedItem = newValue
                }
            )
        ) {
            ForEach(items) { item in
                itemView(item)
                    .tag(item.id)
            }
        }
        .disabled(self.isLoading)
        .task {
            self.isLoading = true
            do {
                self.items = try await Item.getItems(queryItems: queryItems)
            } catch {
                print(error)
            }
            self.isLoading = false
        }
    }
}
