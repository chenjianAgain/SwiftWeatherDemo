//
//  Weather.swift
//  WeatherDemo
//
//  Created by ios on 15/9/15.
//  Copyright (c) 2015年 com.czs. All rights reserved.
//

import Foundation

class WeatherKit {
    var city: String?
    var country: String? {
        didSet {
            isUS = country == "US"
        }
    }
    var isUS: Bool?
    
    var temperature: Double?
    
    var weatherList: [Weather]?
    
    var weatherDisplay: WeatherDisplay?
}