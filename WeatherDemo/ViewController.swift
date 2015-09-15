//
//  ViewController.swift
//  WeatherDemo
//
//  Created by ios on 15/9/15.
//  Copyright (c) 2015年 com.czs. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet var loadingIndicator : UIActivityIndicatorView! = nil
    @IBOutlet var icon : UIImageView!
    @IBOutlet var temperature : UILabel!
    @IBOutlet var loading : UILabel!
    @IBOutlet var location : UILabel!
    @IBOutlet weak var time1: UILabel!
    @IBOutlet weak var time2: UILabel!
    @IBOutlet weak var time3: UILabel!
    @IBOutlet weak var time4: UILabel!
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var image4: UIImageView!
    @IBOutlet weak var temp1: UILabel!
    @IBOutlet weak var temp2: UILabel!
    @IBOutlet weak var temp3: UILabel!
    @IBOutlet weak var temp4: UILabel!
    
    var weatherService = WeatherService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        
        let singleFingerTap = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        self.view.addGestureRecognizer(singleFingerTap)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.updateWeatherInfo(-7722, longitude: 121)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateWeatherInfo(31, longitude: 121)
    }
    
    func updateWeatherInfo(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        weatherService.fetchWeather(latitude, longitude: longitude, success: updateUISuccess, fail: updateUIFail, jsonFail: parseFail)
    }
    
    func parseFail() {
        clearAllControls()
        self.loading.text = "Weather info is not available!"
    }
    
    func updateUIFail() {
        clearAllControls()
        self.loading.text = "Internet appears down!"
    }
    
    private func clearAllControls() {
        var imageViews = [self.icon, self.image1, self.image2, self.image3, self.image4]
        for imageView: UIImageView in imageViews {
            imageView.image = nil
        }
        
        self.location.text = nil
        self.temperature.text = nil
        
        self.temp1.text = nil
        self.temp2.text = nil
        self.temp3.text = nil
        self.temp4.text = nil
        
        self.time1.text = nil
        self.time2.text = nil
        self.time3.text = nil
        self.time4.text = nil
        
    }
    
    func updateUISuccess(weatherKit: WeatherKit) {
        self.loading.text = nil
        self.loadingIndicator.hidden = true
        self.loadingIndicator.stopAnimating()
        
        self.location.font = UIFont.boldSystemFontOfSize(25)
        self.location.text = weatherKit.city!
        self.temperature.text = "\(weatherKit.temperature!)"
        
        for index in 0...3 {
            let weatherInfo = weatherKit.weatherList![index] as Weather
            if index == 0 {
                self.temp1.text = "\(weatherInfo.temperature!)"
                self.time1.text = weatherInfo.forecastTime
            }
            if index == 1 {
                self.temp2.text = "\(weatherInfo.temperature!)"
                self.time2.text = weatherInfo.forecastTime
            }
            if index == 2 {
                self.temp3.text = "\(weatherInfo.temperature!)"
                self.time3.text = weatherInfo.forecastTime
            }
            if index == 3 {
                self.temp4.text = "\(weatherInfo.temperature!)"
                self.time4.text = weatherInfo.forecastTime
            }
            weatherService.updateWeatherIcon(weatherInfo.weatherDisplay!.condition!, nightTime: weatherInfo.weatherDisplay!.nightTime!, index: index + 1, updatePictures: updatePictures)
        }
        weatherService.updateWeatherIcon(weatherKit.weatherDisplay!.condition!, nightTime: weatherKit.weatherDisplay!.nightTime!, index: 0, updatePictures: updatePictures)
    
    }

    func updatePictures(index: Int, name: String) {
        if (index==0) {
            self.icon.image = UIImage(named: name)
        }
        if (index==1) {
            self.image1.image = UIImage(named: name)
        }
        if (index==2) {
            self.image2.image = UIImage(named: name)
        }
        if (index==3) {
            self.image3.image = UIImage(named: name)
        }
        if (index==4) {
            self.image4.image = UIImage(named: name)
        }
    }
}

