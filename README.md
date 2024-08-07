# The Meet Group (TMG) - City Weather App 

## City Weather App

## Objective: 
Build a simple iOS weather app that fetches weather data from a public API and displays it to the user in a user-friendly interface.
## Requirements:
1. Use the OpenWeatherMap API (https://openweathermap.org/api) to fetch weather data. 2. Support iOS 15 and up
3. The app should have at least two screens:
Screen 1: A screen where users can enter the name of a city to get the current weather information.
Screen 2: Display the retrieved weather information, including at least temperature, weather description, and an icon representing the weather condition. 4. Implement error handling for cases such as no internet connection or invalid city names.
5. Provide a refresh mechanism to update the weather data.
6. Use Swift and follow best practices for iOS development.
7. Add comments where necessary to explain your code.
8. Develop one screen in SwiftUI and one screen using UIKit
9. In the search field present suggestions for locations as user types in City or zipcode
## Bonus Points (Optional):
Implement a unit test for a critical part of your code.
Allow the user to switch between Celsius and Fahrenheit. 
Use a design pattern like MVVM and Combine framework. 
Include loading indicators during API calls. 


## Instructions how to build and run the project: 
1. Clone the repo local to your machine.
2. Double-click the WeatherApp.xcworkspace file in Finder, or
Use the command line to open Xcode: open WeatherApp.xcworkspace
3. Build and run CityWeatherApp target to any iOS, iPadOS or MacOS (with m1+)

### Payload contract

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
