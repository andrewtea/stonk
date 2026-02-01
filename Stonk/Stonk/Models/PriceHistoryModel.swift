//
//  PriceHistoryModel.swift
//  Stonk
//
//  Created by Andrew Tang on 2/1/26.
//

import Foundation

struct PricePoint: Identifiable {
	let date: Date
	let close: Float

	var id: Date { date }
}

struct PriceHistoryResponse: Codable {
	let history: [PricePointResponse]
}

struct PricePointResponse: Codable {
	let date: String
	let close: Float
}

enum ChartPeriod: String, CaseIterable {
	case oneDay = "1d"
	case oneWeek = "1w"
	case oneMonth = "1mo"
	case oneYear = "1y"
	case fiveYears = "5y"

	var displayName: String {
		switch self {
		case .oneDay: return "1D"
		case .oneWeek: return "1W"
		case .oneMonth: return "1M"
		case .oneYear: return "1Y"
		case .fiveYears: return "5Y"
		}
	}
}
