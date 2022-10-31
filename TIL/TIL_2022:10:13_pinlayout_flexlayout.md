Today I Learned

----

2022.10.13 (목)

<br />

- [PinLayout 리드미에서 오류 발견 pr](https://github.com/layoutBox/PinLayout/pull/254)

### PinLayout & FlexLayout 성능 비교 그래프 

PinLayout & FlexLayout은 오토레이아웃을 이용한 레이아웃 방식이 아닙니다. 따라서 자동으로 오토레이아웃을 잡아주는 UIStackView보다 8~12배 성능이 좋습니다. 이 프레임워크들은 메인스레드에서만 사용할 수 있는 뷰를 백그라운드 스레드로 끌고와 연산 처리를 하기 때문입니다. [제드님의 댓글](https://zeddios.tistory.com/1251)을 참고했습니다. 이번엔 이 프레임워크들을 어떻게 사용하는 지 공부해보겠습니다.

<img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/abc.png" width="600">

### PinLayout?

<div align="center"><img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/pinlayout-logo-text.png" width="200"></div>

- CSS의 절대 위치 방식을 차용해 만든 레이아웃 프레임워크 (오토레이아웃이 아님)
- 오토레이아웃이 아니기 때문에 contianer의 크기가 바뀌거나 디바이스 회전모드가 바뀔 때 `UIView.layoutSubviews()`나 `UIViewController.viewDidLayoutSubviews()`에서 레이아웃을 업데이트해주어야합니다. (그래서 간단한 구성의 뷰에서 작성하나봐요.)
- 코드 한 줄에, 하나의 View를 레이아웃해줍니다. 

```swift
label1.pin.topLeft().size(100)
label2.pin.top().after(of: label1).size(100)
label3.pin.left().below(of: label1).width(200).height(100)
```

- `pin`으로 시작하고 레이아웃을 구성하는 여러가지 메소드들을 제공합니다. (SnapKit의 `snp`와 비슷하게 사용됩니다.)

```swift
let label1 = UILabel()
label1.backgroundColor = .systemBlue
self.view.addSubview(label1)
let label2 = UILabel()
label2.backgroundColor = .systemRed
self.view.addSubview(label2)
let label3 = UILabel()
label3.backgroundColor = .systemMint
self.view.addSubview(label3)
```

### Edges Layout

```swift
label1.pin.top(10).bottom(10).left(10).right(10)
label1.pin.all(10)
label1.pin.top(view.pin.safeArea.top)
label1.pin.top(10%).bottom(10%).left(10%).right(10%)
```

top, bottom, left, right 하나하나 명시해서 사용 가능합니다., all로도 가능합니다, safeArea의 경우, `view.pin.safeArea`로 처리해야합니다. 파라미터에는 CGFloat, Percent, UIEdgeInsets 을 넣을 수 있습니다. CGFloat는 constraint와 마찬가지로 작동하고, Percent는 superview의 퍼센트를 계산해서 CGFloat로 변환해줍니다. 

```swift
top(_ offset: CGFloat) // 방법 1
top(_ offset: Percent) // 방법 2
top() // 방법 3
top(_ margin: UIEdgeInsets) // 방법 4
```

`top`, `bottom`, `left`, `right`, `start`, `end`, `horizontally`, `vertically`는 모두 위의 방법으로 사용 가능합니다. 

```swift
all(_ margin: CGFloat)
all()
all(_ margin: UIEdgeInsets)
```

`all` 은 Percent 파라미터를 사용할 수 없습니다. 

![pinlayout-anchors](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/pinlayout-anchors.png)

재밌는게 PinLayout에서는 topLeft, topRight와 같이 모서리에 뷰를 붙일 수 있는 메소드를 제공해줍니다. 

```swift
label1.pin.topRight().size(100)
```

위와 같이 코드를 작성하면 아래와 같은 결과를 얻을 수 있습니다. 

<div align="center"><img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-10-13%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%201.34.08.png" width="400"></div>

### Relative Edges Layout

상대적인 위치로 레이아웃을 잡을 수도 있습니다. `above(of: UIView)`,  `above(of: [UIView])`와 같이 UIView, 또는 UIVIew배열 파라미터로 잡을 수 있습니다. 만약 배열로 넣을 경우 가장 위에 위치한 뷰의 위에 새로운 뷰를 위치시킵니다. (snapkit에는 없었던 거라 신기합니다!) `below` `before` `after` `left` `right` 메소드를 제공합니다. 

```swift
label1.pin.topLeft().size(100)
label2.pin.top().after(of: label1).size(200)
label3.pin.below(of: [label1, label2]).size(300)
```

<div align="center"><img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-10-13%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%201.38.48.png" width="400"></div>

여러개의 뷰 레이아웃 관계를 이용해서 설정할 수도 있습니다. 두개의 뷰사이에 뷰를 위치시킬 수 있습니다. 

```swift
label1.pin.topLeft().size(100)
label2.pin.topRight().size(100)
label3.pin.after(of: label1).before(of: label2).height(100)
```

<div align="center"><img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-10-13%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%201.40.56.png" width="400"></div>

뷰와 align을 맞출 수 있습니다. 만약 A뷰의 right에 위치시킨다고 할 때엔 VerticalAlignment 또한 설정할 수 있습니다. 

```swift
label1.pin.top(50).left().size(100)
label2.pin.right(of: label1, aligned: .center).size(50)
label3.pin.right(of: [label1,label2], aligned: .center).size(50)
```

<div align="center"><img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-10-13%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%202.12.13.png" width="400"></div>

### Layout between other views

위와 다르게 아예 뷰사이에 위치시키는 메소드도 제공합니다. 

```swift
label1.pin.top(50).left().size(100)
label2.pin.top(50).right().size(100)
label3.pin.horizontallyBetween(label1, and: label2, aligned: .top).marginHorizontal(5).height(100)
```

<div align="center"><img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-10-13%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%202.17.16.png" width="400"></div>



등등이 있고 이외에도 정말 많은 메소드들을 제공합니다. (레이아웃은 많이 잡아보면서 느는 것!)

### 💄 Style guide 

- `view.pin.[EDGE|ANCHOR|RELATIVE].[WIDTH|HEIGHT|SIZE].[pinEdges()].[MARGINS].[sizeToFit()]`순으로 작성

```swift
 view.pin.top().left(10%).margin(10, 12, 10, 12)
 view.pin.left().width(100%).pinEdges().marginHorizontal(12)
 view.pin.horizontally().margin(0, 12).sizeToFit(.width)
 view.pin.width(100).height(100%)
```

- TOP, BOTTOM, LEFT, RIGHT 순으로 작성
- 레이아웃 코드가 너무 길면 개행

----

<div align="center"><img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/flexlayout-logo-text-2.png" width="200" ></div>

### FlexLayout?

- UIStackView를 개선한 레이아웃 프레임워크로 사용하기 간단하고 다양한 API를 제공합니다. 
- UIStackView보다 8~ 12배 빠름빠름!
- PinLayout말고 FlexLayout을 쓰는 상황 
  - 많은 뷰들의 레이아웃을 잡아야하는데 PinLayout의 세세한 컨트롤이 필요하지 않을 때 
  - 복잡한 애니메이션이 없을 때 
- PinLayout과 같이 사용되는 레이아웃 관련 프레임워크
  - PinLayout을 FlexLayout container 안에서 사용가능하고 반대로도 사용가능합니다. (상황에 맞게 선택)

### Setup 

먼저, container를 세팅합니다. 

```swift
class ExampleView: UIView {
    fileprivate let rootFlexContainer: UIView = UIView()

    init() {
        super.init(frame: .zero)
	      rootFlexContainer.flex.define { flex in
						// 레이아웃 코드 
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

```

그리고 container의 레이아웃을 잡아줍니다. `layoutSubviews()` 또는 `viewDidLayoutSubviews()`에서 container의 레이아웃을 잡고 `flex.layout()`으을 실행합니다. 

```swift
 override func layoutSubviews() {
      super.layoutSubviews()

      rootFlexContainer.pin.all(pin.safeArea)
      rootFlexContainer.flex.layout()
}
```

세팅이 완료됐습니다. 이제 레이아웃을 잡아주는  `flex.define()` 메소드에 대해서 알아보겠습니다. 

### define()

레이아웃 잡는 코드를 구조화시킬 때 사용합니다. `flex`타입을 파라미터로 이용해서 하위 뷰(아이템)들을 추가합니다. 아래 1과 2는 같은 작업을 하는 코드입니다. 

```swift
// 1 
view.flex.addItem().define { (flex) in
    flex.addItem(imageView).grow(1)
	
    flex.addItem().direction(.row).define { (flex) in
        flex.addItem(titleLabel).grow(1)
        flex.addItem(priceLabel)
    }
}

// 2 
let columnContainer = UIView()
columnContainer.flex.addItem(imageView).grow(1)
view.flex.addItem(columnContainer)
	
let rowContainer = UIView()
rowContainer.flex.direction(.row)
rowContainer.flex.addItem(titleLabel).grow(1)
rowContainer.flex.addItem(priceLabel)
columnContainer.flex.addItem(rowContainer)
```

아래는 `Flex`타입이 가진 메소드들입니다. container에 아래 설정들을 할 수 있습니다. 

| FlexLayout Name |
| --------------- |
| **`direction`** |
| **`wrap`**      |
| **`grow`**      |
| **`shrink`**    |
| **`basis`**     |
| **`start`**     |
| **`end`**       |

하나씩 둘러보도록 하겠습니다.

**direction**은 column, row를 설정할 수 있습니다. 디폴트값은 column입니다.

```swift
rootFlexContainer.flex.direction(.column).define { flex in
		flex.addItem(view1).height(40)
		flex.addItem(view2).height(40)
		flex.addItem(view3).height(40)
}
```

<div align="center"><img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-10-13%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%205.12.19.png" width="400"></div>

**wrap**은 flex container에 적용되는 메소드로, container 내의 아이템들이 여러줄일 때 다음 줄로 넘어갈지 아니면 한 줄에 보여줄 지 여부를 설정합니다. 디폴트는 nowrap으로 한 줄에 보여지도록 설정되어있습니다. 행을 축으로 하여 wrap설정을 하면 아래와 같이 나옵니다. 

```swift
rootFlexContainer.flex.direction(.row).wrap(.wrap).define { flex in
    flex.addItem(view1).width(50%).height(100)
    flex.addItem(view2).width(50%).height(100)
    flex.addItem(view3).width(50%).height(100)
}
```

<div align="center"><img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-10-13%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%205.32.00.png" width="400"></div>

**grow**는 flex item에 적용되는 것으로, 아이템이 더 커질 수 있을지에 대한 여부를 설정합니다. 디폴트는 0으로, 0이면 아이템은 커지지 않고 0이 아닌 0초과의 값들은 남는 공간을 모두 채워버립니다. (`grow`가 0인 아이템과 같이 쓰인 경우에) `grow`가 1인 아이템이 있다면 상대적 비율대로 다른 아이템보다 커집니다. 즉, 아이템이 모두 grow(1)로 설정되어있다면 아이템의 사이즈는 모두 같아집니다. 아이템1과 아이템2의 `grow`가 1과 2로 설정되어있다면 아이템2는 아이템 1보다 2배 커야합니다. **shrink**는 `grow`의 반대로 얼마나 더 줄어들 수 있는 지에 대한 여부를 설정합니다. 

> grow와 shrink는 텍스트로 설명하기에 굉장히 어렵습니다. 직접 작성해보아야합니다.

```swift
rootFlexContainer.flex.wrap(.wrap).define { flex in
    flex.addItem(view1).grow(1)
    flex.addItem(view2).grow(1)
    flex.addItem(view3).grow(2)
}
```

<div align="center"><img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/Simulator%20Screen%20Shot%20-%20iPhone%2014%20Pro%20-%202022-10-13%20at%2017.24.10.png" width="400" ></div>



**basis**는 flex item에 적용되는 것으로, 너비와 높이 값입니다. grow와 shrink에 의해서 남는  nil로 설정하면 `auto`라는 의미로 아이템의 크기와 같아집니다. 만약 아이템의 크기가 정해져있지 않다면, 아이템의 콘텐츠에 따라 정해집니다. 

```swift
basis(_ : CGFloat?)
basis(_ : FPercent)
```

**justifyContent**는 flex conainer에 적용되는 것으로, `start`, `end`, `center`, `spaceBetween`, `spaceAround`, `spaceEvenly` 의 값으로 아이템의 정렬을 설정합니다. 디폴트값은 `start`입니다. 아이템들이 어떻게 위치하는 지에 대해선 [이 링크](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-10-13%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%205.32.00.png)를 확인하면 됩니다:)

```swift
rootFlexContainer.flex.justifyContent(.spaceBetween).define { flex in
    flex.addItem(view1).height(100)
    flex.addItem(view2).height(100)
    flex.addItem(view3).height(100)
}
```







<div align="center"><img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-10-13%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%205.36.24.png" width="400"></div>

.

.

.

.

.

또 다른 여러가지 메소드들이 있는데 사용해보면서 하나씩 알아보도록 하겠습니다. 추가로 알면 편한 것들은 `margin`,  `padding`을 추가하거나 `backgroundColor`를 설정할 수 있습니다.



### addItem()

메소드들에 대해서 알아봤는데 아이템을 어떻게 추가할까요? (위에서 사용하긴 했지만..)

**addItem(:UIView)**을 이용하여 원하는 View를 추가할 수 있습니다. 하지만 항상 rootContainer 안에 새로운 뷰를 추가해야합니다.

```swift
rootFlexContainer.flex.addItem(view1).height(100)
rootFlexContainer.flex.addItem(view2).height(100)
rootFlexContainer.flex.addItem(view3).height(100)
```

**addItem()**을 이용하여 기본 UIView를 추가할 수 있습니다. 그냥 간단한 뷰를 만들 때 유용할 것 같습니다. (구분선)

```swift
rootFlexContainer.flex.addItem().height(100).backgroundColor(.gray)
rootFlexContainer.flex.addItem().height(100).backgroundColor(.green)
rootFlexContainer.flex.addItem().height(100).backgroundColor(.black)
```

Flex 아이템의 UIView 컴포넌트에 접근하기 위해서는 두가지 방법이 있습니다. `flex.view`로 접근하는 방식과 선언 후 Flex 아이템에 추가하는 방식입니다.

```swift
view.flex.direction(.row).padding(20).alignItems(.center).define { (flex) in
    flex.addItem().width(50).height(50).define { (flex) in
        flex.view?.alpha = 0.8
    }
}

view.flex.direction(.row).padding(20).alignItems(.center).define { (flex) in
    let container = UIView()
    container.alpha = 0.8
    
    flex.addItem(container).width(50).height(50)
}
```

### layout()

container에 속한 아이템들의 레이아웃을 잡아주는 메소드입니다. 항상 불러주어야하는 메소드로,  `fitContainer`, `adjustWidth`, `adjustHeight` 를 값으로 가지고 있습니다.

`fitContainer`는 디퐅트값으로 하위 아이템들이 container 크기 안에서 레이아웃이 잡힙니다. `adjustWidth`는 하위 아이템들이 container의 너비에 맞게 레이아웃이 잡힙니다. container의 높이는 하위 아이템의 크기에 맞게 조절됩니다. `adjustHeight`는 하위 아이템들이 container의 높이에 맞게 레이아웃이 잡히고너비는 아이템들의 크기에 맞게 조절됩니다. 

```swift
rootFlexContainer.pin.all(pin.safeArea)
rootFlexContainer.flex.layout(mode: .adjustHeight)
```

| fitContainer                                                 | adjustHeight                                                 |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| <img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/Simulator%20Screen%20Shot%20-%20iPhone%2014%20Pro%20-%202022-10-13%20at%2018.21.13.png" width="400"> | <img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/Simulator%20Screen%20Shot%20-%20iPhone%2014%20Pro%20-%202022-10-13%20at%2018.21.55.png" width="400"> |



### ⚠️ 주의할 사항 

SPM으로 FlexLayout 설치하고 빌드할 때, TARGET -> Build Settings -> Apple Clang-Preprocessing -> Preprocessor Macros에서 `FLEXLAYOUT_SWIFT_PACKAGE=1` 추가 (리드미에 적혀있습니다..😓)

![image-20221013174908276](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/image-20221013174908276.png)



- https://github.com/layoutBox/PinLayout
- https://devscope.io/code/layoutBox/FlexLayout/issues/200
- https://github.com/layoutBox/FlexLayout#performance
- https://zeddios.tistory.com/1251