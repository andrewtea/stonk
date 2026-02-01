//
//  HoldingHeaderView.swift
//  Stonk
//
//  Created by Andrew Tang on 2/1/26.
//

import Kingfisher
import SwiftUI

struct HoldingHeaderView: View {
	let holding: Holding

	var body: some View {
		VStack(spacing: 16) {
			KFImage(URL(string: holding.imageURL))
				.placeholder {
					ProgressView()
				}
				.resizable()
				.scaledToFit()
				.frame(width: 80, height: 80)

			VStack(spacing: 4) {
				Text(holding.ticker)
					.font(.system(.title, design: .serif, weight: .bold))

				if let name = holding.name {
					Text(name)
						.font(.subheadline)
						.foregroundStyle(.secondary)
						.multilineTextAlignment(.center)
				}
			}

			VStack(spacing: 4) {
				Text(holding.lastPrice.formatted(.currency(code: "USD")))
					.font(.system(.largeTitle, design: .monospaced, weight: .bold))

				if holding.previousClose != nil {
					DailyChangeView(holding: holding)
				}
			}
		}
		.frame(maxWidth: .infinity)
		.padding(.vertical)
	}
}

struct DailyChangeView: View {
	let holding: Holding

	var body: some View {
		let isPositive = holding.dailyChange >= 0
		let color: Color = isPositive ? .green : .red
		let arrow = isPositive ? "arrow.up.right" : "arrow.down.right"

		HStack(spacing: 4) {
			Image(systemName: arrow)
				.font(.caption)

			Text(holding.dailyChange.formatted(.currency(code: "USD")))
				.font(.system(.subheadline, design: .monospaced))

			Text("(\(holding.dailyChangePercent.formatted(.number.precision(.fractionLength(2))))%)")
				.font(.system(.subheadline, design: .monospaced))
		}
		.foregroundStyle(color)
	}
}

#Preview {
	let holding = Holding(ticker: "AAPL", numShares: 10, lastPrice: 185.50, averagePrice: 150.00)
	holding.name = "Apple Inc."
	holding.previousClose = 183.25

	return HoldingHeaderView(holding: holding)
}
