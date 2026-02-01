//
//  StatisticsSectionView.swift
//  Stonk
//
//  Created by Andrew Tang on 2/1/26.
//

import SwiftUI

struct StatisticsSectionView: View {
	let holding: Holding

	private let columns = [
		GridItem(.flexible()),
		GridItem(.flexible())
	]

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("Key Statistics")
				.font(.system(.title2, design: .serif, weight: .bold))

			LazyVGrid(columns: columns, spacing: 16) {
				StatItemView(
					label: "Market Cap",
					value: formatMarketCap(holding.marketCap)
				)

				StatItemView(
					label: "P/E Ratio",
					value: formatOptional(holding.peRatio, precision: 2)
				)

				StatItemView(
					label: "Dividend Yield",
					value: formatPercent(holding.dividendYield)
				)

				StatItemView(
					label: "Beta",
					value: formatOptional(holding.beta, precision: 2)
				)

				StatItemView(
					label: "52-Week High",
					value: formatCurrency(holding.fiftyTwoWeekHigh)
				)

				StatItemView(
					label: "52-Week Low",
					value: formatCurrency(holding.fiftyTwoWeekLow)
				)

				StatItemView(
					label: "Previous Close",
					value: formatCurrency(holding.previousClose)
				)

				StatItemView(
					label: "Avg Volume",
					value: formatVolume(holding.averageVolume)
				)
			}
			.padding()
			.background(
				RoundedRectangle(cornerRadius: 12)
					.fill(Color(.systemGray6))
			)
		}
	}

	private func formatMarketCap(_ value: Double?) -> String {
		guard let value else { return "—" }

		if value >= 1_000_000_000_000 {
			return "$\((value / 1_000_000_000_000).formatted(.number.precision(.fractionLength(2))))T"
		} else if value >= 1_000_000_000 {
			return "$\((value / 1_000_000_000).formatted(.number.precision(.fractionLength(2))))B"
		} else if value >= 1_000_000 {
			return "$\((value / 1_000_000).formatted(.number.precision(.fractionLength(2))))M"
		}
		return "$\(value.formatted(.number.precision(.fractionLength(0))))"
	}

	private func formatOptional(_ value: Float?, precision: Int) -> String {
		guard let value else { return "—" }
		return value.formatted(.number.precision(.fractionLength(precision)))
	}

	private func formatPercent(_ value: Float?) -> String {
		guard let value else { return "—" }
		return "\(value.formatted(.number.precision(.fractionLength(2))))%"
	}

	private func formatCurrency(_ value: Float?) -> String {
		guard let value else { return "—" }
		return value.formatted(.currency(code: "USD"))
	}

	private func formatVolume(_ value: Int?) -> String {
		guard let value else { return "—" }

		if value >= 1_000_000 {
			return "\((Double(value) / 1_000_000).formatted(.number.precision(.fractionLength(2))))M"
		} else if value >= 1_000 {
			return "\((Double(value) / 1_000).formatted(.number.precision(.fractionLength(1))))K"
		}
		return "\(value)"
	}
}

#Preview {
	let holding = Holding(ticker: "AAPL", numShares: 10, lastPrice: 185.50, averagePrice: 150.00)
	holding.marketCap = 2_850_000_000_000
	holding.peRatio = 30.5
	holding.dividendYield = 0.52
	holding.beta = 1.25
	holding.fiftyTwoWeekHigh = 199.62
	holding.fiftyTwoWeekLow = 164.08
	holding.previousClose = 183.25
	holding.averageVolume = 54_230_000

	return StatisticsSectionView(holding: holding)
		.padding()
}
