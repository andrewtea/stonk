//
//  CompanyInfoSectionView.swift
//  Stonk
//
//  Created by Andrew Tang on 2/1/26.
//

import SwiftUI

struct CompanyInfoSectionView: View {
	let holding: Holding

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("Company Info")
				.font(.system(.title2, design: .serif, weight: .bold))

			VStack(alignment: .leading, spacing: 12) {
				HStack(spacing: 8) {
					if let sector = holding.sector {
						ChipView(text: sector)
					}

					if let industry = holding.industry {
						ChipView(text: industry)
					}
				}

				if let country = holding.country {
					HStack {
						Image(systemName: "globe")
							.foregroundStyle(.secondary)
						Text(country)
							.font(.subheadline)
					}
				}

				if let employees = holding.employees {
					HStack {
						Image(systemName: "person.2.fill")
							.foregroundStyle(.secondary)
						Text("\(employees.formatted(.number)) employees")
							.font(.subheadline)
					}
				}

				if let website = holding.website, let url = URL(string: website) {
					Link(destination: url) {
						HStack {
							Image(systemName: "link")
							Text(website.replacingOccurrences(of: "https://", with: ""))
								.lineLimit(1)
						}
						.font(.subheadline)
					}
				}
			}
			.padding()
			.frame(maxWidth: .infinity, alignment: .leading)
			.background(
				RoundedRectangle(cornerRadius: 12)
					.fill(Color(.systemGray6))
			)
		}
	}
}

struct ChipView: View {
	let text: String

	var body: some View {
		Text(text)
			.font(.caption)
			.padding(.horizontal, 10)
			.padding(.vertical, 6)
			.background(
				Capsule()
					.fill(Color.accentColor.opacity(0.15))
			)
			.foregroundStyle(Color.accentColor)
	}
}

#Preview {
	let holding = Holding(ticker: "AAPL", numShares: 10, lastPrice: 185.50, averagePrice: 150.00)
	holding.sector = "Technology"
	holding.industry = "Consumer Electronics"
	holding.country = "United States"
	holding.employees = 164000
	holding.website = "https://www.apple.com"

	return CompanyInfoSectionView(holding: holding)
		.padding()
}
