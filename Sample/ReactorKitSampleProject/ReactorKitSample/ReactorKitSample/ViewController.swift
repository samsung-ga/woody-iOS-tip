//
//  ViewController.swift
//  ReactorKitSample
//
//  Created by Woody on 2022/08/04.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

final class ViewController: UIViewController, View {

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var plusButton: UIButton!

    var disposeBag = DisposeBag()
    let counterViewReactor: CounterViewReactor = CounterViewReactor()

    override func viewDidLoad() {
        bind(reactor: counterViewReactor)
    }

    func bind(reactor: CounterViewReactor) {
        plusButton.rx.tap
            .map { CounterViewReactor.Action.plus }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        minusButton.rx.tap
            .map { CounterViewReactor.Action.minus }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state
            .map { "\($0.number)" }
            .distinctUntilChanged()
            .bind(to: numberLabel.rx.text)
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.isLoading }
            .distinctUntilChanged()
            .bind(to: loadingIndicator.rx.isAnimating)
            .disposed(by: disposeBag)

        reactor.state
            .map { !$0.isLoading }
            .distinctUntilChanged()
            .bind(to: loadingIndicator.rx.isHidden)
            .disposed(by: disposeBag)

        reactor.pulse(\.$alertMessage)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] message in
                let alertViewController = UIAlertController(
                    title: nil,
                    message: message,
                    preferredStyle: .alert
                )
                alertViewController.addAction(UIAlertAction(
                    title: "OK",
                    style: .default
                ))
                self?.present(alertViewController, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
