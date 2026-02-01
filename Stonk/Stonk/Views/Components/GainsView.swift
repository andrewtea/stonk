//
//  GainsView.swift
//  Stonk
//
//  Created by Andrew Tang on 12/21/25.
//

import SwiftUI

struct GainsView: View {
	let gains: Gains

	var body: some View {
		let color: Color = gains.isPositive ? .green : .red

		HStack {
			Spacer()

			Text(gains.formatForDisplay(type: .dollar))
				.font(.system(.caption, design: .monospaced))
				.foregroundStyle(color)

			Text(gains.formatForDisplay(type: .percent))
				.font(.system(.caption, design: .monospaced))
				.foregroundStyle(.white)
				.padding(.horizontal, 2)
				.background(RoundedRectangle(cornerRadius: 2).fill(color))
		}
	}
}

#Preview {
	VStack {
		GainsView(gains: Gains(dollarAmount: 150.25, percentAmount: 12.5))
		GainsView(gains: Gains(dollarAmount: -50.00, percentAmount: -5.2))
	}
	.padding()
}
