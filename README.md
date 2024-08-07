# The Meet Group (TMG) - City Weather App 

## City Weather App

## Objective: 
Build a simple iOS weather app that fetches weather data from a public API and displays it to the user in a user-friendly interface.
## Requirements:
1. Use the OpenWeatherMap API (https://openweathermap.org/api) to fetch weather data. ✅
2. Support iOS 15 and up. ✅
3. The app should have at least two screens:
Screen 1: A screen where users can enter the name of a city to get the current weather information. ✅
Screen 2: Display the retrieved weather information, including at least temperature, weather description, and an icon representing the weather condition. 4. Implement error handling for cases such as no internet connection or invalid city names. ✅
5. Provide a refresh mechanism to update the weather data. ✅
6. Use Swift and follow best practices for iOS development. ✅
7. Add comments where necessary to explain your code. ✅
8. Develop one screen in SwiftUI and one screen using UIKit ✅
9. In the search field present suggestions for locations as user types in City or zipcode ✅
## Bonus Points (Optional):
1. Implement a unit test for a critical part of your code. ✅
2. Allow the user to switch between Celsius and Fahrenheit. ✅
3. Use a design pattern like MVVM and Combine framework. ✅
4. Include loading indicators during API calls. ✅


## Instructions how to build and run the project: 
1. Clone the repo local to your machine.
2. Double-click the WeatherApp.xcworkspace file in Finder, or
Use the command line to open Xcode: open WeatherApp.xcworkspace
3. Build and run CityWeatherApp target to any iOS, iPadOS or MacOS (with m1+)

## Model Specs

# City Search Item

| Property      | Type                |
|---------------|---------------------|
| `name`        | `String`            |
| `local_names` | `[String: String]?` |
| `lat`         | `Double`            |
| `lon`         | `Double`            |
| `country`     | `String`            |
| `state`       | `String?`           |

# City Detail Item

| Property      | Type                |
|---------------|---------------------|
| `coord`       | `Coordinates`       |
| `weather`     | `[WeatherDetail]`   |
| `base`        | `String`            |
| `main`        | `TemperatureDetail` |
| `visibility`  | `Int`               |
| `base`        | `String`            |
| `main`        | `TemperatureDetail` |
| `visibility`  | `Int`               |
| `wind`        | `WindDetail`        |
| `clouds`      | `CloudsDetail`      |
| `dt`          | `Int`               |
| `sys`         | `SystemProperties`  |
| `timezone`    | `Int`               |
| `id`          | `Int`               |
| `name`        | `String`            |
| `cod`         | `Int`               |

### Coordinates

| Property      | Type                |
|---------------|---------------------|
| `lat`         | `Double`            |
| `lon`         | `Double`            |

### WeatherDetail

| Property      | Type                |
|---------------|---------------------|
| `id`          | `Int`               |
| `main`        | `String`            |
| `description` | `String`            |
| `icon`        | `String`            |

### TemperatureDetail

| Property      | Type                |
|---------------|---------------------|
| `temp`        | `Double`            |
| `feels_like`  | `Double`            |
| `temp_min`    | `Double`            |
| `temp_max`    | `Double`            |
| `pressure`    | `Int`               |
| `humidity`    | `Int`               |
| `sea_level`   | `Int`               |
| `grnd_level`  | `Int`               |

### WindDetail

| Property      | Type                |
|---------------|---------------------|
| `speed`       | `Double`            |
| `deg`         | `Int`               |
| `gust`        | `Double`            |

### CloudsDetail

| Property      | Type                |
|---------------|---------------------|
| `all`         | `Int`               |

### SystemProperties

| Property      | Type                |
|---------------|---------------------|
| `type`        | `Int`               |
| `id`          | `Int`               |
| `country`     | `String`            |
| `sunrise`     | `Int`               |
| `sunset`      | `Int`               |

## Payload contracts

```
GET geo/1.0/direct?q=

200 RESPONSE

[
  {
    "name": "a Name of the City",
    "local_names": {
      "en": "Stara Zagora",
      "de": "Stara Sagora",
      "sr": "Стара Загора",
      "feature_name": "Stara Zagora",
      "nl": "Stara Zagora",
      "ro": "Stara Zagora",
      "fr": "Stara Zagora",
      "ru": "Стара-Загора",
      "ascii": "Stara Zagora",
      "hr": "Stara Zagora",
      "bg": "Стара Загора",
      "et": "Stara Zagora",
      "el": "Στάρα Ζαγόρα",
      "tr": "Eski Zağra"
    },
    "lat": 42.4248111,
    "lon": 25.6257479,
    "country": "BG"
  },
  {
    "name": "Stara Zagora",
    "local_names": {
      "nl": "Stara Zagora",
      "hr": "Stara Zagora",
      "ru": "Стара-Загора",
      "bg": "Стара Загора",
      "el": "Στάρα Ζαγόρα",
      "de": "Stara Sagora",
      "et": "Stara Zagora",
      "tr": "Eski Zağra",
      "fr": "Stara Zagora",
      "sr": "Стара Загора",
      "ascii": "Stara Zagora",
      "ro": "Stara Zagora",
      "en": "Stara Zagora",
      "feature_name": "Stara Zagora"
    },
    "lat": 42.3705205,
    "lon": 25.57158193530669,
    "country": "BG"
  }
]

```

```
GET data/2.5/weather?lat=lon=units=

200 RESPONSE
{
  "coord": {
    "lon": 25.6419,
    "lat": 42.4328
  },
  "weather": [
    {
      "id": 800,
      "main": "Clear",
      "description": "clear sky",
      "icon": "01d"
    }
  ],
  "base": "stations",
  "main": {
    "temp": 31.06,
    "feels_like": 29.22,
    "temp_min": 31.06,
    "temp_max": 31.06,
    "pressure": 1011,
    "humidity": 22,
    "sea_level": 1011,
    "grnd_level": 978
  },
  "visibility": 10000,
  "wind": {
    "speed": 5.73,
    "deg": 32,
    "gust": 4.99
  },
  "clouds": {
    "all": 0
  },
  "dt": 1723044944,
  "sys": {
    "type": 2,
    "id": 2032863,
    "country": "BG",
    "sunrise": 1723000573,
    "sunset": 1723051811
  },
  "timezone": 10800,
  "id": 726848,
  "name": "Stara Zagora",
  "cod": 200
}
```
