//
//  AboutSectionView.swift
//  Stonk
//
//  Created by Andrew Tang on 2/1/26.
//

import SwiftUI

struct AboutSectionView: View {
	let description: String
	@State private var isExpanded: Bool = false

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("About")
				.font(.system(.title2, design: .serif, weight: .bold))

			VStack(alignment: .leading, spacing: 8) {
				Text(description)
					.font(.subheadline)
					.lineLimit(isExpanded ? nil : 4)

				Button {
					withAnimation(.easeInOut(duration: 0.2)) {
						isExpanded.toggle()
					}
				} label: {
					Text(isExpanded ? "Show Less" : "Show More")
						.font(.subheadline.weight(.medium))
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

#Preview {
	AboutSectionView(description: "Apple Inc. designs, manufactures, and markets smartphones, personal computers, tablets, wearables, and accessories worldwide. The company offers iPhone, a line of smartphones; Mac, a line of personal computers; iPad, a line of multi-purpose tablets; and wearables, home, and accessories comprising AirPods, Apple TV, Apple Watch, Beats products, and HomePod. It also provides AppleCare support and cloud services; and operates various platforms, including the App Store that allow customers to discover and download applications and digital content, such as books, music, video, games, and podcasts.")
		.padding()
}
