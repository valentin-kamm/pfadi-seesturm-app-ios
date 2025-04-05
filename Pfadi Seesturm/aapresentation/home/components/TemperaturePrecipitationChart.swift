//
//  TemperaturePrecipitationChart.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 30.11.2024.
//

import Charts
import SwiftUI


struct TemperaturePrecipitationChart: View {
    var weather: Weather
    var body: some View {
        
        // find range for precipitation plot
        let maxPrepAmount = weather.hourly.map{ $0.precipitationAmount }.max() ?? 5.0
        let precipitationRange = [
            0.0,
            (maxPrepAmount > 5.0 ? ceil(maxPrepAmount) + 5.0 : 5.0)
        ]
        
        // range for temperature plot
        let maxTemp = weather.hourly.map{ $0.temperature }.max() ?? 10.0
        let minTemp = weather.hourly.map{ $0.temperature }.min() ?? 0.0
        let temperatureRange = [
            (minTemp > 0.0 ? 0.0 : floor(minTemp) - 5.0),
            (maxTemp > 15.0 ? ceil(maxTemp) + 0.5 : 15.0)
        ]
        
        ZStack(alignment: .center) {
            // first chart for temperature
            Chart {
                ForEach(weather.hourly, id: \.id) { hour in
                    LineMark(x: .value("DateTime", hour.forecastStart, unit: .hour, calendar: Calendar.current), y: .value("Temperature", hour.temperature))
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 4))
                        .foregroundStyle(Color.SEESTURM_RED)
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
            .chartYAxis {
                AxisMarks(position: .trailing, values: .automatic) { value in
                    if let temp = value.as(Double.self) {
                        if temp == 0.0 {
                            AxisGridLine()
                        }
                    }
                    AxisGridLine()
                        .foregroundStyle(Color.clear)
                    AxisValueLabel()
                }
                AxisMarks(position: .leading, values: .automatic) { value in
                    AxisValueLabel()
                        .foregroundStyle(Color.clear)
                    AxisGridLine()
                        .foregroundStyle(Color.clear)
                }
            }
            .chartYAxisLabel("°C", position: .topTrailing)
            .chartYAxisLabel(position: .topLeading) {
                Text("mm")
                    .foregroundStyle(Color.clear)
            }
            .chartXAxisLabel(position: .bottom) {
                Text(weather.hourly[0].forecastStart, format: .dateTime.month().day())
            }
            .chartXAxisLabel("Temperatur und Niederschlag", position: .top)
            .chartXScale(domain: [
                weather.hourly[1].forecastStart,
                weather.hourly[weather.hourly.count - 2].forecastStart
            ])
            .chartYScale(domain: temperatureRange)
            .chartPlotStyle { plotArea in
                plotArea
                    .clipped()
            }
            .clipped()
            
            // second chart for precipitation
            Chart {
                ForEach(weather.hourly, id: \.id) { hour in
                    BarMark(x: .value("DateTime", hour.forecastStart, unit: .hour, calendar: Calendar.current), y: .value("Precipitation", hour.precipitationAmount))
                        .foregroundStyle(Color.SEESTURM_BLUE.opacity(0.8))
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    if let dateValue = value.as(Date.self) {
                        AxisValueLabel {
                            Text(dateValue, format: .dateTime.hour())
                                .foregroundStyle(Color.clear)
                        }
                    }
                    AxisGridLine()
                        .foregroundStyle(Color.clear)
                }
            }
            .chartYAxis {
                AxisMarks(position: .trailing, values: .automatic) { value in
                    AxisValueLabel()
                        .foregroundStyle(Color.clear)
                    AxisGridLine()
                        .foregroundStyle(Color.clear)
                }
                AxisMarks(position: .leading, values: .automatic) { value in
                    AxisValueLabel()
                    AxisGridLine()
                        .foregroundStyle(Color.clear)
                }
            }
            
            .chartYAxisLabel("mm", position: .topLeading)
            .chartYAxisLabel(position: .topTrailing) {
                Text("°C")
                    .foregroundStyle(Color.clear)
            }
            .chartXAxisLabel(position: .bottom) {
                Text(weather.hourly[0].forecastStart, format: .dateTime.month().day())
                    .foregroundStyle(Color.clear)
            }
            .chartXScale(domain: [
                weather.hourly[1].forecastStart,
                weather.hourly[weather.hourly.count - 2].forecastStart
            ])
            .chartYScale(domain: precipitationRange)
            .chartPlotStyle { plotArea in
                plotArea
                    .clipped()
            }
        }
    }
}

#Preview {
    TemperaturePrecipitationChart(weather: WeatherPreviewSampleDataProvider.shared.sampleData())
}
