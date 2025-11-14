### Today I Leanred 

----

2022.10.19 (수)



### **UIBezierPath**

> A path that consists of straight and curved line segments that you can render in your custom views.

view에서 렌더링할 수 있는 직선과 곡선으로 구성된 경로입니다. 이 클래스는 view의 형태를 직접 그려주기 위해서 사용합니다. 곡선, 아치형, 직선형 등으로 모양을 정의해준 후, 현재 그려지는 context에 렌더링하기 위해 추가적인 메소드를 사용할 수 있습니다. 

UIBezierPath 객체는 렌더링될 때 경로를 설명하는 속성들과 지오메트리의 경로들을 합칩니다. 즉, 지오메트리 및 속성을 개별적으로 설정하고 서로 독립적으로 변경할 수 있습니다. 객체를 원하는 방식으로 구성한 후에는 현재 context에서 객체를 그리도록 지정할 수 있습니다. 생성, 구성 및 렌더링 프로세스는 모두 별개의 단계로 Bezier 경로 객체를 코드에서 쉽게 재사용할 수 있습니다. 동일한 객체를 사용하여 동일한 도형을 여러번 렌더링할 수도 있으며, 연속 그리기 호출간에 렌더링옵션을 변경할 수 있습니다. 

경로의 현재 지점을 조작하여 경로의 지오메트리를 설정합니다. 빈 경로 객체를 새로 만들면 현재 점이 점의되지 않으므로 명시적으로 설정해야합니다. 세그먼트를 그리지 않고 현재 점을 이동하려면 move(to:) 함수를 사용합니다. 다른 모든 함수는 경로에 선 또는 커브 세그먼트를 추가합니다. 새로운 세크먼트를 추가하는 방법은 항상 현재 지점에서 시작하여 지정한 새 지점에서 끝나는 것으로 가정합니다. 세그먼트를 추가하면 세그먼트의 끝점이 자동으로 현재 포인트가 됩니다. 

하나의 Bezier 경로 객체는 열려있거나 닫힌 하위 경로가 얼마든지 포함될 수 있습니다. 각 하위 경로는 연결된 일련의 경로 세그먼트를 나타냅니다. close() 함수를 호출하면 현재 포인트에서 하위 경로의 첫 번째 포인트까지 직선 세그먼트가 추가되어 하위 경로가 닫힙니다. move(to:) 함수를 호출하면 현재 하위 경로가 종료되고(닫지 않고) 다음 하위 경로의 시작점이 설정됩니다. Bezier 경로 객체의 하위 경로는 동일한 도면 특성을 공유하므로 그룹으로 조작해야합니다. 서로 다른 특성을 가진 하위 경로를 그리려면 각 하위 경로를 자체 UIBezierPath객체에 넣어야합니다.

Bezier 경로의 지오메트리 및 속성을 구성한 후에는 stoke() 와 fill() 함수를 사용하여 현재 그래픽 context에서 경로를 그립니다. stoke() 함수는 현재 stroke 색상과 Bezier경로 객체의 속성을 사용하여 경로의 윤곽선을 그립니다. 마찬가지로 fill() 함수는 현재 색을 사용하여 경로로 둘러싸인 영역을 채웁니다. 

Bezier 경로 객체를 사용하여 도형을 그릴뿐만 아니라 새 자르기 영역을 정의할 수 있습니다. addClip() 함수는 경로 객체로 표현된 도형을 그래픽 컨텍스트의 현재 clipping 영역과 교차합니다. 새로운 교차로 영역 내에 있는 콘텐츠만 그래픽에 렌더링됩니다. 

### 사용해보기

```swift
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let bview: BezierView = .init(frame: view.frame)
        bview.backgroundColor = .clear
        view.addSubview(bview)
    }
}

class BezierView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {}
}
```

BezierPath를 초기화하는 법은 여러가지가 있습니다. 

**사각형** 

```swift
override func draw(_ rect: CGRect) {
    let path = UIBezierPath(rect: CGRect(x: bounds.midX-50, y:bounds.midY-50, width: 100, height: 100))
    UIColor.systemRed.setFill()
    UIColor.systemYellow.setStroke()
    path.lineWidth = 10
    path.stroke()
    path.fill()
}
```

<p align="center"><img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-10-19%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%206.32.30.png" width="300"></p>

**타원형**

```swift
override func draw(_ rect: CGRect) {
    let path = UIBezierPath(ovalIn: CGRect(x: bounds.midX-100, y:bounds.midY-100, width: 200, height: 300))
    UIColor.blue.setFill()
    UIColor.red.setStroke()
    path.lineWidth = 10
    path.stroke()
    path.fill()
}
```

<p align="center"><img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-10-19%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%206.33.57.png" width="300"></p>

**둥근 사각형**

