//
//  WeatherService_Alamofire.swift
//  WeatherDemo
//
//  Created by ios on 15/9/16.
//  Copyright © 2015年 com.czs. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire

enum CarEngineErrors: ErrorType {
    case NoFuel
    case OilLeak
    case LowBattery
}

extension WeatherService {

    // MARK: - Use Alamofire + SwiftyJSON

    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees, success: (WeatherKit) -> Void, fail: () -> Void, jsonFail: () -> Void) {
            self.retrieveForecast(latitude, longitude: longitude, success: { (response) -> () in
                    let (parseJsonOK, weatherKit) = self.parseJSONToModel(response.object!)
                    if parseJsonOK == true {
                        success(weatherKit!)
                    } else {
                        jsonFail()
                    }
                
                }) { (response) -> () in
                        // network error
                        print("network error")
                        fail()
                    }
    
    }
    
    func retrieveForecast(latitude: CLLocationDegrees, longitude: CLLocationDegrees, success:(response: Response)->(), failure: (response:Response)->()){
        let url = "http://api.openweathermap.org/data/2.5/forecast"
        let params = ["lat":latitude, "lon":longitude]
        print(params)
        
        Alamofire.request(.GET, url, parameters: params)
            .responseJSON { (_, _, result) in
                if result.isFailure == true {
                    let response = Response()
                    response.status = .failure
                    failure(response: response)
                } else {
                    let json = JSON(result.value!)
                    let response = Response()
                    response.status = .success
                    response.object = json
                    success(response: response)
                }
        }
    }
    
    func parseJSONToModel(json: JSON) -> (Bool, WeatherKit?) {
        let weatherKit = WeatherKit()
        weatherKit.weatherList = []
        
        do {
            // If we can get the temperature from JSON correctly, we assume the rest of JSON is correct.
            if let tempResult = try self.getTemperature(json, index: 0) {
                // Get country
                let country = json["city"]["country"].stringValue
                
                // Get and convert temperature
                weatherKit.temperature = self.getAndConvertTemp(country, tempResult: tempResult)
                // Get city name
                weatherKit.city = json["city"]["name"].stringValue
                
                // Get and set icon
                weatherKit.weatherDisplay = self.getIcon(json, index: 0)
                
                // Get forecast
                for index in 1...4 {
                    print(json["list"][index])
                    
                    if let tempResult = try self.getTemperature(json, index: index) {
                        let weatherInfo = Weather()
                        
                        // Get and convert temperature
                        weatherInfo.temperature = self.getAndConvertTemp(country, tempResult: tempResult)
                        
                        // Get forecast time
                        weatherInfo.forecastTime = self.getForecastTime(json, index: index)
                        
                        // Get and set icon
                        weatherInfo.weatherDisplay = self.getIcon(json, index: index)
                        
                        // Add into weatherList
                        weatherKit.weatherList?.append(weatherInfo)
                    }
                }
                return (true, weatherKit)
            }
            
        } catch {
            print("Could not parse json! :[")
            return  (false, weatherKit)
        }
        return (false, weatherKit)
    }
    
    func getAndConvertTemp(country: String, tempResult: Double) -> Double {
        return self.convertTemperature(country, temperature: tempResult)
    }
    
    func getTemperature(json: JSON, index: Int) throws -> Double?  {
        guard let retVal = json["list"][index]["main"]["temp"].double else {
            throw CarEngineErrors.LowBattery
        }
        return retVal
    }
    
    func getForecastTime(json: JSON, index: Int) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let rawDate = json["list"][index]["dt"].doubleValue
        let date = NSDate(timeIntervalSince1970: rawDate)
        return dateFormatter.stringFromDate(date)
    }
    
    func getIcon(json: JSON, index: Int) -> WeatherDisplay {
        let weather = json["list"][0]["weather"][0]
        let condition = weather["condition"].intValue
        let icon = weather["icon"].stringValue
        let nightTime = self.isNightTime(icon)
        let display = WeatherDisplay()
        display.icon = icon
        display.condition = condition
        display.nightTime = nightTime
        return display
    }
}
