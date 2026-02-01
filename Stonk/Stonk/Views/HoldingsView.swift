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
		NavigationStack {
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
				
				Button(action: { isAddingHolding = true }) {
					Label("Add Holding", systemImage: "plus")
				}
				.buttonStyle(.borderedProminent)
				.padding()
			}
		}
		.sheet(isPresented: $isAddingHolding) {
			AddHoldingView() { holding in
				manager.addHolding(holding, to: portfolio)
				isAddingHolding.toggle()
			}
			.presentationDetents([.medium])
		}
		.navigationTitle(portfolio.name)
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

struct GainsView: View {
	let gains: Gains
	
	var body: some View {
		let color: Color = gains.isPositive ? .green : .red
		
		HStack {
			Spacer()
			
			Text(gains.formatForDisplay(type: .dollar))
				.font(.system(.caption, design: .monospaced))
				.foregroundStyle(color)
			
			Text(gains.formatForDisplay(type: .percent))
				.font(.system(.caption, design: .monospaced))
				.foregroundStyle(.white)
				.padding(.horizontal, 2)
				.background(RoundedRectangle(cornerRadius: 2).fill(color))
		}
	}
}

struct AddHoldingView: View {
	let onHoldingAdded: (Holding) -> ()
	
	@State var ticker: String = ""
	@State var numShares: String = ""
	@State var averagePrice: String = ""
	
	var body: some View {
		VStack {
			Group {
				TextField("Ticker symbol", text: $ticker)
					.keyboardType(.alphabet)
				
				TextField("Number of shares", text: $numShares)
					.keyboardType(.decimalPad)
				
				TextField("Average price per share", text: $averagePrice)
					.keyboardType(.decimalPad)
			}
			.padding()
			.background(
				RoundedRectangle(cornerRadius: 10)
					.fill(Color.gray.opacity(0.1))
			)
			
			Spacer()
			
			Button(action: {
				let holding = Holding(
					ticker: ticker.uppercased(),
					numShares: Float(numShares) ?? 0,
					averagePrice: Float(averagePrice) ?? 0
				)
				onHoldingAdded(holding)
			}) {
				Label("Add", systemImage: "plus")
			}
			.buttonStyle(.borderedProminent)
		}
		.padding()
	}
}

#Preview {
	//SinglePortfolioView()
}
