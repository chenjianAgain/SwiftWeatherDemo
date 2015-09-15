//
//  FetchWeatherService.swift
//  WeatherDemo
//
//  Created by ios on 15/9/15.
//  Copyright (c) 2015年 com.czs. All rights reserved.
//

import Foundation
import CoreLocation
import AFNetworking

class WeatherService {
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees, success: (WeatherKit) -> Void, fail: () -> Void, jsonFail: () -> Void) {
        let manager = AFHTTPRequestOperationManager()
        
        let url = "http://api.openweathermap.org/data/2.5/forecast"
        println(url)
        
        let params = ["lat":latitude, "lon":longitude]
        println(params)
        
        manager.GET(url,
            parameters: params,
            success: { (operation: AFHTTPRequestOperation!,
                responseObject: AnyObject!) in
                println("JSON: " + responseObject.description!)
                
                let (parserOk, weatherKit) = self.JsonToModel(responseObject as! NSDictionary)
                if parserOk {
                    success(weatherKit!)
                } else {
                    jsonFail()
                }
            },
            failure: { (operation: AFHTTPRequestOperation!,
                error: NSError!) in
                println("Error: " + error.localizedDescription)
                
                fail()
            })

    }
    
    private func JsonToModel(jsonResult: NSDictionary) -> (Bool, WeatherKit?) {
        var weatherKit = WeatherKit()
        weatherKit.weatherList = []
        
        if let resultList = jsonResult["list"] as? NSArray {
            if let mainTemp = resultList[0]["main"] as? NSDictionary {
                if let tempResult = mainTemp["temp"] as? Double {
                    if let tempResult = ((jsonResult["list"] as! NSArray)[0]["main"] as! NSDictionary)["temp"] as? Double {
                        println("TempResult:", tempResult)
                        // If we can get the temperature from JSON correctly, we assume the rest of JSON is correct.
                        var temperature: Double
                        var cntry: String
                        cntry = ""
                        if let city = (jsonResult["city"] as? NSDictionary) {
                            if let country = (city["country"] as? String) {
                                cntry = country
                                if (country == "US") {
                                    // Convert temperature to Fahrenheit if user is within the US
                                    temperature = round(((tempResult - 273.15) * 1.8) + 32)
                                }
                                else {
                                    // Otherwise, convert temperature to Celsius
                                    temperature = round(tempResult - 273.15)
                                }
                                
                                weatherKit.temperature = temperature
                            }
                            
                            if let name = (city["name"] as? String) {
                                weatherKit.city = name
                            }
                        }
                        
                        
                        if let weatherArray = (jsonResult["list"] as? NSArray) {
                            for index in 0...4 {
                                println(index)
                                
                                var weatherInfo = Weather()

                                if let perTime = (weatherArray[index] as? NSDictionary) {
                                    if let main = (perTime["main"] as? NSDictionary) {
                                        var temp = (main["temp"] as! Double)
                                        if (cntry == "US") {
                                            // Convert temperature to Fahrenheit if user is within the US
                                            temperature = round(((temp - 273.15) * 1.8) + 32)
                                        }
                                        else {
                                            // Otherwise, convert temperature to Celsius
                                            temperature = round(temp - 273.15)
                                        }
                                        if index != 0 {
                                            weatherKit.weatherList?.append(weatherInfo)
                                            weatherInfo.temperature = temperature
                                        }
                                    }
                                    var dateFormatter = NSDateFormatter()
                                    dateFormatter.dateFormat = "HH:mm"
                                    if let date = (perTime["dt"] as? Double) {
                                        let thisDate = NSDate(timeIntervalSince1970: date)
                                        if index != 0 {
                                            weatherInfo.forecastTime = dateFormatter.stringFromDate(thisDate)
                                        }
                                    }
                                    if let weather = (perTime["weather"] as? NSArray) {
                                        var condition = (weather[0] as! NSDictionary)["id"] as! Int
                                        var icon = (weather[0] as! NSDictionary)["icon"] as! String
                                        var nightTime = false
                                        if icon.rangeOfString("n") != nil{
                                            nightTime = true
                                        }
                                        var weatherDisplay = WeatherDisplay()
                                        weatherDisplay.condition = condition
                                        weatherDisplay.icon = icon
                                        weatherDisplay.nightTime = nightTime
                                        if index == 0 {
                                            weatherKit.weatherDisplay = weatherDisplay
                                        } else {
                                            weatherInfo.weatherDisplay = weatherDisplay
                                        }
                                        
                                        if (index==4) {
                                            return (true, weatherKit)
                                        }
                                        
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return (false, nil)
    }
    
    func updateWeatherIcon(condition: Int, nightTime: Bool, index: Int, updatePictures: (Int, name: String) -> Void) {
        // Thunderstorm
        
        
        if (condition < 300) {
            if nightTime {
                updatePictures(index, name: "tstorm1_night")
            } else {
                updatePictures(index, name: "tstorm1")
            }
        }
            // Drizzle
        else if (condition < 500) {
            updatePictures(index, name: "light_rain")
            
        }
            // Rain / Freezing rain / Shower rain
        else if (condition < 600) {
            updatePictures(index, name: "shower3")
        }
            // Snow
        else if (condition < 700) {
            updatePictures(index, name: "snow4")
        }
            // Fog / Mist / Haze / etc.
        else if (condition < 771) {
            if nightTime {
                updatePictures(index, name: "fog_night")
            } else {
                updatePictures(index, name: "fog")
            }
        }
            // Tornado / Squalls
        else if (condition < 800) {
            updatePictures(index, name: "tstorm3")
        }
            // Sky is clear
        else if (condition == 800) {
            if (nightTime){
                updatePictures(index, name: "sunny_night")
            }
            else {
                updatePictures(index, name: "sunny")
            }
        }
            // few / scattered / broken clouds
        else if (condition < 804) {
            if (nightTime){
                updatePictures(index, name: "cloudy2_night")
            }
            else{
                updatePictures(index, name: "cloudy2")
            }
        }
            // overcast clouds
        else if (condition == 804) {
            updatePictures(index, name: "overcast")
        }
            // Extreme
        else if ((condition >= 900 && condition < 903) || (condition > 904 && condition < 1000)) {
            updatePictures(index, name: "tstorm3")
        }
            // Cold
        else if (condition == 903) {
            updatePictures(index, name: "snow5")
        }
            // Hot
        else if (condition == 904) {
            updatePictures(index, name: "sunny")
        }
            // Weather condition is not available
        else {
            updatePictures(index, name: "dunno")
        }
    }

}
