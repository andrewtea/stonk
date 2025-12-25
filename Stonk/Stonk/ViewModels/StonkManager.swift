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
}
