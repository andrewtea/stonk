//
//  HoldingModel.swift
//  Stonk
//
//  Created by Andrew Tang on 12/22/25.
//

import SwiftData
import Foundation

@Observable
class Holding {
	var ticker: String
	var numShares: Float
	var lastPrice: Float
	
	var totalPrice: Float {
		get { numShares * lastPrice }
	}
	
	var imageURL: String {
		get { "http://localhost:8000/logos/\(ticker)" }
	}
	
	init(ticker: String, numShares: Float, lastPrice: Float = 0) {
		self.ticker = ticker
		self.numShares = numShares
		self.lastPrice = lastPrice
	}
}
