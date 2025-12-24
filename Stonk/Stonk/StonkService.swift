//
//  StonkService.swift
//  Stonk
//
//  Created by Andrew Tang on 12/22/25.
//

import Foundation

struct StonkService {
	let URL_BASE = "http://127.0.0.1:8000/tickers/"
	
	func getSharePrice(ticker: String) async -> Float {
		guard let url = URL(string: "\(URL_BASE)\(ticker)") else { return 0 }
		
		let session = URLSession.shared
		var request = URLRequest(url: url)
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		
		do {
			let (data, _) = try await session.data(for: request)
			let response = try JSONDecoder().decode(TickerResponse.self, from: data)
			return response.price
		} catch {
			return 0
		}
	}
}

struct TickerResponse: Codable {
	let price: Float
}
