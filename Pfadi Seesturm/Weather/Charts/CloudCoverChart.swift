//
//  CloudCoverChart.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 25.11.2024.
//

import SwiftUI
import Charts

struct CloudCoverChart: View {
    var weather: TransformedWeatherResponse
    var body: some View {
        Chart {
            ForEach(weather.hourly, id: \.id) { hour in
                AreaMark(x: .value("DateTime", hour.forecastStart, unit: .hour, calendar: Calendar.current), y: .value("Cloud Cover", hour.cloudCover))
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.primary.opacity(0.4), Color.primary.opacity(0.0)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                LineMark(x: .value("DateTime", hour.forecastStart, unit: .hour, calendar: Calendar.current), y: .value("Cloud Cover", hour.cloudCover))
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 4))
                    .foregroundStyle(Color.primary)
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                if let dateValue = value.as(Date.self) {
                    AxisValueLabel {
                        Text(dateValue, format: .dateTime.hour())
                    }
                }
                AxisGridLine()
            }
        }
        .chartYAxisLabel("%", position: .top)
        .chartXAxisLabel(position: .bottom) {
            Text(weather.hourly[0].forecastStart, format: .dateTime.month().day())
        }
        .chartXAxisLabel("Bewölkung", position: .top)
        .chartYScale(domain: [0, 100])
        .chartXScale(domain: [
            weather.hourly[1].forecastStart,
            weather.hourly[weather.hourly.count - 1].forecastStart
        ])
        .chartPlotStyle { plotArea in
            plotArea
                .clipped()
        }
    }
}

#Preview {
    CloudCoverChart(weather: WeatherPreviewSampleDataProvider.shared.sampleData())
}
