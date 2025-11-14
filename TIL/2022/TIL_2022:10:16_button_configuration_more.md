### Today I Learned

----

2022.10.16 (일)



UIButton.Configuration을 조금 더 깊게 파보겠습니다. 

### 기본적인 요소 

```swift
// 선언
var configuration = UIButton.Configuration.filled() 

// 표시되는 UI 
configuration.title = "버튼입니다"
configuration.subtitle = "서브 타이틀입니다"
configuration.image = .init(systemName: "xmark")

// UI의 간격 및 위치, 사이즈 조절
configuration.titleAlignment = .center
configuration.titlePadding = 10
configuration.imagePlacement = .trailing
configuration.imagePadding = 10
configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .medium)

// 사이즈 
configuration.buttonSize = .mini 
configuration.buttonSize = .small
configuration.buttonSize = .medium  
configuration.buttonSize = .large 
```

> 사이즈가 있지만 Constriaint를 지정하면 이 값은 무시됩니다. 왜 있는 지 모르겠습니다. 단지 개발자가 ""이 버튼의 사이즈는 이정도이다."라고 명세하는 용도로만 사용되는 것 같습니다.
> [아래 영어는 문서에 작성된 buttonSize의 Discussion](https://developer.apple.com/documentation/uikit/uibutton/configuration/3750783-buttonsize):
> The size indicates a system-defined size you prefer for this button. The exact size of the button may change regardless of this value.

```swift
configuration.cornerStyle = .small
configuration.cornerStyle = .medium
configuration.cornerStyle = .large
configuration.cornerStyle = .capsule
configuration.cornerStyle = .dynamic
```

`cornerStyle`은 background corner radius를 무시하고 버튼 corner radius를 설정하는 프로퍼티입니다. 여기서 `fixed` 케이스만 혼자만 background corner radius를 따릅니다. 

> 그런데, dynamic과 fixed의 차이가 뭘까? 이건 쫌 나중에 찾아봅시다.

```swift
configuration.cornerStyle = .fixed
configuration.background.cornerRadius = 14
```

----

### 조금 깊게 - 버튼 제목 프로퍼티 수정하기

```swift
configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
		var outgoing = incoming
		outgoing.font = UIFont.preferredFont(forTextStyle: .headline)
		return outgoing
}
```

incoming과 outgoing은 `AttributeContainer` 타입입니다. title과 관련된 attribute를 수정하고 반환합니다.

> AttributeContainer도 나중에 공부합시다. 일단은 UILabel의 여러 프로퍼티들을 가지고 있는 타입이라고만 알아둡시다.

---

### 더욱 깊게 - 로딩 버튼 

```swift
button.configurationUpdateHandler = { [unowned self] button in
  var config = button.configuration
  config?.showsActivityIndicator = self.signingIn
  config?.imagePlacement = self.signingIn ? .leading : .trailing
  config?.title = self.signingIn ? "Signing In..." : "Sign In"
  button.isEnabled = !self.signingIn
  button.configuration = config
}

// Configuration 업데이트
button.setNeedsUpdateConfiguration()
```

버튼에서 `showsActivityIndicator`프로퍼티를 통해 `Indicator`를 보여줄 수 있습니다. 해당 프로퍼티는 Configuration에 속해있고 보여주기 위해서는 버튼의 Configuration을 업데이트해야합니다. 이 때 `configurationUpdateHandler`프로퍼티를 사용합니다. Configuration 업데이트 클로저를 작성한 후 직접 업데이트를 하기 위해서는 `setNeedsUpdateConfiguration()`메소드를 호출합니다.

> [unowned self]를 사용하는 이유에 대해서 한번 생각해봅시다.

----

### 더욱 깊게 - 토글 버튼 

```swift
button.configurationUpdateHandler = { [unowned self] button in
  var config = button.configuration
  let symbolName = self.isBookInCart ? "cart.badge.minus" : "cart.badge.plus"
  config?.image = UIImage(systemName: symbolName)
  button.configuration = config
}

// Configuration 업데이트
button.setNeedsUpdateConfiguration()
```

토글 버튼은 로딩 버튼에서 이용했던 `configurationUpdateHandler`프로퍼티를 그대로 사용하면 됩니다. 

----

### 더욱 깊게 - 팝업 버튼

```swift
button.showsMenuAsPrimaryAction = true
button.menu = UIMenu(children: [
    UIAction(title: "Action 1", image: UIImage(systemName: "hare.fill")) { _ in
      print("Action 1")
    },
    UIAction(title: "Action 2", image: UIImage(systemName: "tortoise.fill")) { _ in
      print("Action 2")
    }
])

button.changesSelectionAsPrimaryAction = true
```

팝업버튼은 `showsMenuAsPrimaryAction`프로퍼티를 true로 설정하고 `menu`에 `UIAction`을 담아줘야합니다. `changesSelectionAsPrimaryAction`을 true로 설정한다면 팝업이 나올 때 마지막에 선택한 Action이 선택이 된 상태로 나옵니다. (만일 처음이라면 첫번째 Action이 선택되어져있습니다.)

----

### 더욱 깊게 - UIAction

```swift
let button = UIButton(configuration: .filled(), primaryAction: UIAction(handler: { action in
    print("안녕")
}))
```

UIAction은 메뉴의 하나의 기능으로, 클로저를 통해 액션을 실행합니다. 메뉴의 일종이지만 버튼의 initiailzer에도 설정할 수 있어서 `addTarget`대신 사용할 수도 있습니다. 하지만 버튼의 초기화이후에는 버튼에 따로 설정할 수 는 없습니다. 





### UIButton Configuration Ref

- https://www.raywenderlich.com/27854768-uibutton-configuration-tutorial-getting-started
- https://github.com/wody-d/woody-iOS-tip/issues/22
- https://developer.apple.com/documentation/uikit/uiaction