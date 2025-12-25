//
//  StonkViewModel.swift
//  Stonk
//
//  Created by Andrew Tang on 12/22/25.
//

import Foundation
import Combine

@Observable
class PortfolioViewModel {
	var service: StonkService
	var portfolioList: [Portfolio]
	var currentPortfolio: Portfolio
	
	init(service: StonkService) {
		self.service = service
		let firstPortfolio = Portfolio(name: "Portfolio 1")
		self.portfolioList = [firstPortfolio]
		self.currentPortfolio = firstPortfolio
	}
	
	func addHolding(_ newHolding: Holding) {
		guard let holding = currentPortfolio.holdings.first(where: { $0 == newHolding }) else {
			currentPortfolio.holdings.append(newHolding)
			return
		}
		
		holding.averagePrice = ((holding.numShares * holding.averagePrice + newHolding.numShares * newHolding.averagePrice) / (holding.numShares + newHolding.numShares))
		holding.numShares += newHolding.numShares
	}
	
	func updatePrices() async {
		await withTaskGroup { group in
			currentPortfolio.holdings.forEach { holding in
				group.addTask {
					let price = await self.service.getSharePrice(ticker: holding.ticker)
					await MainActor.run {
						holding.lastPrice = price
					}
				}
			}
		}
	}
}
