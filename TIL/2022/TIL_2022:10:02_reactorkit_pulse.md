### Today I Learend

----

2022.10.02 (일)

<br />

### @Pulse (in ReactorKit)

[@Pulse](https://github.com/ReactorKit/ReactorKit#pulse)라는 프로퍼티 래퍼에 대해 정리해볼게요.

> `Pulse` has diff only when mutated 

Pulse는 변화가 있을 때에만 변화를 준다고 합니다. 사실 이 정의만 보았을 때는 잘 이해가 되지 않았어요. 그래서 직접 만들어보면서 이해해보았습니다. 아래는 버튼 2개로 이루어진 PulseViewController와 State 3개를 가지고 있는 PulseReactor입니다. 

```swift
class PusleViewController: UIViewController { 
		
  	// UI 코드 생략
  
    func bind(reactor: Reactor) {
        stateButton.rx.tap.map { .didTapStateButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        pulseButton.rx.tap.map { .didTapPulseButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state
            .map { "\($0.value)" }
            .subscribe(onNext: { value in
                print("👋🏻👋🏻👋🏻 상태 1")
            }).disposed(by: disposeBag)

        reactor.state
            .map { $0.message }
            .subscribe(onNext: { message in
                print("🚀🚀🚀 상태 2")
            }).disposed(by: disposeBag)

        reactor.pulse(\.$error)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { _ in
                print("✨✨✨ 펄스 ")
            }).disposed(by: disposeBag)
    }

}
```

```swift
class PulseReactor: Reactor {

    enum Action {
        case didTapStateButton
        case didTapPulseButton
    }

    struct State {
        var message: String = ""
        var value: String = ""

        @Pulse var error: String?
    }

    var initialState: State = State()

    func reduce(state: State, mutation: Action) -> State {
        var newState = state
        switch mutation {
        case .didTapStateButton:
            newState.message = "메세지"
        case .didTapPulseButton:
            newState.error = "펄스"
        }
        return newState
    }
}
```
<br />

**왜 필요할까?**

Pulse는 값에 할당이 될때에 무조건 방출하는 프로퍼티 래퍼입니다. 보통 State는 값에 변화가 있든 없든 매번 방출이 됩니다. 그렇기에 값에 변화가 없어도 구독한 객체는 항상 변화가 일어납니다. 

```swift
reactor.state
	.map { "\($0.value)" }
	.subscribe(onNext: { value in
	    print("👋🏻👋🏻👋🏻 상태 1")
	}).disposed(by: disposeBag)

```

해당 state가 변화가 일어나지 않아도 action -> mutate를 거쳐 reduce 통해 state가 반환되기 때문입니다. 아래 코드에서 didTapStateButton 액션이 실행되어 message 상태만 변화해도 모든 상태가 반환되어 바인딩된 객체에 전달됩니다. 

```swift
    func reduce(state: State, mutation: Action) -> State {
        var newState = state
        switch mutation {
        case .didTapStateButton:
            newState.message = "메세지"
        case .didTapPulseButton:
            newState.error = "펄스"
        }
        return newState
    }ㅓ
```

이럴 때 보통 map을 통해 특정 state로 변환한 후 `distinctUntilChanged()`메소드를 통해 해당 값이 변할 때만 이벤트를 받도록 합니다. 전달되는 Element가 Equtable 프로토콜을 채택하고 있다면 이전에 전달된 값과 비교하여 값이 같다면 두번째 element부터 전달하지 않고, 값이 다르다면 element를 전달됩니다.

```swift
reactor.state
	.map { "\($0.value)" }
	.distinctUntilChanged()
	.subscribe(onNext: { value in
	    print("👋🏻👋🏻👋🏻 상태 1") // distinctUntilChanged 사용하 때 이슈 있음 (마지막)
	}).disposed(by: disposeBag)
```

왼쪽은, value에 대해 distinctUntilChanged 없이 출력. 오른쪽은 valueㅇ 대해 distinctUntilChanged 있이 출력.

<img src="https://user-images.githubusercontent.com/56102421/193439670-6ca8b17b-9514-4c00-af9c-604aaee57266.gif" width="300" />          <img src="https://user-images.githubusercontent.com/56102421/193439672-f5a2cfaf-458f-4d25-96d2-2f95f8a9a84c.gif" width="300" />

<br />
정리하면, State가 변화하든 안하든, 항상 이벤트는 전달되는데 `distinctUntilChanged()`를 통해 특정 state가 변화할 때만 이벤트를 받도록 할 수 있습니다.

그럼, 특정 state의 값이 변화하지 않을 때에도 해당 state에 값이 할당되면 이벤트를 받도록 하고 싶은 경우에는 어떻게 해야할까요? 

`distinctUntilChanged()`를 사용하지 않으면 되는 거 아닌가?? 라고 처음엔 생각했지만 전혀 상관 없는 state가 변화해도 이벤트가 전달되는 경우가 있기 때문에 적절한 경우가 아니예요. 이 상황에 `@Pulse`가 필요합니다!

<br /> 

**Pulse 뜯어보기:**

Pulse가 구현된 코드는 비교적 이해하기 쉬워요. value에 값이 할당되면 `riseValueUpdatedCount()`메소드가 불립니다. 그리고       valueUpdatedCount 를 1증가시켜요. 

```swift
  public var value: Value {
    didSet {
      self.riseValueUpdatedCount()
    }
  }
  public internal(set) var valueUpdatedCount = UInt.min
  private mutating func riseValueUpdatedCount() {
    if self.valueUpdatedCount == UInt.max {
      self.valueUpdatedCount = UInt.min
    } else {
      self.valueUpdatedCount += 1
    }
  }
```

pulse() 메소드를 살펴보면, 새로운 pulse와 기존 pulse의 valueUpdatedCount를 비교하는 `distinctUntilChanged`로 구현되어 있습니다. value가 아닌 valueUpdatedCount를 비교하므로 같은 값이 할당되어도 이벤트를 방출합니다. 만일 다른 프로퍼티가 변하더라도 valueUpdatedCount는 같기 때문에 이벤트를 방출하지 않네요.

```swift

extension Reactor {
  public func pulse<Result>(_ transformToPulse: @escaping (State) throws -> Pulse<Result>) -> Observable<Result> {
    return self.state.map(transformToPulse).distinctUntilChanged(\.valueUpdatedCount).map(\.value)
  }
}

```

<br /> 

**Pulse로 선언하기**:

Pulse 프로퍼티 래퍼로 선언하게 된다면, 해당 state가 변화가 있든 없든 할당이 된다면 이벤트가 항상 전달됩니다. 다른 state와는 전혀 상관이 없습니다. 사용법은 아래 코드와 같아요.

```swift
 reactor.pulse(\.$error)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { _ in
                print("✨✨✨ 펄스 ")
            }).disposed(by: disposeBag)
```

 error 프로퍼티에 할당이 될 때 이벤트가 전달됩니다.  

```swift
 func reduce(state: State, mutation: Action) -> State {
        var newState = state
        switch mutation {
        case .didTapStateButton:
            newState.message = "메세지"
        case .didTapPulseButton: 
            newState.error = "펄스" // ✅ 할당
        }
        return newState
    }
```

<br />**마무리 :**

Pulse는 에러 처리를 위한 토스트 메시지나 알림창에 자주 쓰일 것 같아요. ReactorKit 레포에도 알림 메시지에 대한 예제가 있어요. 값이 변해서 UI에 변화가 생겨야 하는 경우에 쓰는 것이 아니고 항상 값은 일정한데 할당이 되는 경우에 써야하니까요. (오류메시지는 대부분 일정하니까), 또한, 화면전환을 상태로 관리할 때에도 유용할 것 같습니다. 



추가로, distinctUntilChange에서 만난 이슈 하나를 공유하자면.. 아래와 같이 작성하면 swift가 타입추론을 하지 못해 오류가 나요. 

<img width="874" alt="스크린샷 2022-10-02 오후 2 41 42" src="https://user-images.githubusercontent.com/56102421/193439808-e70ac524-c2b2-4950-8605-ebfb909ce3af.png">


distintUntilChanged에서 비교하는 Element는 Equtable 프로토콜을 채택하는데, 이는 방출하는 Element로 비교해서..? 일듯한데.. 정확하진 않고... 조금 더 알아봐야겠어요. 

```swift
extension ObservableType where Element: Equatable {

    /**
     Returns an observable sequence that contains only distinct contiguous elements according to equality operator.

     - seealso: [distinct operator on reactivex.io](http://reactivex.io/documentation/operators/distinct.html)

     - returns: An observable sequence only containing the distinct contiguous elements, based on equality operator, from the source sequence.
     */
    public func distinctUntilChanged()
        -> Observable<Element> {
        self.distinctUntilChanged({ $0 }, comparer: { ($0 == $1) })
    }
}
```

<br /><br /><br />

- https://github.com/ReactorKit/ReactorKit#pulse
