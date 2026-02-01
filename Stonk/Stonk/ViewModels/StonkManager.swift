//
//  StonkViewModel.swift
//  Stonk
//
//  Created by Andrew Tang on 12/22/25.
//

import Combine
import Foundation
import SwiftData

@Observable
class StonkManager {
	var context: ModelContext
	var service: StonkService
	
	init(context: ModelContext, service: StonkService) {
		self.context = context
		self.service = service
	}
	
	func addHolding(_ newHolding: Holding, to portfolio: Portfolio) {
		guard let holding = portfolio.holdings.first(where: { $0 == newHolding }) else {
			portfolio.holdings.append(newHolding)
			Task {
				await updatePrices(for: portfolio)
			}
			return
		}
		
		holding.averagePrice = ((holding.numShares * holding.averagePrice + newHolding.numShares * newHolding.averagePrice) / (holding.numShares + newHolding.numShares))
		holding.numShares += newHolding.numShares
	}
	
	func addPortfolio(_ newPortfolio: Portfolio) {
		context.insert(newPortfolio)
	}
	
	func updatePrices(for portfolio: Portfolio) async {
		await withTaskGroup { group in
			portfolio.holdings.forEach { holding in
				group.addTask {
					let price = await self.service.getSharePrice(ticker: holding.ticker)
					await MainActor.run {
						holding.lastPrice = price
					}
				}
			}
		}
	}
	
	func updateHoldingDetails(for holding: Holding) async {
		let response = await self.service.getHoldingDetails(ticker: holding.ticker)

		guard let response else { return }

		await MainActor.run {
			holding.name = response.name
			holding.desc = response.description
			holding.sector = response.sector
			holding.website = response.website

			// Market data
			holding.marketCap = response.marketCap
			holding.peRatio = response.peRatio
			holding.dividendYield = response.dividendYield
			holding.beta = response.beta
			holding.fiftyTwoWeekHigh = response.fiftyTwoWeekHigh
			holding.fiftyTwoWeekLow = response.fiftyTwoWeekLow
			holding.previousClose = response.previousClose
			holding.averageVolume = response.averageVolume

			// Extended company info
			holding.industry = response.industry
			holding.country = response.country
			holding.employees = response.employees
		}
	}
}
