import Foundation

public struct CityDetailItem: Equatable {
    
    public let coordinates: Coordinates
    public let weather: [WeatherInfo]
    public let base: String
    public let mainWeather: MainWeather
    public let visibility: Int
    public let windInfo: WindInfo
    public let clouds: CloudsWeather
    public let dateTime: Int
    public let systemWeather: SystemWeather
    public let timezone: Int
    public let id: Int
    public let name: String
    public let code: Int
    
    public init(coordinates: Coordinates, weather: [WeatherInfo], base: String, mainWeather: MainWeather, visibility: Int, windInfo: WindInfo, clouds: CloudsWeather, dateTime: Int, systemWeather: SystemWeather, timezone: Int, id: Int, name: String, code: Int) {
        self.coordinates = coordinates
        self.weather = weather
        self.base = base
        self.mainWeather = mainWeather
        self.visibility = visibility
        self.windInfo = windInfo
        self.clouds = clouds
        self.dateTime = dateTime
        self.systemWeather = systemWeather
        self.timezone = timezone
        self.id = id
        self.name = name
        self.code = code
    }
}

public struct Coordinates: Equatable {
    public let latitude: Double
    public let longitude: Double
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

public struct WeatherInfo: Equatable {
    public let id: Int
    public let main: String
    public let description: String
    public let icon: String
    
    public init(id: Int, main: String, description: String, icon: String) {
        self.id = id
        self.main = main
        self.description = description
        self.icon = icon
    }
}

public struct MainWeather: Equatable {
    public let temp: Double
    public let feels_like: Double
    public let temp_min: Double
    public let temp_max: Double
    public let pressure: Int
    public let humidity: Int
    public let sea_level: Int
    public let grnd_level: Int
    
    public init(temp: Double, feels_like: Double, temp_min: Double, temp_max: Double, pressure: Int, humidity: Int, sea_level: Int, grnd_level: Int) {
        self.temp = temp
        self.feels_like = feels_like
        self.temp_min = temp_min
        self.temp_max = temp_max
        self.pressure = pressure
        self.humidity = humidity
        self.sea_level = sea_level
        self.grnd_level = grnd_level
    }
}

public struct WindInfo: Equatable {
    public let speed: Double
    public let deg: Int
    public let gust: Double
    
    public init(speed: Double, deg: Int, gust: Double) {
        self.speed = speed
        self.deg = deg
        self.gust = gust
    }
}

public struct SystemWeather: Equatable {
    public let country: String
    public let sunrise: Int
    public let sunset: Int
    
    public init(country: String, sunrise: Int, sunset: Int) {
        self.country = country
        self.sunrise = sunrise
        self.sunset = sunset
    }
}

public struct CloudsWeather: Equatable {
    public let all: Int
    
    public init(all: Int) {
        self.all = all
    }
}

