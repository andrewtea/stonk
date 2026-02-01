//
//  HoldingDetailView.swift
//  Stonk
//
//  Created by Andrew Tang on 1/4/26.
//

import Foundation
import SwiftUI

struct HoldingDetailView: View {
	@Environment(StonkManager.self) var manager
	let holding: Holding

	@State private var isLoading = true
	
	var hasCompanyInfo: Bool {
		get {
			holding.sector != nil ||
			holding.industry != nil ||
			holding.country != nil ||
			holding.website != nil
		}
	}

	var body: some View {
		ScrollView {
			VStack(spacing: 24) {
				HoldingHeaderView(holding: holding)

				PositionSectionView(holding: holding)

				StatisticsSectionView(holding: holding)

				if hasCompanyInfo {
					CompanyInfoSectionView(holding: holding)
				}

				if let description = holding.desc {
					AboutSectionView(description: description)
				}
			}
			.padding()
			.redacted(reason: isLoading ? .placeholder : [])
		}
		.scrollIndicators(.never)
		.refreshable {
			await manager.updateHoldingDetails(for: holding)
		}
		.task {
			await manager.updateHoldingDetails(for: holding)
			isLoading = false
		}
	}
}

#Preview {
	let holding = Holding(ticker: "AAPL", numShares: 10, lastPrice: 185.50, averagePrice: 150.00)
	holding.name = "Apple Inc."
	holding.desc = "Apple Inc. designs, manufactures, and markets smartphones, personal computers, tablets, wearables, and accessories worldwide."
	holding.sector = "Technology"
	holding.industry = "Consumer Electronics"
	holding.website = "https://www.apple.com"
	holding.country = "United States"
	holding.employees = 164000
	holding.previousClose = 183.25
	holding.marketCap = 2_850_000_000_000
	holding.peRatio = 30.5
	holding.dividendYield = 0.52
	holding.beta = 1.25
	holding.fiftyTwoWeekHigh = 199.62
	holding.fiftyTwoWeekLow = 164.08
	holding.averageVolume = 54_230_000

	return NavigationStack {
		HoldingDetailView(holding: holding)
	}
}
