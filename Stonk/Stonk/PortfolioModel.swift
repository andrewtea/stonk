//
//  PortfolioModel.swift
//  Stonk
//
//  Created by Andrew Tang on 12/24/25.
//

import Foundation

@Observable
class Portfolio {
	var holdings: [Holding] = []
	
	var numHoldings: Int {
		get { holdings.count }
	}
	
	var totalValue: Float {
		get {
			holdings
				.map { $0.totalPrice }
				.reduce(0, +)
		}
	}
}
