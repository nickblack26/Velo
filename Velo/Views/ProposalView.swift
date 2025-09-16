//
//  ProposalView.swift
//  Velo
//
//  Created by Nick Black on 9/12/25.
//

import SwiftUI

fileprivate enum Tab: String, CaseIterable {
	case overview, workplan, products
	
	var icon: String {
		switch self {
			case .overview:
				""
			case .workplan:
				"checklist"
			case .products:
				"bag"
		}
	}
}

struct ProposalView: View {
	@State private var selectedTab: Tab = .overview
	
    var body: some View {
		NavigationSplitView {
			List(
				Tab.allCases,
				id: \.self,
				selection: $selectedTab
			) { tab in
				NavigationLink(value: tab) {
					Label(tab.rawValue, systemImage: tab.icon)
				}
			}
		} detail: {
			switch selectedTab {
				case .overview:
					EmptyView()
				case .workplan:
					EmptyView()
				case .products:
					EmptyView()
			}
		}
    }
}

#Preview {
    ProposalView()
}
