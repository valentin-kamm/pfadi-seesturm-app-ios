//
//  WeatherCardView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 24.11.2024.
//

import SwiftUI
import WeatherKit

struct WeatherCardView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedGraph: Int = 0
    
    private let weather: Weather
    
    init(
        weather: Weather
    ) {
        self.weather = weather
    }
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            CustomCardView(shadowColor: Color.seesturmGreenCardViewShadowColor) {
                VStack(alignment: .leading) {
                    HStack(alignment: .center, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(weather.daily.dayFormatted)
                                .lineLimit(3)
                                .fontWeight(.bold)
                                .font(.callout)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Label("Pfadiheim Bergbrücke", systemImage: "location")
                                .lineLimit(3)
                                .labelStyle(.titleAndIcon)
                                .font(.footnote)
                                .foregroundStyle(Color.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            HStack {
                                Text(weather.daily.temperatureMin)
                                    .font(.largeTitle)
                                    .foregroundStyle(Color.secondary)
                                    .fontWeight(.bold) +
                                Text(" | ")
                                    .font(.largeTitle)
                                    .fontWeight(.ultraLight) +
                                Text(weather.daily.temperatureMax)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                            }
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity, alignment: .center)
                            Text(weather.daily.description)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .lineLimit(3)
                                .font(.callout)
                        }
                        weather.daily.weatherCondition.getIcon(colorScheme)
                            .resizable()
                            .scaledToFit()
                            .aspectRatio(16/9, contentMode: .fit)
                    }
                    .padding(.bottom, 4)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    HStack(alignment: .center, spacing: 16) {
                        CustomCardView(shadowColor: Color.clear, backgroundColor: .seesturmGray) {
                            Label(weather.daily.precipitationAmount, systemImage: "cloud.rain.fill")
                                .lineLimit(2)
                                .padding(8)
                                .font(.footnote)
                                .frame(maxHeight: .infinity)
                                .foregroundStyle(Color.primary)
                        }
                        CustomCardView(shadowColor: Color.clear, backgroundColor: .seesturmGray) {
                            Label(weather.daily.windSpeed, systemImage: "wind")
                                .lineLimit(2)
                                .padding(8)
                                .font(.footnote)
                                .frame(maxHeight: .infinity)
                                .foregroundStyle(Color.primary)
                        }
                        CustomCardView(shadowColor: Color.clear, backgroundColor: .seesturmGray) {
                            Label(weather.daily.cloudCover, systemImage: "cloud.fill")
                                .lineLimit(2)
                                .padding(8)
                                .font(.footnote)
                                .frame(maxHeight: .infinity)
                                .foregroundStyle(Color.primary)
                        }
                    }
                    .padding(.horizontal)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    TabView {
                        CustomCardView(shadowColor: .clear, backgroundColor: .seesturmGray) {
                            TemperaturePrecipitationChart(weather: weather)
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        .padding(.bottom, 50)
                        CustomCardView(shadowColor: .clear, backgroundColor: .seesturmGray) {
                            CloudCoverChart(weather: weather)
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        .padding(.bottom, 50)
                        CustomCardView(shadowColor: .clear, backgroundColor: .seesturmGray) {
                            WindChart(weather: weather)
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        .padding(.bottom, 50)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .frame(height: 250)
                }
                .padding(.top)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if let attributionUrl = URL(string: weather.attributionURL) {
                Link(destination: attributionUrl) {
                    Label("Apple Weather", systemImage: "apple.logo")
                        .labelStyle(.titleAndIcon)
                        .font(.footnote)
                }
                .foregroundStyle(Color.secondary)
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
    }
}

#Preview {
    WeatherCardView(
        weather: DummyData.weather
    )
    .background(Color.customBackground)
}
