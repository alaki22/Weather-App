//
//  ForecastCell.swift
//  WeatherApp
//
//  Created by Ani Lakirbaia on 09.02.25.
//
import UIKit

class ForecastCell: UITableViewCell {
    private let timeLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let temperatureLabel = UILabel()
    private let weatherIconImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor(hue: 0.5861, saturation: 0.5, brightness: 0.47, alpha: 1.0)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        
        let labelsStackView = UIStackView(arrangedSubviews: [timeLabel, descriptionLabel])
        labelsStackView.axis = .vertical
        labelsStackView.spacing = 4
        labelsStackView.alignment = .leading
        
        
        let mainStackView = UIStackView(arrangedSubviews: [weatherIconImageView, labelsStackView, temperatureLabel])
        mainStackView.axis = .horizontal
        mainStackView.spacing = 16
        mainStackView.alignment = .center

        addSubview(mainStackView)

        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        weatherIconImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            
            weatherIconImageView.widthAnchor.constraint(equalToConstant: 70),
            weatherIconImageView.heightAnchor.constraint(equalToConstant: 70),

            temperatureLabel.heightAnchor.constraint(equalToConstant: 50)
        ])

        temperatureLabel.textColor = .yellow
        temperatureLabel.textAlignment = .right
        timeLabel.textColor = .white
        descriptionLabel.textColor = .white

        timeLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        temperatureLabel.font = UIFont.systemFont(ofSize: 20)
    }

    func configure(with forecast: Forecast) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let date = Date(timeIntervalSince1970: forecast.dt)
        timeLabel.text = dateFormatter.string(from: date)

        descriptionLabel.text = forecast.weather.first?.description.capitalized
        temperatureLabel.text = "\(forecast.main.temp)°C"

        if let iconId = forecast.weather.first?.icon {
            let iconUrlString = "https://openweathermap.org/img/wn/\(iconId)@2x.png"
            if let iconUrl = URL(string: iconUrlString) {
                let dataTask = URLSession.shared.dataTask(with: iconUrl) { data, response, error in
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.weatherIconImageView.image = image
                        }
                    } else if let error = error {
                        print("Error loading icon: \(error.localizedDescription)")
                    }
                }
                dataTask.resume()
            }
        }
    }
}
