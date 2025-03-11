//
//  WeatherCell.swift
//  WeatherApp
//
//  Created by Ani Lakirbaia on 07.02.25.
//
import UIKit
//import Kingfisher


class WeatherCell: UICollectionViewCell {
    static let identifier = "WeatherCell"
    
    var weatherData: WeatherData? {
        didSet {
            
            
            let colors = [
                UIColor(red: 184/255, green: 219/255, blue: 234/255, alpha: 1.0), 
                UIColor(red: 173/255, green: 216/255, blue: 211/255, alpha: 1.0),
                UIColor(red: 174/255, green: 201/255, blue: 221/255, alpha: 1.0)
            ]
            let backgroundColor = colors.randomElement() ?? UIColor.white
                   containerView.backgroundColor = backgroundColor

                   
            let temperature = "\(weatherData?.main.temp ?? 0)°C"
            let description = weatherData?.weather.first?.description ?? ""
            temperatureDescriptionLabel.text = "\(temperature) | \(description)"
            
            let cityName = weatherData?.name ?? ""
            let countryCode = weatherData?.sys.country ?? ""
            let locale = Locale.current
            let countryName = locale.localizedString(forRegionCode: countryCode) ?? countryCode
            cityLabel.text = "\(cityName), \(countryName)"
            
            cloudinessLabel.text = "Cloudiness:"
            cloudinessValueLabel.text = "\(weatherData?.clouds.all ?? 0)%"
            
            humidityLabel.text = "Humidity:"
            humidityValueLabel.text = "\(weatherData?.main.humidity ?? 0)%"
            
            let windSpeedInKmh = (weatherData?.wind.speed ?? 0) * 3.6
            windSpeedLabel.text = "Wind Speed:"
            windSpeedValueLabel.text = "\(String(format: "%.1f", windSpeedInKmh)) km/h"
            
            windDirectionLabel.text = "Wind Direction:"
            windDirectionValueLabel.text =
                "\(windDirection(from: weatherData?.wind.deg ?? 0))"
            
            if let iconCode = weatherData?.weather.first?.icon {
                fetchWeatherIcon(iconCode: iconCode)
            }
        }
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        return view
    }()
    
    private let temperatureDescriptionLabel = UILabel()
    private let cityLabel = UILabel()
    private let cloudinessLabel = UILabel()
    private let cloudinessValueLabel = UILabel()
    private let humidityLabel = UILabel()
    private let humidityValueLabel = UILabel()
    private let windSpeedLabel = UILabel()
    private let windSpeedValueLabel = UILabel()
    private let windDirectionLabel = UILabel()
    private let windDirectionValueLabel = UILabel()
    private let weatherIconImageView = UIImageView()
    
    private let cloudinessIcon = UIImageView(image: UIImage(systemName: "cloud.fill"))
    private let humidityIcon = UIImageView(image: UIImage(systemName: "humidity.fill"))
    private let windSpeedIcon = UIImageView(image: UIImage(systemName: "wind"))
    private let windDirectionIcon = UIImageView(image: UIImage(systemName: "location.fill"))
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 30
        contentView.layer.masksToBounds = true

        containerView.layer.cornerRadius = 15
        
        containerView.backgroundColor = UIColor.black
        
        containerView.layer.masksToBounds = true

        contentView.addSubview(containerView)
        [temperatureDescriptionLabel, cityLabel, cloudinessLabel, cloudinessValueLabel, humidityLabel, humidityValueLabel, windSpeedLabel, windSpeedValueLabel, windDirectionLabel, windDirectionValueLabel, weatherIconImageView, cloudinessIcon, humidityIcon, windSpeedIcon, windDirectionIcon].forEach {
            containerView.addSubview($0)
        }

