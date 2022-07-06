//
//  ViewController.swift
//  CustomButton
//
//  Created by Woody on 2022/07/06.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let button1 = UIButton(type: .system)
        button1.translatesAutoresizingMaskIntoConstraints = false
        button1.addTarget(self, action: #selector(button1Pressed), for: .touchUpInside)
        button1.backgroundColor = .black
        button1.setTitle("버튼1", for: .normal)
        button1.tintColor = .white
        button1.titleLabel?.font = .boldSystemFont(ofSize: 25)
        button1.layer.cornerRadius = 16
        
        view.addSubview(button1)
        
        NSLayoutConstraint.activate([
            button1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            button1.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            button1.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -200),
            button1.heightAnchor.constraint(equalToConstant: 80)
        ])
        
//        var configuration = UIButton.Configuration.filled()
//        configuration.baseBackgroundColor = .black
//        configuration.baseForegroundColor = .white
//        configuration.title = "버튼2"
//        configuration.subtitle = "버튼2 서브타이틀"
        
        let action = UIAction(title: "button2") { (action: UIAction) in
            // 터치
            print("터치", action.title)
        }
        
        
        let button2 = UIButton(primaryAction: action)
        button2.configuration = .filled()
        button2.configuration?.title = "버튼2"
        button2.configuration?.subtitle = "버튼2 서브타이틀"
        button2.configuration?.baseBackgroundColor = .black
        button2.configuration?.baseForegroundColor = .white
        button2.configuration?.cornerStyle = .dynamic
               
        button2.translatesAutoresizingMaskIntoConstraints = false
        button2.layer.cornerRadius = 16
//        button2.titleLabel?.font = .boldSystemFont(ofSize: 25)
        view.addSubview(button2)
        
        NSLayoutConstraint.activate([
            button2.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            button2.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            button2.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            button2.heightAnchor.constraint(equalToConstant: 80)
        ])
        
    }

    @objc
    private func button1Pressed() {
        
    }
}
