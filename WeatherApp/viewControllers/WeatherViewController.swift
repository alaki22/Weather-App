//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Ani Lakirbaia on 06.02.25.
//

/*
let apiKey = "129f6cefb806c76ad29b2d5b8dff653c"
*/

import Foundation
import UIKit
import CoreLocation
import CoreData

struct WeatherData: Codable {
    struct Sys: Codable {
        let country: String
    }
    var sys: Sys
    var name: String
    var weather: [Weather]
    var main: Main
    var wind: Wind
    var clouds: Clouds
}

struct Main: Codable {
    let temp: Double
    let humidity: Int
}

struct Weather: Codable {
    let description: String
    let icon: String
}

struct Wind: Codable {
    let speed: Double
    let deg: Int
}

struct Clouds: Codable {
    let all: Int
}
class WeatherViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate {
    
    var cities: [String] = []
    var weatherDataList: [WeatherData] = []
    
    let apiKey = "129f6cefb806c76ad29b2d5b8dff653c"
    var collectionView: UICollectionView!
    var popupView: CityPopupView?
    
    var loader: UIActivityIndicatorView!
    
    var locationManager: CLLocationManager!
    var userLocation: CLLocation?
    var pageControl: UIPageControl!
    private var addAction: UIAlertAction?
    var addButton: UIBarButtonItem?
    var refreshButton: UIBarButtonItem?
    
