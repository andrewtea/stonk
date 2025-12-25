//
//  StonkApp.swift
//  Stonk
//
//  Created by Andrew Tang on 12/21/25.
//

import SwiftData
import SwiftUI

@main
struct StonkApp: App {
	let container: ModelContainer
	
	init() {
		do {
			container = try ModelContainer(for: Portfolio.self)
			// TODO: Remove after testing
			try container.mainContext.delete(model: Portfolio.self)
			try container.mainContext.delete(model: Holding.self)
		} catch {
			fatalError()
		}
	}
	
    var body: some Scene {
        WindowGroup {
			PortfoliosView(
				manager: StonkManager(
					context: container.mainContext,
					service: StonkService()
				)
			)
        }
		.modelContainer(container)
    }
}
