//
//  ExpenseReportDetailView.swift
//  Velo
//
//  Created by Nick Black on 6/14/25.
//

import SwiftUI

struct ExpenseReportDetailView: View {
    @State private var expenseEntry: ExpenseEntry?
    var expenseReport: ExpenseReport
    
    var body: some View {
        FetchableListView(
            selectedItem: $expenseEntry,
            queryItems: [
                .init(name: "conditions", value: "expenseReport/id = \(expenseReport.id)")
            ],
            itemView: { item in
                NavigationLink {
                    ExpenseEntryDetailView(id: item.id)
                } label: {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text(item.notes)
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text(item.type.name)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            Text(item.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(item.amount.formatted(.currency(code: "USD")))
                    }
                }
            }
        )
        .navigationTitle(expenseReport.searchValue)
    }
}

#Preview {
    ExpenseReportDetailView(expenseReport: .example)
}