```swift
override func draw(_ rect: CGRect) {
    let path = UIBezierPath(roundedRect: CGRect(x: bounds.midX-100, y:bounds.midY-100, width: 100, height: 200), cornerRadius: 20)
    UIColor.blue.setFill()
    UIColor.red.setStroke()
    path.lineWidth = 10
    path.stroke()
    path.fill()
}
```

<p align="center"><img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-10-19%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%206.35.44.png" width="300"></p>

**아치형** 

```swift
override func draw(_ rect: CGRect) {
    let path = UIBezierPath(roundedRect:  CGRect(x: bounds.midX-50, y:bounds.midY-50, width: 100, height: 100), byRoundingCorners: [.topLeft,.topRight], cornerRadii: .init(width: 50, height: 50))
    UIColor.blue.setFill()
    UIColor.red.setStroke()
    path.lineWidth = 10
    path.stroke()
    path.fill()
}
```

<p align="center"><img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/image-20221019183832100.png" width="300"></p>

**곡선**

```swift
override func draw(_ rect: CGRect) {
    let path = UIBezierPath(arcCenter: center, radius: 50, startAngle: 0, endAngle: .pi, clockwise: false)
    UIColor.blue.setFill()
    UIColor.red.setStroke()
    path.lineWidth = 10
    path.stroke()
    path.fill()
}
```

<p align="center"><img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-10-19%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%206.40.29.png" width="300"></p>

**Initializer 정리** 

- [`init(rect: CGRect)`](https://developer.apple.com/documentation/uikit/uibezierpath/1624359-init)
- [`init(ovalIn: CGRect)`](https://developer.apple.com/documentation/uikit/uibezierpath/1624379-init)
- [`init(roundedRect: CGRect, cornerRadius: CGFloat)`](https://developer.apple.com/documentation/uikit/uibezierpath/1624356-init)
- [`init(roundedRect: CGRect, byRoundingCorners: UIRectCorner, cornerRadii: CGSize)`](https://developer.apple.com/documentation/uikit/uibezierpath/1624368-init)
- [`init(arcCenter: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, clockwise: Bool)`](https://developer.apple.com/documentation/uikit/uibezierpath/1624358-init)
  - clockwise: 그려질 방향 선택 (false: 위, true: 아래)

### 경로 만들기

위와 같이 Initializer을 통해 모양을 만들 수 있지만 직접 원하는 모양을 그릴 수 있습니다. 

```swift
override func draw(_ rect: CGRect) {
    let path = UIBezierPath()
    path.move(to: center)
    path.addCurve(to: .init(x: center.x + 100, y: center.y - 100),
                  controlPoint1: .init(x: center.x + 1, y: center.y - 97),
                  controlPoint2: .init(x: center.x + 82, y: center.y - 7))
    path.addLine(to: .init(x: center.x + 100, y: center.y))
    path.addLine(to: .init(x: center.x, y: center.y))
    UIColor.blue.setFill()
    UIColor.red.setStroke()
    path.lineWidth = 10
    path.stroke()
    path.fill()
    path.close() // 모양이 완성되면 끊기 
}
```

<p align="center"><img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-10-19%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%208.41.28.png" width="300"></p>

- [`func move(to: CGPoint)`](https://developer.apple.com/documentation/uikit/uibezierpath/1624343-move)
  - 시작점을 정할 수 있습니다. 
  - 현재 point를 지정해줍니다. 
- [`func addLine(to: CGPoint)`](https://developer.apple.com/documentation/uikit/uibezierpath/1624354-addline)
- [`func addArc(withCenter: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, clockwise: Bool)`](https://developer.apple.com/documentation/uikit/uibezierpath/1624367-addarc)
- [`func addCurve(to: CGPoint, controlPoint1: CGPoint, controlPoint2: CGPoint)`](https://developer.apple.com/documentation/uikit/uibezierpath/1624357-addcurve)
  - 3차 베지어 곡선 그리기
- [`func addQuadCurve(to: CGPoint, controlPoint: CGPoint)`](https://developer.apple.com/documentation/uikit/uibezierpath/1624351-addquadcurve)
  - 2차 베지어 곡선 그리기 

> 곡선을 그릴 때 참고할 만한 사이트 
> https://cubic-bezier.com/#.17,.67,.83,.67

### 여러 프로퍼티들 

- `path.stroke()` 를 이용해서 가장자리(테두리)를 그릴 수 있습니다. 
- `path.lineWidth = 10`을 이용해서 선의 두께를 정할 수 있습니다.
- `setStroke()`를 이용해서 원하는 선 색깔을 정할 수 있습니다.
- `path.lineCapStyle = .round`를 이용하면 선의 끝점이 둥글어 집니다. (시작과 끝에만 적용)
- `path.lineJoinStyle = .round`를 이용하면 모든 모서리가 둥글어 집니다. 
- `path.fill()`을 통해 색을 채워줍니다.

