//
//  WeatherServiceExtension.swift
//  WeatherDemo
//
//  Created by ios on 15/9/15.
//  Copyright © 2015年 com.czs. All rights reserved.
//

import Foundation
import CoreLocation
import AFNetworking


extension WeatherService {
    
    // MARK: - Use AFNetworking
    
//    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees, success: (WeatherKit) -> Void, fail: () -> Void, jsonFail: () -> Void) {
//        let manager = AFHTTPRequestOperationManager()
//        
//        let url = "http://api.openweathermap.org/data/2.5/forecast"
//        print(url)
//        
//        let params = ["lat":latitude, "lon":longitude]
//        print(params)
//        
//        manager.GET(url,
//            parameters: params,
//            success: { (operation: AFHTTPRequestOperation!,
//                responseObject: AnyObject!) in
//                //                print("JSON: " + responseObject.description!)
//                
//                let (parserOk, weatherKit) = self.JsonToModel(responseObject as! NSDictionary)
//                if parserOk {
//                    success(weatherKit!)
//                } else {
//                    jsonFail()
//                }
//            },
//            failure: { (operation: AFHTTPRequestOperation!,
//                error: NSError!) in
//                print("Error: " + error.localizedDescription)
//                
//                fail()
//        })
//        
//    }
    
    private func JsonToModel(jsonResult: NSDictionary) -> (Bool, WeatherKit?) {
        let weatherKit = WeatherKit()
        weatherKit.weatherList = []
        
        if let resultList = jsonResult["list"] as? NSArray {
            if let mainTemp = resultList[0]["main"] as? NSDictionary {
                if let tempResult = mainTemp["temp"] as? Double {
                    if let tempResult = ((jsonResult["list"] as! NSArray)[0]["main"] as! NSDictionary)["temp"] as? Double {
                        
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
                                print(index)
                                
                                let weatherInfo = Weather()
                                
                                if let perTime = (weatherArray[index] as? NSDictionary) {
                                    if let main = (perTime["main"] as? NSDictionary) {
                                        let temp = (main["temp"] as! Double)
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
                                    let dateFormatter = NSDateFormatter()
                                    dateFormatter.dateFormat = "HH:mm"
                                    if let date = (perTime["dt"] as? Double) {
                                        let thisDate = NSDate(timeIntervalSince1970: date)
                                        if index != 0 {
                                            weatherInfo.forecastTime = dateFormatter.stringFromDate(thisDate)
                                        }
                                    }
                                    if let weather = (perTime["weather"] as? NSArray) {
                                        let condition = (weather[0] as! NSDictionary)["id"] as! Int
                                        let icon = (weather[0] as! NSDictionary)["icon"] as! String
                                        var nightTime = false
                                        if icon.rangeOfString("n") != nil{
                                            nightTime = true
                                        }
                                        let weatherDisplay = WeatherDisplay()
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

}