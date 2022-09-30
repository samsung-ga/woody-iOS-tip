//
//  CodeBasedViewController.swift
//  CustomButton
//
//  Created by Woody on 2022/07/07.
//

import UIKit

class CodeBasedViewController: UIViewController {
    @IBOutlet weak var contentView: UIView!
    
    private lazy var button1: UIButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(button1Pressed), for: .touchUpInside)
        $0.backgroundColor = .black
        $0.setTitle("버튼1", for: .normal)
        $0.tintColor = .white
        $0.titleLabel?.font = .boldSystemFont(ofSize: 25)
        $0.layer.cornerRadius = 16
        
        return $0
    }(UIButton(type: .system))
    
    private lazy var button2: UIButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(button2Pressed), for: .touchUpInside)
        $0.backgroundColor = .black
        $0.setTitle("버튼2", for: .normal)
        $0.tintColor = .white
        $0.titleLabel?.font = .boldSystemFont(ofSize: 25)
        $0.layer.cornerRadius = 16
        
        return $0
    }(UIButton(type: .custom))
    
    private lazy var button3: UIButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(button3Pressed), for: .touchUpInside)
        $0.backgroundColor = .black
        $0.setTitle("버튼3", for: .normal)
        $0.tintColor = .white
        $0.titleLabel?.font = .boldSystemFont(ofSize: 25)
        $0.layer.cornerRadius = 16
        $0.setImage(UIImage(systemName: "paperplane"), for: .normal)
        
        return $0
    }(UIButton(type: .system))
    
    private lazy var button4: UIButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(button4Pressed), for: .touchUpInside)
        $0.configuration?.baseBackgroundColor = .systemBlue
        $0.configuration?.cornerStyle = .dynamic
        $0.configuration?.background.cornerRadius = 16
        $0.configuration?.title = "버튼4"
        $0.configuration?.image = UIImage(systemName: "paperplane")
        $0.configuration?.imagePlacement = .trailing
        
        var container = AttributeContainer()
        container.font = UIFont.boldSystemFont(ofSize: 25)
        
        $0.configuration?.attributedTitle = AttributedString("버튼4", attributes: container)
        
        return $0
    }(UIButton(configuration: .filled()))

    private lazy var button5: UIButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(button4Pressed), for: .touchUpInside)
        $0.configuration?.baseBackgroundColor = .systemBlue
        $0.configuration?.cornerStyle = .dynamic
        $0.configuration?.background.cornerRadius = 16
        $0.configuration?.title = "버튼5"
        $0.configuration?.image = UIImage(systemName: "paperplane")
        $0.configuration?.imagePlacement = .trailing
        
        var container = AttributeContainer()
        container.font = UIFont.boldSystemFont(ofSize: 25)
        
        $0.configuration?.attributedTitle = AttributedString("버튼5", attributes: container)
        
        return $0
    }(UIButton(configuration: .filled(), primaryAction: UIAction(handler: { action in
        print("button5 눌림")
    })))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
    }
    
    private func layout() {
        
        view.addSubview(button1)
        
        NSLayoutConstraint.activate([
            button1.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            button1.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            button1.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 30),
            button1.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        view.addSubview(button2)
        
        NSLayoutConstraint.activate([
            button2.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            button2.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            button2.topAnchor.constraint(equalTo: button1.bottomAnchor, constant: 30),
            button2.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        view.addSubview(button3)
        
        NSLayoutConstraint.activate([
            button3.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            button3.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            button3.topAnchor.constraint(equalTo: button2.bottomAnchor, constant: 30),
            button3.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        view.addSubview(button4)
        
        NSLayoutConstraint.activate([
            button4.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            button4.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            button4.topAnchor.constraint(equalTo: button3.bottomAnchor, constant: 30),
            button4.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        view.addSubview(button5)
        
        NSLayoutConstraint.activate([
            button5.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            button5.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            button5.topAnchor.constraint(equalTo: button4.bottomAnchor, constant: 30),
            button5.heightAnchor.constraint(equalToConstant: 50)
        ])
        
    }
    
    @objc private func button1Pressed() {
        print("button1 눌림")
    }
    
    @objc private func button2Pressed() {
        print("button2 눌림")
    }
    
    @objc private func button3Pressed() {
        print("button3 눌림")
    }

    @objc private func button4Pressed() {
        print("button4 눌림")
    }

}
