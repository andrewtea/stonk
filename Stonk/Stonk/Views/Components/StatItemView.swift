//
//  StatItemView.swift
//  Stonk
//
//  Created by Andrew Tang on 2/1/26.
//

import SwiftUI

struct StatItemView: View {
	let label: String
	let value: String

	var body: some View {
		VStack(alignment: .leading, spacing: 4) {
			Text(label)
				.font(.caption)
				.foregroundStyle(.secondary)

			Text(value)
				.font(.system(.body, design: .monospaced, weight: .medium))
		}
		.frame(maxWidth: .infinity, alignment: .leading)
	}
}

#Preview {
	VStack {
		StatItemView(label: "Market Cap", value: "$3.45T")
		StatItemView(label: "P/E Ratio", value: "32.5")
	}
	.padding()
}
