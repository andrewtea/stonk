//
//  PositionSectionView.swift
//  Stonk
//
//  Created by Andrew Tang on 2/1/26.
//

import SwiftUI

struct PositionSectionView: View {
	let holding: Holding

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("Your Position")
				.font(.system(.title2, design: .serif, weight: .bold))

			VStack(spacing: 0) {
				PositionRow(label: "Shares", value: holding.numShares.formatted(.number.precision(.fractionLength(2))))

				Divider()

				PositionRow(label: "Avg Cost/Share", value: holding.averagePrice.formatted(.currency(code: "USD")))

				Divider()

				PositionRow(label: "Cost Basis", value: holding.costBasis.formatted(.currency(code: "USD")))

				Divider()

				PositionRow(label: "Current Value", value: holding.totalPrice.formatted(.currency(code: "USD")))

				Divider()

				HStack {
					Text("Total Gain/Loss")
						.font(.subheadline)

					Spacer()

					GainsView(gains: holding.gains)
				}
				.padding(.vertical, 8)

				if holding.previousClose != nil {
					Divider()

					HStack {
						Text("Today's Gain/Loss")
							.font(.subheadline)

						Spacer()

						GainsView(gains: holding.dailyGains)
					}
					.padding(.vertical, 8)
				}
			}
			.padding()
			.background(
				RoundedRectangle(cornerRadius: 12)
					.fill(Color(.systemGray6))
			)
		}
	}
}

struct PositionRow: View {
	let label: String
	let value: String

	var body: some View {
		HStack {
			Text(label)
				.font(.subheadline)

			Spacer()

			Text(value)
				.font(.system(.subheadline, design: .monospaced, weight: .medium))
		}
		.padding(.vertical, 8)
	}
}

#Preview {
	let holding = Holding(ticker: "AAPL", numShares: 10, lastPrice: 185.50, averagePrice: 150.00)
	holding.previousClose = 183.25

	return PositionSectionView(holding: holding)
		.padding()
}
