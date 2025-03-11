//
//  CityForecastViewController.swift
//  WeatherApp
//
//  Created by Ani Lakirbaia on 09.02.25.
//


import Foundation
import UIKit


struct CityForecastResponse: Codable {
    let list: [Forecast]
}

struct Forecast: Codable {
    let dt: TimeInterval
    let main: Temp
    let weather: [Description]
}

struct Temp: Codable {
    let temp: Double
}

struct Description: Codable {
    let description: String
    let icon: String
}

class CityForecastViewController: UIViewController, UITableViewDelegate {
    let apiKey = "129f6cefb806c76ad29b2d5b8dff653c"
    var cityName: String?
    private let tableView = UITableView()
    private var groupedForecasts: [String: [Forecast]] = [:]
    private var daysOfWeek: [String] = []
    var loader: UIActivityIndicatorView!
    var pushErrorViewController: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupLoader()
        self.loader.startAnimating()
        fetchForecast()
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor(hue: 0.5861, saturation: 0.5, brightness: 0.47, alpha: 1.0)
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.yellow
        ]
        navigationController?.navigationBar.tintColor = UIColor.yellow
    }
    

    private func setupUI() {
        view.backgroundColor =  UIColor(hue: 0.5861, saturation: 0.5, brightness: 0.47, alpha: 1.0)
        title = cityName
        

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ForecastCell.self, forCellReuseIdentifier: "ForecastCell")
        tableView.backgroundColor =  UIColor(hue: 0.5861, saturation: 0.5, brightness: 0.47, alpha: 1.0)
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setupLoader() {
            loader = UIActivityIndicatorView(style: .large)
            loader.color = .yellow
            loader.center = view.center
            view.addSubview(loader)
    }

    private func fetchForecast() {
        guard let cityName = cityName else {
            self.pushErrorViewController!()
            return
        }
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?q=\(cityName)&units=metric&appid=\(apiKey)"
       
        guard let url = URL(string: urlString) else {
            pushErrorViewController!()
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error: (error.localizedDescription)")
                DispatchQueue.main.async {
                    self.pushErrorViewController!()
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.pushErrorViewController!()
                }
                return
            }

            do {
                let decodedData = try JSONDecoder().decode(CityForecastResponse.self, from: data)
                DispatchQueue.main.async {
                    self.groupForecastsByDay(forecasts: decodedData.list)
                    self.loader.stopAnimating()
                    self.tableView.reloadData()
                }
            } catch {
                print("Error decoding JSON: (error)")
                DispatchQueue.main.async {
                    self.pushErrorViewController!()
                }
            }
        }.resume()
    }

    private func groupForecastsByDay(forecasts: [Forecast]) {
        let calendar = Calendar.current
        let today = Date()

        var grouped: [String: [Forecast]] = [:]
        var days: [String] = []
        var uniqueDaysCount = 0

        for forecast in forecasts {
            let date = Date(timeIntervalSince1970: forecast.dt)
            let dayKey = calendar.startOfDay(for: date)
            let dayOfWeek = calendar.weekdaySymbols[calendar.component(.weekday, from: date) - 1]

            
            if dayKey >= calendar.startOfDay(for: today) {
                if grouped[dayOfWeek] == nil {
                    if uniqueDaysCount >= 5 { break }
                    grouped[dayOfWeek] = []
                    days.append(dayOfWeek)
                    uniqueDaysCount += 1
                }
                grouped[dayOfWeek]?.append(forecast)
            }
        }

        self.groupedForecasts = grouped
        self.daysOfWeek = days
    }
}

extension CityForecastViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return daysOfWeek.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let day = daysOfWeek[section]
        return groupedForecasts[day]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return daysOfWeek[section]
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastCell", for: indexPath) as! ForecastCell
        let day = daysOfWeek[indexPath.section]
        let forecast = groupedForecasts[day]?[indexPath.row]
        if let forecast = forecast {
            cell.configure(with: forecast)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
            if let headerView = view as? UITableViewHeaderFooterView {
                headerView.contentView.backgroundColor = UIColor(hue: 0.5861, saturation: 0.5, brightness: 0.47, alpha: 1.0)
                headerView.textLabel?.textColor = .yellow
                headerView.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
                tableView.contentInset.top = 0
            }
        }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 50
        }
}
