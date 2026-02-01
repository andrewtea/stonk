//
//  HoldingDetailView.swift
//  Stonk
//
//  Created by Andrew Tang on 1/4/26.
//

import Foundation
import SwiftUI

struct HoldingDetailView: View {
	@Environment(StonkManager.self) var manager
	let holding: Holding
	
	var body: some View {
		VStack {
			Text(holding.ticker)
		}
		.navigationTitle(holding.ticker)
		.task {
			await manager.updateHoldingDetails(for: holding)
		}
	}
}
