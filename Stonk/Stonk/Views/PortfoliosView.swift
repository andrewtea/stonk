//
//  PortfoliosView.swift
//  Stonk
//
//  Created by Andrew Tang on 12/25/25.
//

import SwiftData
import SwiftUI

struct PortfoliosView: View {
	@Environment(StonkManager.self) var manager
	@State var isAddingPortfolio: Bool = false
	
	var body: some View {
		NavigationStack {
			VStack {
				PortfolioListView() {
					// TODO: refresh
				}
				.environment(manager)

				Spacer()

				PortfoliosTotalView()
					.padding()
			}
			.navigationTitle("Portfolios")
			.toolbar {
				ToolbarItem(placement: .primaryAction) {
					Button(action: { isAddingPortfolio = true }) {
						Image(systemName: "plus")
					}
				}
			}
		}
		.sheet(isPresented: $isAddingPortfolio) {
			AddPortfolioView() { portfolio in
				manager.addPortfolio(portfolio)
				isAddingPortfolio.toggle()
			}
			.presentationDetents([.medium])
		}
	}
}

struct PortfolioListView: View {
	@Environment(StonkManager.self) var manager
	@Query(sort: \Portfolio.name) var portfolioList: [Portfolio]
	
	let onRefresh: () async -> Void
	
	var body: some View {
		if portfolioList.isEmpty {
			ContentUnavailableView {
				Label("No portfolios", systemImage: "chart.pie.fill")
			} description: {
				Text("Tap Add Portfolio to create your first portfolio!")
			}
		} else {
			List {
				ForEach(portfolioList) { portfolio in
					NavigationLink {
						HoldingsView(portfolio: portfolio)
							.environment(manager)
					} label: {
						PortfolioListItem(portfolio: portfolio)
					}
				}
			}
			.refreshable {
				await onRefresh()
			}
		}
	}
}

struct PortfolioListItem: View {
	let portfolio: Portfolio
	
	var body: some View {
		HStack(alignment: .center) {
			VStack(alignment: .leading) {
				Text(portfolio.name)
					.font(.system(.title2, design: .serif, weight: .bold))
				
				Text("\(portfolio.numHoldings) holdings")
					.font(.caption)
			}
			
			Spacer()
			
			VStack(alignment: .trailing) {
				Text(portfolio.totalValue.formatted(.currency(code: "USD")))
					.font(.system(.title2, design: .monospaced, weight: .bold))
				
				GainsView(gains: portfolio.gains)
			}
		}
	}
}

struct PortfoliosTotalView: View {
	@Query var portfolioList: [Portfolio]
	
	var body: some View {
		HStack {
			VStack(alignment: .leading) {
				Text("Net Worth")
					.font(.system(.title2, design: .serif, weight: .bold))
				
				Text("\(portfolioList.count) portfolios")
					.font(.caption)
			}
			
			Spacer()
			
			VStack(alignment: .trailing) {
				Text(portfolioList.isEmpty ? "$ ---" : portfolioList.totalValue.formatted(.currency(code: "USD")))
					.font(.system(.title2, design: .monospaced, weight: .bold))
				
				GainsView(gains: portfolioList.gains)
			}
		}
	}
}

struct AddPortfolioView: View {
	@Environment(\.dismiss) private var dismiss

	let onPortfolioAdded: (Portfolio) -> ()

	@State private var name: String = ""

	private var isValid: Bool {
		!name.isEmpty
	}

	var body: some View {
		NavigationStack {
			Form {
				Section("Portfolio") {
					TextField("Name", text: $name)
				}
			}
			.scrollContentBackground(.hidden)
			.navigationTitle("New Portfolio")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel") {
						dismiss()
					}
				}

				ToolbarItem(placement: .confirmationAction) {
					Button("Add") {
						let portfolio = Portfolio(name: name)
						onPortfolioAdded(portfolio)
					}
					.fontWeight(.semibold)
					.disabled(!isValid)
				}
			}
		}
	}
}
