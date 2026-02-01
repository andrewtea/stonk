//
//  HoldingModel.swift
//  Stonk
//
//  Created by Andrew Tang on 12/22/25.
//

import Foundation
import SwiftData

@Model
class Holding: Hashable {
	var ticker: String
	var numShares: Float
	var lastPrice: Float
	var averagePrice: Float
	var name: String?
	var desc: String?
	var sector: String?
	var website: String?
	
	var totalPrice: Float {
		get { numShares * lastPrice }
	}
	
	var costBasis: Float {
		get { numShares * averagePrice }
	}
	
	var imageURL: String {
		get { "http://localhost:8000/logos/\(ticker)" }
	}
	
	var gains: Gains {
		get {
			let dollarGains = totalPrice - costBasis
			let percentGains = dollarGains / (totalPrice - dollarGains) * 100
			return Gains(dollarAmount: dollarGains, percentAmount: percentGains)
		}
	}
	
	init(ticker: String, numShares: Float, lastPrice: Float = 0, averagePrice: Float = 0) {
		self.ticker = ticker
		self.numShares = numShares
		self.lastPrice = lastPrice
		self.averagePrice = averagePrice
	}
	
	static func == (lhs: Holding, rhs: Holding) -> Bool {
		lhs.ticker == rhs.ticker
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(ticker)
	}
}

struct Gains {
	let dollarAmount: Float
	let percentAmount: Float
	
	enum GainsType {
		case dollar
		case percent
	}
	
	var isPositive: Bool {
		get {
			dollarAmount >= 0 && percentAmount >= 0
		}
	}
	
	func formatForDisplay(type: GainsType) -> String {
		var formattedAmount: String
		
		switch type {
		case .dollar:
			formattedAmount = dollarAmount.formatted(.currency(code: "USD"))
		case .percent:
			formattedAmount = "\(percentAmount.formatted(.number.precision(.fractionLength(2))))%"
		}
		
		if isPositive {
			return "+\(formattedAmount)"
		}
		
		return formattedAmount
	}
}
