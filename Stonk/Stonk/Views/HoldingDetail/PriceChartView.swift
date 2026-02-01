//
//  PriceChartView.swift
//  Stonk
//
//  Created by Andrew Tang on 2/1/26.
//

import Charts
import SwiftUI

struct PriceChartView: View {
	@Environment(StonkManager.self) var manager
	let ticker: String

	@State private var priceHistory: [PricePoint] = []
	@State private var selectedPeriod: ChartPeriod = .oneMonth
	@State private var selectedPoint: PricePoint?
	@State private var isLoading = true

	private var displayPrice: Float {
		selectedPoint?.close ?? priceHistory.last?.close ?? 0
	}

	private var periodChange: (value: Float, percent: Float)? {
		guard let first = priceHistory.first else { return nil }
		let current = selectedPoint?.close ?? priceHistory.last?.close ?? first.close
		let change = current - first.close
		let percent = (change / first.close) * 100
		return (change, percent)
	}

	private var chartColor: Color {
		guard let change = periodChange else { return .gray }
		return change.value >= 0 ? .green : .red
	}

	private var priceRange: ClosedRange<Float> {
		guard let minPrice = priceHistory.map(\.close).min(),
			  let maxPrice = priceHistory.map(\.close).max() else {
			return 0...100
		}
		let padding = (maxPrice - minPrice) * 0.1
		return (minPrice - padding)...(maxPrice + padding)
	}

	private var chartBaseline: Float {
		priceHistory.map(\.close).min() ?? 0
	}

	var body: some View {
		VStack(spacing: 16) {
			chartHeader

			if isLoading {
				ProgressView()
					.frame(height: 200)
			} else if priceHistory.isEmpty {
				Text("No data available")
					.foregroundStyle(.secondary)
					.frame(height: 200)
			} else {
				chartContent
			}

			periodSelector
		}
		.task {
			await loadHistory()
		}
	}

	private var chartHeader: some View {
		VStack(spacing: 4) {
			Text(displayPrice.formatted(.currency(code: "USD")))
				.font(.system(.largeTitle, design: .monospaced, weight: .bold))
				.contentTransition(.numericText())

			if let change = periodChange {
				HStack(spacing: 4) {
					Image(systemName: change.value >= 0 ? "arrow.up.right" : "arrow.down.right")
						.font(.caption)

					Text(change.value.formatted(.currency(code: "USD").sign(strategy: .always())))
						.font(.system(.subheadline, design: .monospaced))

					Text("(\(change.percent.formatted(.number.precision(.fractionLength(2)).sign(strategy: .always())))%)")
						.font(.system(.subheadline, design: .monospaced))

					if let selectedPoint {
						Text("·")
						Text(formattedDate(for: selectedPoint.date))
							.font(.subheadline)
					} else {
						Text("· Now")
					}
				}
				.foregroundStyle(chartColor)
			}
		}
		.animation(.easeInOut(duration: 0.15), value: selectedPoint?.id)
	}

	private var chartContent: some View {
		Chart(priceHistory) { point in
			AreaMark(
				x: .value("Date", point.date),
				yStart: .value("Baseline", chartBaseline),
				yEnd: .value("Price", point.close)
			)
			.foregroundStyle(
				LinearGradient(
					colors: [chartColor.opacity(0.3), chartColor.opacity(0.0)],
					startPoint: .top,
					endPoint: .bottom
				)
			)
			.interpolationMethod(.catmullRom)

			LineMark(
				x: .value("Date", point.date),
				y: .value("Price", point.close)
			)
			.foregroundStyle(chartColor)
			.interpolationMethod(.catmullRom)
			.lineStyle(StrokeStyle(lineWidth: 2))

			if let selected = selectedPoint, selected.id == point.id {
				RuleMark(x: .value("Selected", point.date))
					.foregroundStyle(Color.secondary.opacity(0.5))
					.lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))

				PointMark(
					x: .value("Date", point.date),
					y: .value("Price", point.close)
				)
				.foregroundStyle(chartColor)
				.symbolSize(80)
			}
		}
		.chartYScale(domain: priceRange)
		.chartXAxis(.hidden)
		.chartYAxis(.hidden)
		.frame(height: 200)
		.chartOverlay { proxy in
			GeometryReader { geometry in
				Rectangle()
					.fill(Color.clear)
					.contentShape(Rectangle())
					.gesture(
						DragGesture(minimumDistance: 0)
							.onChanged { value in
								let xPosition = value.location.x
								guard let date: Date = proxy.value(atX: xPosition) else { return }
								selectNearestPoint(to: date)
							}
							.onEnded { _ in
								selectedPoint = nil
							}
					)
			}
		}
	}

	private var periodSelector: some View {
		HStack(spacing: 0) {
			ForEach(ChartPeriod.allCases, id: \.self) { period in
				Button {
					withAnimation(.easeInOut(duration: 0.2)) {
						selectedPeriod = period
					}
					Task {
						await loadHistory()
					}
				} label: {
					Text(period.displayName)
						.font(.system(.subheadline, weight: .medium))
						.frame(maxWidth: .infinity)
						.padding(.vertical, 8)
						.background(
							RoundedRectangle(cornerRadius: 8)
								.fill(selectedPeriod == period ? chartColor.opacity(0.2) : Color.clear)
						)
						.foregroundStyle(selectedPeriod == period ? chartColor : .secondary)
				}
				.buttonStyle(.plain)
			}
		}
		.padding(4)
		.background(
			RoundedRectangle(cornerRadius: 12)
				.fill(Color(.secondarySystemBackground))
		)
	}

	private func selectNearestPoint(to date: Date) {
		guard !priceHistory.isEmpty else { return }

		let nearest = priceHistory.min { point1, point2 in
			abs(point1.date.timeIntervalSince(date)) < abs(point2.date.timeIntervalSince(date))
		}

		if selectedPoint?.id != nearest?.id {
			selectedPoint = nearest
		}
	}

	private func formattedDate(for date: Date) -> String {
		let formatter = DateFormatter()

		switch selectedPeriod {
		case .oneDay:
			formatter.dateFormat = "h:mm a"
		case .oneWeek, .oneMonth:
			formatter.dateFormat = "MMM d"
		case .oneYear:
			formatter.dateFormat = "MMM d, yyyy"
		case .fiveYears:
			formatter.dateFormat = "MMM yyyy"
		}

		return formatter.string(from: date)
	}

	private func loadHistory() async {
		isLoading = true
		selectedPoint = nil

		if let history = await manager.getPriceHistory(for: ticker, period: selectedPeriod) {
			await MainActor.run {
				priceHistory = history
				isLoading = false
			}
		} else {
			await MainActor.run {
				priceHistory = []
				isLoading = false
			}
		}
	}
}

#Preview {
	let sampleData: [PricePoint] = [
		PricePoint(date: Date().addingTimeInterval(-86400 * 30), close: 175.0),
		PricePoint(date: Date().addingTimeInterval(-86400 * 25), close: 178.5),
		PricePoint(date: Date().addingTimeInterval(-86400 * 20), close: 176.2),
		PricePoint(date: Date().addingTimeInterval(-86400 * 15), close: 182.0),
		PricePoint(date: Date().addingTimeInterval(-86400 * 10), close: 179.8),
		PricePoint(date: Date().addingTimeInterval(-86400 * 5), close: 184.5),
		PricePoint(date: Date(), close: 185.5)
	]

	return VStack {
		PriceChartView(ticker: "AAPL")
	}
	.padding()
}
