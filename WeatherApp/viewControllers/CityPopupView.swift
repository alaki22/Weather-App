//
//  CityPopupView.swift
//  WeatherApp
//
//  Created by Ani Lakirbaia on 07.02.25.
//

import Foundation
import UIKit

class CityPopupView: UIView {
    let apiKey = "129f6cefb806c76ad29b2d5b8dff653c"

    var onAddCity: ((String) -> Void)?

     let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blurEffect)
        view.alpha = 0.7
        return view
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Add City"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()

    private let cityTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter city name"
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        return textField
    }()

    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 30
        button.clipsToBounds = true
        return button
    }()

    private let loader: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView(style: .large)
        loader.hidesWhenStopped = true
        return loader
    }()

    private let plusIconImageView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold, scale: .default)
        let plusIcon = UIImage(systemName: "plus", withConfiguration: config)
        imageView.image = plusIcon
        imageView.tintColor = .white
        return imageView
    }()
    
    
    private let errorBanner: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.red
        view.layer.cornerRadius = 10
        view.alpha = 0
        return view
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        label.text = "Error Occurred\nCity with that name was not found!"
        label.numberOfLines = 2
        return label
    }()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(blurEffectView)
        addSubview(containerView)
        setupErrorBanner()
        containerView.addSubview(titleLabel)
        containerView.addSubview(cityTextField)
        containerView.addSubview(addButton)
        addButton.addSubview(loader)
        addButton.addSubview(plusIconImageView)

        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cityTextField.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        loader.translatesAutoresizingMaskIntoConstraints = false
        plusIconImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: topAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),

            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 280),
            containerView.heightAnchor.constraint(equalToConstant: 200),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

            cityTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            cityTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            cityTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            cityTextField.heightAnchor.constraint(equalToConstant: 40),

            addButton.topAnchor.constraint(equalTo: cityTextField.bottomAnchor, constant: 20),
            addButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 60),
            addButton.heightAnchor.constraint(equalToConstant: 60),

            loader.centerXAnchor.constraint(equalTo: addButton.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: addButton.centerYAnchor),

            plusIconImageView.centerXAnchor.constraint(equalTo: addButton.centerXAnchor),
            plusIconImageView.centerYAnchor.constraint(equalTo: addButton.centerYAnchor),
        ])

        addButton.addTarget(self, action: #selector(addCityTapped), for: .touchUpInside)
    }
    
    func setupErrorBanner(){
        addSubview(errorBanner)
        errorBanner.addSubview(errorLabel)

        errorBanner.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            errorBanner.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: -60),
            errorBanner.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            errorBanner.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            errorBanner.heightAnchor.constraint(equalToConstant: 60),

            errorLabel.centerXAnchor.constraint(equalTo: errorBanner.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: errorBanner.centerYAnchor)
        ])
    }
    
    func showErrorBanner() {
        UIView.animate(withDuration: 0.3, animations: {
            self.errorBanner.alpha = 1
            self.errorBanner.transform = CGAffineTransform(translationX: 0, y: 80)
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.hideErrorBanner()
            }
        }
    }

    func hideErrorBanner() {
        UIView.animate(withDuration: 0.3, animations: {
            self.errorBanner.alpha = 0
            self.errorBanner.transform = CGAffineTransform.identity
        })
    }
    
    @objc private func addCityTapped() {
        guard let city = cityTextField.text, !city.isEmpty else { return }

        addButton.isEnabled = false
        startLoader()
        validateCity(city: city) { [weak self] isValid in
            DispatchQueue.main.async {
                self?.restoreButton()
                if isValid {
                    self?.onAddCity?(city)
                } else {
                    self?.showErrorBanner()
                }
            }
        }
    }

    
    private func validateCity(city: String, completion: @escaping (Bool) -> Void) {
        guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(false)
            return
        }

        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(encodedCity)&appid=\(apiKey)&units=metric"
        guard let url = URL(string: urlString) else {
            completion(false)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, _ in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }.resume()
    }

    private func restoreButton() {
        addButton.isEnabled = true
        stopLoader()
        plusIconImageView.isHidden = false
    }



    private func startLoader() {
        loader.startAnimating()
        plusIconImageView.isHidden = true
    }

    private func stopLoader() {
        loader.stopAnimating()
        plusIconImageView.isHidden = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
