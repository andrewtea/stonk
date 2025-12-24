//
//  StonkViewModel.swift
//  Stonk
//
//  Created by Andrew Tang on 12/22/25.
//

import Foundation
import Combine

@Observable
class StonkViewModel {
	var service: StonkService = StonkService()
	var holdings: [Holding] = []
	
	func addHolding(_ newHolding: Holding) {
		for holding in holdings {
			if holding.ticker == newHolding.ticker {
				holding.numShares += newHolding.numShares
				return
			}
		}
		
		holdings.append(newHolding)
	}
	
	func updatePrices() async {
		await withTaskGroup { group in
			holdings.forEach { holding in
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
