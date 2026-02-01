//
//  HoldingsView.swift
//  Stonk
//
//  Created by Andrew Tang on 12/21/25.
//

import Kingfisher
import SwiftUI
import SwiftData

struct HoldingsView: View {
	@Environment(StonkManager.self) var manager
	@State var isAddingHolding: Bool = false
	
	@Bindable var portfolio: Portfolio
	
	var body: some View {
		VStack {
			HoldingListView(holdingList: $portfolio.holdings, onRefresh: {
				await manager.updatePrices(for: portfolio)
			})
			.task {
				await manager.updatePrices(for: portfolio)
			}

			Spacer()

			HoldingsTotalView(portfolio: portfolio)
				.padding()
		}
		.navigationTitle(portfolio.name)
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				Button(action: { isAddingHolding = true }) {
					Image(systemName: "plus")
				}
			}
		}
		.sheet(isPresented: $isAddingHolding) {
			AddHoldingView() { holding in
				manager.addHolding(holding, to: portfolio)
				isAddingHolding.toggle()
			}
			.presentationDetents([.medium])
		}
    }
}

struct HoldingListView: View {
	@Binding var holdingList: [Holding]
	let onRefresh: () async -> Void
	
	var body: some View {
		if holdingList.isEmpty {
			ContentUnavailableView {
				Label("No holdings", systemImage: "chart.bar.fill")
			} description: {
				Text("Tap Add Holding to start building your portfolio!")
			}
		} else {
			List($holdingList, id: \.ticker, editActions: .delete) { $holding in
				NavigationLink {
					HoldingDetailView(holding: holding)
				} label: {
					HoldingListItem(holding: holding)
				}
			}
			.refreshable {
				await onRefresh()
			}
		}
	}
}

struct HoldingListItem: View {
	let holding: Holding
	
	var body: some View {
		HStack(alignment: .center) {
			KFImage(URL(string: holding.imageURL))
				.placeholder {
					ProgressView()
				}
				.resizable()
				.scaledToFit()
				.frame(width: 40, height: 40)
			
			VStack(alignment: .leading) {
				Text(holding.ticker)
					.font(.system(.title2, design: .serif, weight: .bold))
				
				Text("\(holding.numShares.formatted(.number.precision(.fractionLength(2)))) shares")
					.font(.caption)
			}
			
			Spacer()
			
			VStack(alignment: .trailing) {
				Text(holding.totalPrice.formatted(.currency(code: "USD")))
					.font(.system(.title2, design: .monospaced, weight: .bold))
				
				GainsView(gains: holding.gains)
			}
		}
	}
}

struct HoldingsTotalView: View {
	let portfolio: Portfolio
	
	var body: some View {
		HStack {
			VStack(alignment: .leading) {
				Text("Portfolio Value")
					.font(.system(.title2, design: .serif, weight: .bold))
				
				Text("\(portfolio.numHoldings) holdings")
					.font(.caption)
			}
			
			Spacer()
			
			VStack(alignment: .trailing) {
				Text(portfolio.isEmpty ? "$ ---" : portfolio.totalValue.formatted(.currency(code: "USD")))
					.font(.system(.title2, design: .monospaced, weight: .bold))
				
				GainsView(gains: portfolio.gains)
			}
		}
	}
}

struct AddHoldingView: View {
	@Environment(\.dismiss) private var dismiss

	let onHoldingAdded: (Holding) -> ()

	@State private var ticker: String = ""
	@State private var numShares: String = ""
	@State private var averagePrice: String = ""

	private var isValid: Bool {
		!ticker.isEmpty && Float(numShares) != nil && Float(averagePrice) != nil
	}

	var body: some View {
		NavigationStack {
			Form {
				Section("Ticker") {
					TextField("Symbol", text: $ticker)
						.textInputAutocapitalization(.characters)
						.autocorrectionDisabled()
				}

				Section("Position") {
					TextField("Number of shares", text: $numShares)
						.keyboardType(.decimalPad)

					TextField("Average price per share", text: $averagePrice)
						.keyboardType(.decimalPad)
				}
			}
			.scrollContentBackground(.hidden)
			.navigationTitle("Add Holding")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel") {
						dismiss()
					}
				}

				ToolbarItem(placement: .confirmationAction) {
					Button("Add") {
						let holding = Holding(
							ticker: ticker.uppercased(),
							numShares: Float(numShares) ?? 0,
							averagePrice: Float(averagePrice) ?? 0
						)
						onHoldingAdded(holding)
					}
					.fontWeight(.semibold)
					.disabled(!isValid)
				}
			}
		}
	}
}

#Preview {
	//SinglePortfolioView()
}
