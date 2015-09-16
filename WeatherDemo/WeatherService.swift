//
//  FetchWeatherService.swift
//  WeatherDemo
//
//  Created by ios on 15/9/15.
//  Copyright (c) 2015年 com.czs. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire


public enum Status {
    case success
    case failure
}

public class Response {
    public var status: Status = .failure
    public var object: JSON? = nil
    public var error: NSError? = nil
}

class WeatherService {
    
    // MARK: - 工具方法
    
    func convertTemperature(country: String, temperature: Double)->Double{
        if (country == "US") {
            // Convert temperature to Fahrenheit if user is within the US
            return round(((temperature - 273.15) * 1.8) + 32)
        }
        else {
            // Otherwise, convert temperature to Celsius
            return round(temperature - 273.15)
        }
    }
    
    func isNightTime(icon: String)->Bool {
        return icon.rangeOfString("n") != nil
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