        setupLabels()
        setupConstraints()
    }
   
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLabels() {
        temperatureDescriptionLabel.font = UIFont.boldSystemFont(ofSize: 24)
        temperatureDescriptionLabel.textAlignment = .center
        temperatureDescriptionLabel.textColor = .yellow
        
        cityLabel.font = UIFont.boldSystemFont(ofSize: 22)
        cityLabel.textColor = .white
        cityLabel.textAlignment = .center
        
        let labels = [cloudinessLabel, humidityLabel, windSpeedLabel, windDirectionLabel]
        labels.forEach {
            $0.font = UIFont.systemFont(ofSize: 20, weight: .medium)
            $0.textColor = .white
            $0.textAlignment = .left
        }
        
        let values = [cloudinessValueLabel, humidityValueLabel, windSpeedValueLabel, windDirectionValueLabel]
        values.forEach {
            $0.font = UIFont.systemFont(ofSize: 22, weight: .medium)
            $0.textColor = .yellow
            $0.textAlignment = .right
        }
        
        weatherIconImageView.contentMode = .scaleAspectFit
        
        cloudinessIcon.tintColor = .yellow
        humidityIcon.tintColor = .yellow
        windSpeedIcon.tintColor = .yellow
        windDirectionIcon.tintColor = .yellow
    }
    
    private func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        temperatureDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        cityLabel.translatesAutoresizingMaskIntoConstraints = false
        cloudinessLabel.translatesAutoresizingMaskIntoConstraints = false
        cloudinessValueLabel.translatesAutoresizingMaskIntoConstraints = false
        humidityLabel.translatesAutoresizingMaskIntoConstraints = false
        humidityValueLabel.translatesAutoresizingMaskIntoConstraints = false
        windSpeedLabel.translatesAutoresizingMaskIntoConstraints = false
        windSpeedValueLabel.translatesAutoresizingMaskIntoConstraints = false
        windDirectionLabel.translatesAutoresizingMaskIntoConstraints = false
        windDirectionValueLabel.translatesAutoresizingMaskIntoConstraints = false
        weatherIconImageView.translatesAutoresizingMaskIntoConstraints = false
        cloudinessIcon.translatesAutoresizingMaskIntoConstraints = false
        humidityIcon.translatesAutoresizingMaskIntoConstraints = false
        windSpeedIcon.translatesAutoresizingMaskIntoConstraints = false
        windDirectionIcon.translatesAutoresizingMaskIntoConstraints = false
        
 
            NSLayoutConstraint.activate([
                containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
                containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
                containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
                
                weatherIconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 40),
                weatherIconImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                weatherIconImageView.widthAnchor.constraint(equalToConstant: 140),
                weatherIconImageView.heightAnchor.constraint(equalToConstant: 140),
                
                cityLabel.topAnchor.constraint(equalTo: weatherIconImageView.bottomAnchor, constant: 5),
                cityLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                
                temperatureDescriptionLabel.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: 5),
                temperatureDescriptionLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                
                cloudinessIcon.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -60),
                cloudinessIcon.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
                cloudinessIcon.widthAnchor.constraint(equalToConstant: 40),
                cloudinessIcon.heightAnchor.constraint(equalToConstant: 40),
                cloudinessLabel.centerYAnchor.constraint(equalTo: cloudinessIcon.centerYAnchor),
                cloudinessLabel.leadingAnchor.constraint(equalTo: cloudinessIcon.trailingAnchor, constant: 5),
                cloudinessValueLabel.centerYAnchor.constraint(equalTo: cloudinessIcon.centerYAnchor),
                cloudinessValueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
                
                humidityIcon.bottomAnchor.constraint(equalTo: cloudinessIcon.topAnchor, constant: -15),
                humidityIcon.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
                humidityIcon.widthAnchor.constraint(equalToConstant: 40),
                humidityIcon.heightAnchor.constraint(equalToConstant: 40),
                humidityLabel.centerYAnchor.constraint(equalTo: humidityIcon.centerYAnchor),
                humidityLabel.leadingAnchor.constraint(equalTo: humidityIcon.trailingAnchor, constant: 5),
                humidityValueLabel.centerYAnchor.constraint(equalTo: humidityIcon.centerYAnchor),
                humidityValueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
                
                windSpeedIcon.bottomAnchor.constraint(equalTo: humidityIcon.topAnchor, constant: -15),
                windSpeedIcon.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
                windSpeedIcon.widthAnchor.constraint(equalToConstant: 40),
                windSpeedIcon.heightAnchor.constraint(equalToConstant: 40),
                windSpeedLabel.centerYAnchor.constraint(equalTo: windSpeedIcon.centerYAnchor),
                windSpeedLabel.leadingAnchor.constraint(equalTo: windSpeedIcon.trailingAnchor, constant: 5),
                windSpeedValueLabel.centerYAnchor.constraint(equalTo: windSpeedIcon.centerYAnchor),
                windSpeedValueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
                
                windDirectionIcon.bottomAnchor.constraint(equalTo: windSpeedIcon.topAnchor, constant: -15),
                windDirectionIcon.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
                windDirectionIcon.widthAnchor.constraint(equalToConstant: 40),
                windDirectionIcon.heightAnchor.constraint(equalToConstant: 40),
                windDirectionLabel.centerYAnchor.constraint(equalTo: windDirectionIcon.centerYAnchor),
                windDirectionLabel.leadingAnchor.constraint(equalTo: windDirectionIcon.trailingAnchor, constant: 5),
                windDirectionValueLabel.centerYAnchor.constraint(equalTo: windDirectionIcon.centerYAnchor),
                windDirectionValueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15)
            ])

        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        containerView.backgroundColor = .clear
        containerView.layer.borderColor = UIColor.clear.cgColor
    }
    
    
    
    
    private func windDirection(from degrees: Int) -> String {
        switch degrees {
        case 0..<45:
            return "N"
        case 45..<135:
            return "E"
        case 135..<225:
            return "S"
        case 225..<315:
            return "W"
        default:
            return "N"
        }
    }
    
  
    private func fetchWeatherIcon(iconCode: String) {
           let iconURLString = "https://openweathermap.org/img/wn/\(iconCode)@2x.png"
           guard let iconURL = URL(string: iconURLString) else { return }
           
           URLSession.shared.dataTask(with: iconURL) { data, _, error in
               if let data = data, let image = UIImage(data: data) {
                   DispatchQueue.main.async {
                       self.weatherIconImageView.image = image
                   }
               } else {
                   print("Error fetching weather icon: \(error?.localizedDescription ?? "Unknown error")")
               }
           }.resume()
       }
}
