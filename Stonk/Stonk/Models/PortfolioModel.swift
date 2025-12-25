//
//  PortfolioModel.swift
//  Stonk
//
//  Created by Andrew Tang on 12/24/25.
//

import Foundation
import SwiftData

@Model
class Portfolio: Hashable {
	var name: String
	var holdings: [Holding]
	
	init(name: String, holdings: [Holding] = []) {
		self.name = name
		self.holdings = holdings
	}
	
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
	
	var isEmpty: Bool {
		get { holdings.isEmpty }
	}
	
	var gains: Gains {
		get {
			let dollarGains = holdings
				.map { $0.gains.dollarAmount }
				.reduce(0, +)
			let percentGains = dollarGains / (totalValue - dollarGains) * 100
			return Gains(dollarAmount: dollarGains, percentAmount: percentGains)
		}
	}
	
	static func == (lhs: Portfolio, rhs: Portfolio) -> Bool {
		lhs.name == rhs.name
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(name)
	}
}

extension [Portfolio] {
	var totalValue: Float {
		get {
			self
				.map { $0.totalValue }
				.reduce(0, +)
		}
	}
	
	var gains: Gains {
		get {
			let dollarGains = self
				.map{ $0.gains.dollarAmount }
				.reduce(0, +)
			let percentGains = dollarGains / (totalValue - dollarGains) * 100
			return Gains(dollarAmount: dollarGains, percentAmount: percentGains)
		}
	}
}
