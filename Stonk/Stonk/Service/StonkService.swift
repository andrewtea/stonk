//
//  StonkService.swift
//  Stonk
//
//  Created by Andrew Tang on 12/22/25.
//

import Foundation

struct StonkService {
	let URL_BASE = "http://127.0.0.1:8000/"
	
	func getSharePrice(ticker: String) async -> Float {
		guard let url = URL(string: "\(URL_BASE)prices/\(ticker)") else { return 0 }
		
		let session = URLSession.shared
		let request = URLRequest(url: url)
		
		do {
			let (data, _) = try await session.data(for: request)
			let response = try JSONDecoder().decode(TickerResponse.self, from: data)
			return response.price
		} catch {
			return 0
		}
	}
	
	func getHoldingDetails(ticker: String) async -> HoldingDetailsResponse? {
		guard let url = URL(string: "\(URL_BASE)info/\(ticker)") else { return nil }

		let session = URLSession.shared
		let request = URLRequest(url: url)

		do {
			let (data, _) = try await session.data(for: request)
			let response = try JSONDecoder().decode(HoldingDetailsResponse.self, from: data)
			return response
		} catch {
			return nil
		}
	}

	func getPriceHistory(ticker: String, period: ChartPeriod) async -> [PricePoint]? {
		guard let url = URL(string: "\(URL_BASE)history/\(ticker)?period=\(period.rawValue)") else { return nil }

		let session = URLSession.shared
		let request = URLRequest(url: url)

		do {
			let (data, _) = try await session.data(for: request)
			let response = try JSONDecoder().decode(PriceHistoryResponse.self, from: data)

			let formatter = ISO8601DateFormatter()
			formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

			// Fallback formatter without fractional seconds
			let fallbackFormatter = ISO8601DateFormatter()
			fallbackFormatter.formatOptions = [.withInternetDateTime]

			return response.history.compactMap { point in
				let date = formatter.date(from: point.date) ?? fallbackFormatter.date(from: point.date)
				guard let date else { return nil }
				return PricePoint(date: date, close: point.close)
			}
		} catch {
			return nil
		}
	}
}

struct TickerResponse: Codable {
	let price: Float
}

struct HoldingDetailsResponse: Codable {
	let name: String?
	let description: String?
	let sector: String?
	let website: String?

	// Market data
	let marketCap: Double?
	let peRatio: Float?
	let dividendYield: Float?
	let beta: Float?
	let fiftyTwoWeekHigh: Float?
	let fiftyTwoWeekLow: Float?
	let previousClose: Float?
	let averageVolume: Int?

	// Extended company info
	let industry: String?
	let country: String?
	let employees: Int?
}
