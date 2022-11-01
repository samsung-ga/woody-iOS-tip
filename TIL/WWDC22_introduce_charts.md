### WWDC22 SwiftUI Charts

----

2022.11.01 (화)

- Charts
- 여러가지 기능 제공

## Charts

여러가지 요소별 차트가 있습니다. 막대 차트를 예시로 학습해보겠습니다.

Bar Marks는 막대를 이용하여 데이터의 각 항목을 표현합니다. 이 때 value 팩토리 메소드를 사용하고 막대의 위치나 높이를 직접 설정하지 않아도 됩니다. Swift Chart 프레임워크는 막대만 자동으로 생성하지 않고, X축 막대에 대한 레이블과 막대의 길이가 의미하는 Y축의 이름도 보여줍니다. 

```swift
struct ContentView: View {
  var body: some View {
      Chart {
          BarMark(
              x: .value("Name", "Cachapa"),
              y: .value("Sales", 916)
          )
      }
  }
}
```

<img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-01%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%205.17.23.png" width="250">

여러개의 막대를 표현하기 위해서는 ForEach 구문을 이용할 수 있습니다. 

```swift

struct Pancakes: Identifiable {
    let name: String
    let sales: Int

    var id: String { name }
}

let sales: [Pancakes] = [
    .init(name: "Canhapa", sales: 916),
    .init(name: "Injera", sales: 856),
    .init(name: "Crepe", sales: 802)

]
struct ContentView: View {
    var body: some View {
        Chart {
            ForEach(sales) { element in
                BarMark(
                    x: .value("Name", element.name),
                    y: .value("Sales", element.sales)
                )
            }
        }
    }
}

```

<img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-01%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%205.22.55.png" width="250">



만일 ForEach가 차트에서 유일한 콘텐츠인 경우, 차트 이니셜라이저에 데이터를 직접 넣을 수 있습니다. 

```swift
struct ContentView: View {
    var body: some View {
        Chart(sales) { element in 
            BarMark(
                x: .value("Name", element.name),
                y: .value("Sales", element.sales)
            )
        }
    }
}
```

콘텐츠가 늘어남에 따라 막대의 레이블이 점점 가까워집니다. 이를 해결하기 위햇 X축과 Y축을 바꾸고 차트를 눕힐 수 있습니다. 

<img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-01%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%205.27.51.png" width="250" >

다크모드,  기기에 따른 폰트 크기, 차트 크기, 기기가로모드 등 여러 접근성을 지원합니다. 또한, VoiceOver 기능도 지원합니다. VoiceOver는 차트의 레이블과 막대의 위치를 말해줍니다. 

## 여러가지 기능 제공

3가지 Mark와 4가지 Marks Property를 이용하여 여러 종류의 그래프를 그릴 수 있습니다.

![스크린샷 2022-11-01 오후 6.33.21](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-01%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%206.33.21.png)

Bar + X Position + Y Position = 막대 차트

![스크린샷 2022-11-01 오후 6.33.24](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-01%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%206.33.24.png)

Point + X Position + Y Position = 점 차트

![스크린샷 2022-11-01 오후 6.33.39](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-01%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%206.33.39.png)

Line + X Position + Y Position = 꺽은 선 차트

![스크린샷 2022-11-01 오후 6.33.47](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-01%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%206.33.47.png)

Line + Point + X + Y + Foreground = 색깔로 구분되는 점과 꺽은 선을 합친 차트 

![스크린샷 2022-11-01 오후 6.34.44](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-01%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%206.34.44.png)

이외에도 Area, Rule, Rectangle Mark를 제공하고, Symbol Size와 Line Style Property도 존재합니다.

![스크린샷 2022-11-01 오후 6.35.00](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-01%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%206.35.00.png)

정말 다양한 차트를 그려볼 수 있습니다.

![스크린샷 2022-11-01 오후 6.35.48](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-01%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%206.35.48.png)

다양한 접근성을 제공하고 모든 애플 플랫폼에서 사용 가능합니다.