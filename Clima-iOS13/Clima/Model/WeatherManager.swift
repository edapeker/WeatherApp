import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager , weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=\(apiKey)&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String){
        //1. Create a url
        if let url = URL(string: urlString){
            //2. Create a URLSession
            let session = URLSession(configuration: .default)
            //3. Give URLSession a task
            //Closure kullnarak dataTask içindeki handler yazdık
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    //data'yı parseJSON içinde açtığımız veriden kullanacağız
                    //önceki swift sürümlerinde closure içinde olduğumuzdan self.parseJSON yazmak gerekirdi şu an gerek yok
                    if let weather = parseJSON(safeData){
                        //let weatherVC = WeatherViewController()
                        //weatherVC.didUpdateWeather(weather: weather)
                        delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            //4. Start the task
            task.resume()
        }
    }
    //Api'den gelen sıkıştırılmış json veriyi swift olarak açmak için fonksiyon
    //Handler içindeki veri tipi olan Data kullandık
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            //print(decodedData.name)
            //print(decodedData.main.temp)
            //print(decodedData.weather[0].description)
            //print(decodedData.main.feels_like)
            let id = decodedData.weather[0].id
            let name = decodedData.name
            let temp = decodedData.main.temp
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
            //print(weather.conditionName)
            //print(weather.temperatureString)
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    

}
