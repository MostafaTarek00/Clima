//
//  ViewController.swift
//  Clima
//
//  Created by Mustafa on 9/25/19.
//  Copyright © 2019 Mostafa. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController , CLLocationManagerDelegate , ChangeCityDelegate{
    
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "f5cee514b39fb36deeb62dcd02950a12"
    /***Get your own App ID at https://openweathermap.org/appid ****/
    
    
    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    
    
    //Pre-linked IBOutlets
    
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var weatherIcon: UIImageView!
    
    @IBOutlet weak var cityLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        
    }
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:

    func getWeatherData(url : String , parameters : [String : String] )  {

     
        Alamofire.request(url, method:.get, parameters: parameters).responseJSON {
            response  in

            if response.result.isSuccess {
                print("Success! Go the Weather Data ")
                let weatherJson : JSON = JSON (response.result.value!)
                print(weatherJson)
                self.updateWeatherData(json: weatherJson)


            }else {
                print("error : \(String(describing: response.result.error))" )
                self.cityLabel.text = "Connection Issues"

            }

        }

    }
    
    

    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
    
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json : JSON)  {
        
        if   let tempResult = json ["main"] ["temp"].double {
            weatherDataModel.temperature = Int(tempResult - 273.15)
            weatherDataModel.weatherCondition = json ["weather"] [0] ["id"].intValue
            weatherDataModel.city = json ["name"].stringValue
            weatherDataModel.weatherIconName =  weatherDataModel.updateWeatherIcon(condition: weatherDataModel.weatherCondition)
            updateUIWithWeatherData()
            
            
            
        } else {
            cityLabel.text = "Weather Unvailable "
        }
        
        
        
    }
   
   
    
    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWithWeatherData()  {
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        
    }
   
    
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1 ]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            print("latitude : \(location.coordinate.latitude) and  longitude : \(location.coordinate.longitude) ")
            let latitude = String (location.coordinate.latitude)
            let longitude = String (location.coordinate.longitude)
            let  parms : [String : String] = ["lat" : latitude , "lon" : longitude , "appid" : APP_ID]
            getWeatherData(url: WEATHER_URL, parameters: parms)
            
            
        }
        
    }
    
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unvailable"
    }
    
    
    
    
    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    
    func userEnteredANewCityName(city: String) {
        let parms : [String : String] = ["q" : city , "appid" : APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: parms)
    }
    
    
    
    //Write the PrepareForSegue Method here
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName"{
            let changeCityVC = segue.destination as! ChangeCityViewController
            changeCityVC.delegate = self
            
        }
    }
    
    


}

