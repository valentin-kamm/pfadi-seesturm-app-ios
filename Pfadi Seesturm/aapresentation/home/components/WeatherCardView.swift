//
//  WeatherCardView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 24.11.2024.
//

import SwiftUI
import WeatherKit

struct WeatherCardView: View {
    
    var weather: Weather
    @Environment(\.colorScheme) var colorScheme
    
    @State var selectedGraph: Int = 0
    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            CustomCardView(shadowColor: Color.seesturmGreenCardViewShadowColor) {
                VStack(alignment: .leading) {
                    HStack(alignment: .center, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(weather.daily.day)
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
                                if #available(iOS 17.0, *) {
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
                                } else {
                                    Text(weather.daily.temperatureMin)
                                        .font(.largeTitle)
                                        .foregroundColor(Color.secondary)
                                        .fontWeight(.bold) +
                                    Text(" | ")
                                        .font(.largeTitle)
                                        .fontWeight(.ultraLight) +
                                    Text(weather.daily.temperatureMax)
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                }
                            }
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity, alignment: .center)
                            Text(weather.daily.description)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .lineLimit(3)
                                .font(.callout)
                        }
                        getWeatherIcon()
                            .resizable()
                            .scaledToFit()
                            .aspectRatio(16/9, contentMode: .fit)
                    }
                    .padding(.bottom, 4)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    HStack(alignment: .center, spacing: 16) {
                        CustomCardView(shadowColor: Color.clear, backgroundColor: Color(UIColor.systemGray5)) {
                            Label(weather.daily.precipitationAmount, systemImage: "cloud.rain.fill")
                                .lineLimit(2)
                                .padding(8)
                                .font(.footnote)
                                .frame(maxHeight: .infinity)
                                .foregroundStyle(Color.primary)
                        }
                        CustomCardView(shadowColor: Color.clear, backgroundColor: Color(UIColor.systemGray5)) {
                            Label(weather.daily.windSpeed, systemImage: "wind")
                                .lineLimit(2)
                                .padding(8)
                                .font(.footnote)
                                .frame(maxHeight: .infinity)
                                .foregroundStyle(Color.primary)
                        }
                        CustomCardView(shadowColor: Color.clear, backgroundColor: Color(UIColor.systemGray5)) {
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
                    // graphics
                    TabView {
                        // temperature and precipitation
                        CustomCardView(shadowColor: .primary) {
                            TemperaturePrecipitationChart(weather: weather)
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        .padding(.bottom, 50)
                        // cloud cover chart
                        CustomCardView(shadowColor: .primary) {
                            CloudCoverChart(weather: weather)
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        .padding(.bottom, 50)
                        // wind speed chart
                        CustomCardView(shadowColor: .primary) {
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
    
    // function to get icon based on the weather
    private func getWeatherIcon() -> Image {
        switch weather.daily.conditionCode {
        case .blizzard:
            return Image("blizzard" + (colorScheme == .dark ? "-dark" : ""))
        case .blowingDust:
            return Image("blowingDust")
        case .blowingSnow:
            return Image("blizzard" + (colorScheme == .dark ? "-dark" : ""))
        case .breezy:
            return Image("windy" + (colorScheme == .dark ? "-dark" : ""))
        case .clear:
            return Image("clear")
        case .cloudy:
            return Image("cloudy" + (colorScheme == .dark ? "-dark" : ""))
        case .drizzle:
            return Image("hail" + (colorScheme == .dark ? "-dark" : ""))
        case .flurries:
            return Image("flurries" + (colorScheme == .dark ? "-dark" : ""))
        case .foggy:
            return Image("foggy" + (colorScheme == .dark ? "-dark" : ""))
        case .freezingDrizzle:
            return Image("freezingDrizzle" + (colorScheme == .dark ? "-dark" : ""))
        case .freezingRain:
            return Image("freezingDrizzle" + (colorScheme == .dark ? "-dark" : ""))
        case .frigid:
            return Image("frigid" + (colorScheme == .dark ? "-dark" : ""))
        case .hail:
            return Image("hail" + (colorScheme == .dark ? "-dark" : ""))
        case .haze:
            return Image("foggy" + (colorScheme == .dark ? "-dark" : ""))
        case .heavyRain:
            return Image("heavyRain" + (colorScheme == .dark ? "-dark" : ""))
        case .heavySnow:
            return Image("snow" + (colorScheme == .dark ? "-dark" : ""))
        case .hot:
            return Image("hot")
        case .hurricane:
            return Image("hurricane" + (colorScheme == .dark ? "-dark" : ""))
        case .isolatedThunderstorms:
            return Image("thunderstorms" + (colorScheme == .dark ? "-dark" : ""))
        case .mostlyClear:
            return Image("mostlyClear" + (colorScheme == .dark ? "-dark" : ""))
        case .mostlyCloudy:
            return Image("cloudy" + (colorScheme == .dark ? "-dark" : ""))
        case .partlyCloudy:
            return Image("mostlyClear" + (colorScheme == .dark ? "-dark" : ""))
        case .rain:
            return Image("heavyRain" + (colorScheme == .dark ? "-dark" : ""))
        case .scatteredThunderstorms:
            return Image("thunderstorms" + (colorScheme == .dark ? "-dark" : ""))
        case .sleet:
            return Image("hail" + (colorScheme == .dark ? "-dark" : ""))
        case .smoky:
            return Image("foggy" + (colorScheme == .dark ? "-dark" : ""))
        case .snow:
            return Image("snow" + (colorScheme == .dark ? "-dark" : ""))
        case .strongStorms:
            return Image("thunderstorms" + (colorScheme == .dark ? "-dark" : ""))
        case .sunFlurries:
            return Image("sunFlurries" + (colorScheme == .dark ? "-dark" : ""))
        case .sunShowers:
            return Image("sunShowers" + (colorScheme == .dark ? "-dark" : ""))
        case .thunderstorms:
            return Image("thunderstorms" + (colorScheme == .dark ? "-dark" : ""))
        case .tropicalStorm:
            return Image("hurricane" + (colorScheme == .dark ? "-dark" : ""))
        case .windy:
            return Image("windy" + (colorScheme == .dark ? "-dark" : ""))
        case .wintryMix:
            return Image("wintryMix" + (colorScheme == .dark ? "-dark" : ""))
        default:
            return Image(systemName: "questionmark.square.dashed")
        }
    }
    
}

#Preview {
    
    WeatherCardView(
        weather: WeatherPreviewSampleDataProvider.shared.sampleData()
    )
    
}

class WeatherPreviewSampleDataProvider {
    static let shared = WeatherPreviewSampleDataProvider()
    func sampleData() -> Weather {
        let jsonString = """
    {
      "attributionURL": "https://developer.apple.com/weatherkit/data-source-attribution/",
      "readTime": "2025-02-01T15:16:10Z",
      "daily": {
        "forecastStart": "2025-02-01T07:00:00Z",
        "forecastEnd": "2025-02-01T19:00:00Z",
        "conditionCode": "MostlyCloudy",
        "temperatureMax": 4.25,
        "temperatureMin": 0.61,
        "precipitationAmount": 0,
        "precipitationChance": 0,
        "snowfallAmount": 0,
        "cloudCover": 0.74,
        "humidity": 0.83,
        "windDirection": 24,
        "windSpeed": 7.19,
        "sunrise": "2025-02-01T06:48:49Z",
        "sunset": "2025-02-01T16:24:22Z"
      },
      "hourly": [
        {
          "forecastStart": "2025-02-01T05:00:00Z",
          "cloudCover": 0.96,
          "precipitationType": "clear",
          "precipitationAmount": 0,
          "snowfallAmount": 0,
          "temperature": 1.17,
          "windSpeed": 10.54,
          "windGust": 17.63
        },
        {
          "forecastStart": "2025-02-01T06:00:00Z",
          "cloudCover": 0.97,
          "precipitationType": "clear",
          "precipitationAmount": 0,
          "snowfallAmount": 0,
          "temperature": 1.12,
          "windSpeed": 10.01,
          "windGust": 17.21
        },
        {
          "forecastStart": "2025-02-01T07:00:00Z",
          "cloudCover": 0.97,
          "precipitationType": "clear",
          "precipitationAmount": 0,
          "snowfallAmount": 0,
          "temperature": 0.66,
          "windSpeed": 8.06,
          "windGust": 15.66
        },
        {
          "forecastStart": "2025-02-01T08:00:00Z",
          "cloudCover": 0.93,
          "precipitationType": "clear",
          "precipitationAmount": 0,
          "snowfallAmount": 0,
          "temperature": 0.7,
          "windSpeed": 8.09,
          "windGust": 15.55
        },
        {
          "forecastStart": "2025-02-01T09:00:00Z",
          "cloudCover": 0.96,
          "precipitationType": "clear",
          "precipitationAmount": 0,
          "snowfallAmount": 0,
          "temperature": 1.37,
          "windSpeed": 8.5,
          "windGust": 16.54
        },
        {
          "forecastStart": "2025-02-01T10:00:00Z",
          "cloudCover": 0.95,
          "precipitationType": "clear",
          "precipitationAmount": 20,
          "snowfallAmount": 0,
          "temperature": 2,
          "windSpeed": 8.42,
          "windGust": 16.27
        },
        {
          "forecastStart": "2025-02-01T11:00:00Z",
          "cloudCover": 0.95,
          "precipitationType": "clear",
          "precipitationAmount": 0,
          "snowfallAmount": 0,
          "temperature": 2.59,
          "windSpeed": 8.13,
          "windGust": 16.17
        },
        {
          "forecastStart": "2025-02-01T12:00:00Z",
          "cloudCover": 0.82,
          "precipitationType": "clear",
          "precipitationAmount": 0,
          "snowfallAmount": 0,
          "temperature": 3.24,
          "windSpeed": 7.16,
          "windGust": 15.4
        },
        {
          "forecastStart": "2025-02-01T13:00:00Z",
          "cloudCover": 0.59,
          "precipitationType": "clear",
          "precipitationAmount": 0,
          "snowfallAmount": 0,
          "temperature": 3.69,
          "windSpeed": 6.07,
          "windGust": 14.28
        },
        {
          "forecastStart": "2025-02-01T14:00:00Z",
          "cloudCover": 0.58,
          "precipitationType": "clear",
          "precipitationAmount": 0,
          "snowfallAmount": 0,
          "temperature": 4.16,
          "windSpeed": 6.54,
          "windGust": 13.83
        },
        {
          "forecastStart": "2025-02-01T15:00:00Z",
          "cloudCover": 0.6,
          "precipitationType": "clear",
          "precipitationAmount": 0,
          "snowfallAmount": 0,
          "temperature": 4.21,
          "windSpeed": 7.39,
          "windGust": 14.86
        },
        {
          "forecastStart": "2025-02-01T16:00:00Z",
          "cloudCover": 0.59,
          "precipitationType": "clear",
          "precipitationAmount": 0,
          "snowfallAmount": 0,
          "temperature": 3.68,
          "windSpeed": 7.28,
          "windGust": 13.59
        },
        {
          "forecastStart": "2025-02-01T17:00:00Z",
          "cloudCover": 0.62,
          "precipitationType": "clear",
          "precipitationAmount": 0,
          "snowfallAmount": 0,
          "temperature": 2.64,
          "windSpeed": 6.46,
          "windGust": 11.82
        },
        {
          "forecastStart": "2025-02-01T18:00:00Z",
          "cloudCover": 0.52,
          "precipitationType": "clear",
          "precipitationAmount": 0,
          "snowfallAmount": 0,
          "temperature": 2.04,
          "windSpeed": 5.94,
          "windGust": 11.39
        },
        {
          "forecastStart": "2025-02-01T19:00:00Z",
          "cloudCover": 0.46,
          "precipitationType": "clear",
          "precipitationAmount": 0,
          "snowfallAmount": 0,
          "temperature": 1.35,
          "windSpeed": 4.44,
          "windGust": 10.22
        }
      ]
    }
    """
        let data = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withColonSeparatorInTimeZone]
            isoFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            return isoFormatter.date(from: dateString)!
        }
        return try! decoder.decode(WeatherDto.self, from: data).toWeather()
    }
}
