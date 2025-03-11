//
//  ErrorViewController.swift
//  WeatherApp
//
//  Created by Ani Lakirbaia on 23.02.25.
//

import Foundation
import UIKit



class ErrorViewController: UIViewController {
    var reloadButton: UIButton?
    var refresh: (() -> Void)?
    var hideButton: Bool?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        print(hideButton)
        if hideButton! == true {
            reloadButton?.isHidden = true
        }
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(hue: 0.5861, saturation: 0.5, brightness: 0.47, alpha: 1.0)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        let cloudImageView = UIImageView()
        cloudImageView.image = UIImage(systemName: "cloud.fill")
        cloudImageView.tintColor = .systemGray
        cloudImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(cloudImageView)
        
        
        let warningImageView = UIImageView()
        warningImageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
        warningImageView.tintColor = .systemYellow
        warningImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(warningImageView)
        
        
        let errorLabel = UILabel()
        errorLabel.text = "Error occurred while loading data"
        errorLabel.textColor = .white
        errorLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        errorLabel.textAlignment = .center
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(errorLabel)
        
        
        reloadButton = UIButton(type: .system)
        reloadButton?.setTitle("Reload", for: .normal)
        reloadButton?.setTitleColor(.white, for: .normal)
        reloadButton?.backgroundColor = .systemYellow
        reloadButton?.layer.cornerRadius = 10
        reloadButton?.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        reloadButton?.translatesAutoresizingMaskIntoConstraints = false
        reloadButton?.addTarget(self, action: #selector(reloadData), for: .touchUpInside)
        containerView.addSubview(reloadButton!)
        
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            cloudImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            cloudImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            cloudImageView.widthAnchor.constraint(equalToConstant: 150),
            cloudImageView.heightAnchor.constraint(equalToConstant: 130),
            
            warningImageView.centerXAnchor.constraint(equalTo: cloudImageView.centerXAnchor, constant: 10),
            warningImageView.centerYAnchor.constraint(equalTo: cloudImageView.centerYAnchor, constant: 40),
            warningImageView.widthAnchor.constraint(equalToConstant: 60),
            warningImageView.heightAnchor.constraint(equalToConstant: 60),
            
            errorLabel.topAnchor.constraint(equalTo: cloudImageView.bottomAnchor, constant: 10),
            errorLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            reloadButton!.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 15),
            reloadButton!.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            reloadButton!.widthAnchor.constraint(equalToConstant: 120),
            reloadButton!.heightAnchor.constraint(equalToConstant: 40),
            reloadButton!.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    @objc private func reloadData() {
        self.refresh!()
        let Vc = WeatherViewController()
        navigationController?.pushViewController(Vc, animated: true)
    }
    
    
}
