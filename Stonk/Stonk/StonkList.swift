//
//  StonkList.swift
//  Stonk
//
//  Created by Andrew Tang on 12/21/25.
//

import SwiftUI

struct StonkList: View {
	@State var viewModel: StonkViewModel = StonkViewModel()
	@State var isAddingHolding: Bool = false
	
	var body: some View {
		VStack {
			List($viewModel.holdings, id: \.ticker, editActions: [.delete]) { $holding in
				SingleHoldingView(holding: holding)
			}
			.refreshable {
				await viewModel.updatePrices()
			}
			
			Spacer()
			
			PortfolioTotalView(holdings: viewModel.holdings)
				.padding()
			
			HStack {
				Button(action: {}) {
					Label("Add portfolio", systemImage: "plus")
						.frame(maxWidth: .infinity)
				}
				.buttonStyle(.borderedProminent)
								
				Button(action: { isAddingHolding.toggle() }) {
					Label("Add holding", systemImage: "plus")
						.frame(maxWidth: .infinity)
				}
				.buttonStyle(.borderedProminent)
			}
			.padding()
		}
		.sheet(isPresented: $isAddingHolding) {
			AddHoldingView() { holding in
				Task {
					await viewModel.updatePrices()
				}
				
				viewModel.addHolding(holding)
				isAddingHolding = false
			}
			.presentationDetents([.medium])
		}
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
			
			Text(holding.totalPrice.formatted(.currency(code: "USD")))
				.font(.system(.title, design: .serif, weight: .bold))
		}
	}
}

struct PortfolioTotalView: View {
	let holdings: [Holding]
	
	var body: some View {
		let numHoldings = holdings.count
		let totalValue = holdings
			.map { $0.totalPrice }
			.reduce(0, +)
		
		HStack {
			VStack(alignment: .leading) {
				Text("Portfolio Value")
					.font(.system(.title2, design: .serif, weight: .bold))
				
				Text("\(numHoldings) holdings")
					.font(.caption)
			}
			
			Spacer()
			
			Text(totalValue.formatted(.currency(code: "USD")))
				.font(.system(.title, design: .serif, weight: .bold))
		}
	}
}

struct AddHoldingView: View {
	let onHoldingAdded: (Holding) -> ()
	
	@State var ticker: String = ""
	@State var numShares: String = ""
	
	var body: some View {
		VStack {
			Group {
				TextField("Ticker symbol", text: $ticker)
					.keyboardType(.alphabet)
				
				TextField("Number of shares", text: $numShares)
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
					numShares: Float(numShares) ?? 0
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
	StonkList()
}