    private let DBContext = DBManager.shared.persistentContainer.viewContext
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Weather"
        view.backgroundColor = UIColor(hue: 0.5861, saturation: 0.5, brightness: 0.47, alpha: 1.0)
        
        
        setupNavigationBar()
        setupLocationManager()
        setupPageControl()
        setupCollectionView()
        setupLoader()
        self.loader.startAnimating()
    }

    
    
    
    func setupLocationManager() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
            self.locationManager.requestWhenInUseAuthorization()
            
        }
        
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager.startUpdatingLocation()
            case .denied, .restricted:
                self.pushErrorViewController(hideButton: true)
                print("Location access denied or restricted")
                self.loader.stopAnimating()
            default:
                break
            }
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let currentLocation = locations.first else { return }
            
            locationManager.stopUpdatingLocation()
            userLocation = currentLocation
            addUserLocationToCities(location: currentLocation)
        }
        
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Failed to get user's location: \(error.localizedDescription)")
            pushErrorViewController(hideButton: false)
        }
        
    func addUserLocationToCities(location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            if let error = error {
                print("Error reversing geocode: (error.localizedDescription)")
                return
            }
            if let city = placemarks?.first?.locality {
                print("City from location: (city)")

                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.loadSavedCities()
                    if let index = self.cities.firstIndex(of: city) {
                       
                        if index != 0 {
                            self.cities.remove(at: index)
                            self.cities.insert(city, at: 0)
                        } else {
                            print("(city) is already at the 0th index.")
                        }
                    } else {
                        self.cities.insert(city, at: 0)
                        self.saveCity(name: city)
                    }
                    self.fetchAllWeatherData()
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    
    
    func setupNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        title = "Today"
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]

        addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCity))
        addButton?.tintColor = .yellow
        navigationItem.rightBarButtonItem = addButton
        
        refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshWeather))
        refreshButton?.tintColor = .yellow
        navigationItem.leftBarButtonItem =  refreshButton
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func setupLoader() {
            loader = UIActivityIndicatorView(style: .large)
            loader.color = .yellow
            loader.center = view.center
            view.addSubview(loader)
    }
    
    
    override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()

            if collectionView.frame == .zero {
                collectionView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
            }


            if collectionView.bounds.width <= 0 || collectionView.bounds.height <= 0 {
                print("Invalid collectionView bounds")
                return
            }

            collectionView.collectionViewLayout.invalidateLayout()
        }
    
    
    func saveCity(name: String) {
        let context = DBContext
        let city = City(context: context)
        city.name = name

        do {
            try context.save()
        } catch {
            print("Failed to save city: (error)")
        }
    }

    func loadSavedCities() {
        let context = DBContext
        let fetchRequest: NSFetchRequest<City> = City.fetchRequest()

        do {
            let fetchedCities = try context.fetch(fetchRequest)
            cities = fetchedCities.compactMap { $0.name }
        } catch {
            print("Failed to fetch cities: (error)")
        }
    }
    
    
    
    @objc func addCity(){
        addButton?.isEnabled = false
        refreshButton?.isEnabled = false
        showAddCityPopup()
    }
    
    @objc func refreshWeather() {
        collectionView.isHidden = true
        self.loader.startAnimating()
        fetchAllWeatherData()
        collectionView.reloadData()
    }
    
    
    
    
    func showAddCityPopup() {
            popupView = CityPopupView(frame: view.bounds)
            popupView?.alpha = 0
            popupView?.onAddCity = { [weak self] city in
                self?.addNewCity(city: city)
            }

            if let popupView = popupView {
                view.addSubview(popupView)
            }

            UIView.animate(withDuration: 0.3) {
                self.popupView?.alpha = 1
            }

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
            popupView?.blurEffectView.addGestureRecognizer(tapGesture)
        }

        @objc func dismissPopup() {
           
            UIView.animate(withDuration: 0.3, animations: {
                self.popupView?.alpha = 0
            }) { _ in
                self.popupView?.removeFromSuperview()
            }
            
            addButton?.isEnabled = true
            refreshButton?.isEnabled = true
        }

    
    
    func addNewCity(city: String) {
        if cities.contains(city){
            self.dismissPopup()
            return
        }
        cities.append(city)
        saveCity(name: city)
        fetchWeather(for: city) { [weak self] weatherData in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let weatherData = weatherData {
                    self.weatherDataList.append(weatherData)
                    self.pageControl.numberOfPages = self.cities.count
                    self.collectionView.reloadData()
                }
                self.dismissPopup()
            }
        }
    }
    
    func setupPageControl() {
        pageControl = UIPageControl()
        pageControl.numberOfPages = cities.count
        pageControl.currentPage = 0
        pageControl.tintColor = .yellow
        pageControl.pageIndicatorTintColor = .white
        pageControl.currentPageIndicatorTintColor = .yellow
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageControl)
            
        NSLayoutConstraint.activate([
            pageControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    
    func setupCollectionView() {
        let layout = CustomCollectionLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.decelerationRate = .fast
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(WeatherCell.self, forCellWithReuseIdentifier: WeatherCell.identifier)
        collectionView.backgroundColor = UIColor(hue: 0.5861, saturation: 0.5, brightness: 0.47, alpha: 1.0)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
         collectionView.addGestureRecognizer(longPressGesture)
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
                collectionView.topAnchor.constraint(equalTo: pageControl.bottomAnchor),
                collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
                collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
                collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10)
            ])
    }
    
    var weatherDataDict: [String: WeatherData] = [:]

    func fetchAllWeatherData() {
        weatherDataDict.removeAll()
        self.loader.startAnimating()
        
        let group = DispatchGroup()
        for city in cities {
            print(city)
            group.enter()
            fetchWeather(for: city) { weatherData in
                print("fetching for \(city)")
                if let weatherData = weatherData {
                    self.weatherDataDict[city] = weatherData
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.weatherDataList = self.cities.compactMap { self.weatherDataDict[$0] }
            self.loader.stopAnimating()
            self.collectionView.reloadData()
            self.collectionView.isHidden = false
            self.pageControl.numberOfPages = self.cities.count
        }
    }

    
    
    func fetchWeather(for city: String, completion: @escaping (WeatherData?) -> Void) {
        guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            pushErrorViewController(hideButton: false)
            completion(nil)
            return
        }

       let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(encodedCity)&appid=\(apiKey)&units=metric"
        guard let url = URL(string: urlString) else {
            pushErrorViewController(hideButton: false)
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error: (error.localizedDescription)")
                DispatchQueue.main.async {
                    self.pushErrorViewController(hideButton: false)
                }
                completion(nil)
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.pushErrorViewController(hideButton: false)
                }
                completion(nil)
                return
            }

            do {
                let decodedData = try JSONDecoder().decode(WeatherData.self, from: data)
                DispatchQueue.main.async {
                    completion(decodedData)
                }
            } catch {
                print("Error decoding JSON: (error)")
                DispatchQueue.main.async {
                    self.pushErrorViewController(hideButton: false)
                }
                completion(nil)
            }
        }.resume()
    }

    private func pushErrorViewController(hideButton : Bool) {
            if let navController = self.navigationController {
                    let errorVC = ErrorViewController()
                    errorVC.hideButton = hideButton
                    errorVC.navigationItem.hidesBackButton = hideButton
                    errorVC.refresh = self.refreshWeather
                    navController.pushViewController(errorVC, animated: true)
                }
    }
    
    
    @objc
    private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: collectionView)
        if let indexPath = collectionView.indexPathForItem(at: location){
            showDeleteConfirmation(at: indexPath)
        }
    }
    
    private func showDeleteConfirmation(at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "Delete City?",
            message: "City will be deleted permanently",
            preferredStyle: .actionSheet
        )
        addAction = UIAlertAction(
            title: "Delete",
            style: .destructive,
            handler: { [unowned self] _ in
                deleteCity(at: indexPath)
            }
        )
        alert.addAction(addAction!)
        alert.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil
        ))
        
        if presentedViewController == nil {
                present(alert, animated: true, completion: nil)
            }
    }
    
    
    
   
        
    private func deleteCity(at indexPath: IndexPath) {
        let cityToDelete = cities[indexPath.item]

        if let cityEntity = fetchCityEntityByName(cityToDelete) {
            DBContext.delete(cityEntity)

            do {
                try DBContext.save()

            } catch {
                print("Failed to delete city: (error)")
            }
            
            cities.remove(at: indexPath.item)
            self.refreshWeather()
            self.loader.stopAnimating()
        } else {
            print("City not found in Core Data")
        }
    }
    
    func fetchCityEntityByName(_ name: String) -> City? {
        let fetchRequest: NSFetchRequest<City> = City.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)

        do {
            let results = try DBContext.fetch(fetchRequest)
            return results.first
        } catch {
            print("Failed to fetch city: (error)")
            return nil
        }
    }
    
    func updatePageControl() {
        let pageWidth = collectionView.frame.width - 80
                let page = Int((collectionView.contentOffset.x + pageWidth / 2) / pageWidth)
                pageControl.currentPage = page
       }

      func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
           updatePageControl()
       }
    
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weatherDataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeatherCell.identifier, for: indexPath) as! WeatherCell
        let weatherData = weatherDataList[indexPath.row]
        cell.weatherData = weatherData
        return cell
    }
    
    

    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            
        let selectedCity = cities[indexPath.item]
        let forecastVC = CityForecastViewController()
        forecastVC.cityName = selectedCity
        forecastVC.pushErrorViewController = { self.pushErrorViewController(hideButton: false)}
        navigationController?.pushViewController(forecastVC, animated: true)
    }
    
}


