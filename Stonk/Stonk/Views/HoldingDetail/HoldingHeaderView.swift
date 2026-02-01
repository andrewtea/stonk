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
		}
		.frame(maxWidth: .infinity)
		.padding(.vertical)
	}
}

#Preview {
	let holding = Holding(ticker: "AAPL", numShares: 10, lastPrice: 185.50, averagePrice: 150.00)
	holding.name = "Apple Inc."

	return HoldingHeaderView(holding: holding)
}
