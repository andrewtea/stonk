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
				
				Button(action: { isAddingPortfolio = true }) {
					Label("Add Portfolio", systemImage: "plus")
				}
				.buttonStyle(.borderedProminent)
				.padding()
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
	let onPortfolioAdded: (Portfolio) -> ()
	
	@State var name: String = ""
	
	var body: some View {
		VStack {
			Group {
				TextField("Portfolio name", text: $name)
			}
			.padding()
			.background(
				RoundedRectangle(cornerRadius: 10)
					.fill(Color.gray.opacity(0.1))
			)
			
			Spacer()
			
			Button(action: {
				let portfolio = Portfolio(name: name)
				onPortfolioAdded(portfolio)
			}) {
				Label("Add", systemImage: "plus")
			}
			.buttonStyle(.borderedProminent)
		}
		.padding()
	}
}
