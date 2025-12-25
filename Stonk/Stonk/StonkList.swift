//
//  StonkList.swift
//  Stonk
//
//  Created by Andrew Tang on 12/21/25.
//

import SwiftUI

struct SinglePortfolioView: View {
	@State var viewModel: PortfolioViewModel = PortfolioViewModel(service: StonkService())
	@State var isAddingHolding: Bool = false
	@State var isAddingPortfolio: Bool = false
	
	var body: some View {
		NavigationStack {
			VStack {
				Picker("Test", selection: $viewModel.currentPortfolio) {
					ForEach(viewModel.portfolioList, id: \.name) { portfolio in
						Text(portfolio.name)
							.tag(portfolio)
					}
				}
				.pickerStyle(.menu)
				
				HoldingListView(holdingList: $viewModel.currentPortfolio.holdings) {
					await viewModel.updatePrices()
				}
				
				Spacer()
				
				PortfolioTotalView(portfolio: viewModel.currentPortfolio)
					.padding()
				
				PortfolioButtonBar() { action in
					switch action {
					case .addPortfolio:
						isAddingPortfolio = true
					case .addHolding:
						isAddingHolding = true
					}
				}
				.padding()
			}
		}
		.sheet(isPresented: $isAddingHolding) {
			AddHoldingView() { holding in
				viewModel.addHolding(holding)
				Task {
					await viewModel.updatePrices()
				}
				isAddingHolding.toggle()
			}
			.presentationDetents([.medium])
		}
		.sheet(isPresented: $isAddingPortfolio) {
			AddPortfolioView() { portfolio in
				viewModel.portfolioList.append(portfolio)
				viewModel.currentPortfolio = portfolio
				isAddingPortfolio.toggle()
			}
			.presentationDetents([.medium])
		}
    }
}

struct HoldingListView: View {
	@Binding var holdingList: [Holding]
	let onRefresh: () async -> ()
	
	var body: some View {
		if holdingList.isEmpty {
			ContentUnavailableView {
				Label("No holdings", systemImage: "chart.pie")
			} description: {
				Text("Tap Add Holding to start building your portfolio!")
			}
		} else {
			List($holdingList, id: \.ticker, editActions: [.delete]) { $holding in
				NavigationLink {
					HoldingDetailView(holding: holding)
				} label: {
					SingleHoldingView(holding: holding)
				}
			}
			.refreshable {
				await onRefresh()
			}
		}
	}
}

struct HoldingDetailView: View {
	let holding: Holding
	
	var body: some View {
		Text(holding.ticker)
	}
}

struct SingleHoldingView: View {
	let holding: Holding
	
	var body: some View {
		HStack(alignment: .center) {
			AsyncImage(url: URL(string: holding.imageURL)) { image in
				image
					.resizable()
					.scaledToFit()
			} placeholder: {
				ProgressView()
			}
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
					.font(.system(.title2, design: .serif, weight: .bold))
				
				GainsView(gains: holding.gains)
			}
		}
	}
}

struct PortfolioTotalView: View {
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
					.font(.system(.title2, design: .serif, weight: .bold))
				
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
				.font(.caption)
				.foregroundStyle(color)
			
			Text(gains.formatForDisplay(type: .percent))
				.font(.caption)
				.foregroundStyle(.white)
				.padding(.horizontal, 2)
				.background(RoundedRectangle(cornerRadius: 2).fill(color))
		}
	}
}

struct PortfolioButtonBar: View {
	enum ButtonAction {
		case addPortfolio
		case addHolding
	}
	
	var buttonAction: (ButtonAction) -> Void
	
	var body: some View {
		HStack {
			Button(action: { buttonAction(.addPortfolio) }) {
				Label("Add Portfolio", systemImage: "plus")
					.frame(maxWidth: .infinity)
			}
			.buttonStyle(.borderedProminent)
			
			Button(action: { buttonAction(.addHolding) }) {
				Label("Add Holding", systemImage: "plus")
					.frame(maxWidth: .infinity)
			}
			.buttonStyle(.borderedProminent)
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

#Preview {
	SinglePortfolioView()
}
