//
//  WindChart.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 30.11.2024.
//

import SwiftUI
import Charts

struct WindChart: View {
    
    private let weather: Weather
    
    init(
        weather: Weather
    ) {
        self.weather = weather
    }
    
    var body: some View {
        Chart {
            ForEach(weather.hourly) { hour in
                AreaMark(x: .value("DateTime", hour.forecastStart, unit: .hour, calendar: Calendar.current), y: .value("Wind Speed", hour.windSpeed))
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.SEESTURM_BLUE.opacity(0.4), Color.blue.opacity(0.0)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                LineMark(x: .value("DateTime", hour.forecastStart, unit: .hour, calendar: Calendar.current), y: .value("Wind Speed", hour.windSpeed), series: .value("Wind", "Wind"))
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 4))
                    .foregroundStyle(Color.SEESTURM_BLUE)
                    .foregroundStyle(by: .value("Value", "Windgeschwindigkeit"))
                LineMark(x: .value("DateTime", hour.forecastStart, unit: .hour, calendar: Calendar.current), y: .value("Böen", hour.windGust), series: .value("Böen", "Böen"))
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 4))
                    .foregroundStyle(Color.SEESTURM_BLUE.opacity(0.4))
                    .foregroundStyle(by: .value("Value", "Böen"))
            }
        }
        .environment(\.calendar, Calendar.current)
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
        .chartYAxisLabel("km/h", position: .top)
        .chartXAxisLabel(position: .bottom) {
            Text(weather.hourly[0].forecastStart, format: .dateTime.month().day())
        }
        .chartXAxisLabel("Wind", position: .top)
        .chartXScale(domain: [
            weather.hourly[1].forecastStart,
            weather.hourly[weather.hourly.count - 2].forecastStart
        ])
        .chartPlotStyle { plotArea in
            plotArea
                .clipped()
        }
        .chartForegroundStyleScale([
            "Windgeschwindigkeit": Color.SEESTURM_BLUE,
            "Böen": Color.SEESTURM_BLUE.opacity(0.4)
        ])
        .chartLegend(.visible)
        .chartLegend(position: .overlay)
    }
}

#Preview {
    WindChart(
        weather: DummyData.weather
    )
    .padding()
    .frame(maxWidth: .infinity)
    .frame(height: 200)
}
