# UIKit과 SwiftUI 사용



## UIHostingController

UIHostingController는 SwiftUI 뷰 계층 구조를 포함하는 UIViewController입니다. UIViewController이므로 프로퍼티 view를 가지고 있고 SwiftUI 콘텐츠는 해당 view 내부에 들어갑니다. 

<img width="642" alt="스크린샷 2022-10-04 오후 8 32 04" src="https://user-images.githubusercontent.com/56102421/193858041-c991c3a9-c305-45a1-8928-c11d6dd0284e.png">

<br />

아래 예시는 UIHostingController를 생성하여 사용하는 방법입니다.

```swift
// Presenting a UIHostingController

let heartRateView = HeartRateView() // a SwiftUI view
let hostingController = UIHostingController(rootView: heartRateView)

// Present the hosting controller modally
self.present(hostingController, animated: true)
```

`HeartRateView`라는 SwiftUI View를 만들고 `UIHostingController`의 루트뷰를 `HeartRateView`로 초기화합니다. <br/>

다른 방법도 있습니다.

```swift
// Embedding a UIHostingController

let heartRateView = HeartRateView() // a SwiftUI view
let hostingController = UIHostingController(rootView: heartRateView)

// Add the hosting controller as a child view controller
self.addChild(hostingController)
self.view.addSubview(hostingController.view)
hostingController.didMove(toParent: self)

// Now position & size the hosting controller’s view as desired…
```

1번 예시와 동일하게 초기화하지만 `hostingController`를 하위 view controller로 추가합니다. 그러면 hosingController view의 위치와 크기를 조절할 수 있습니다. (이 예시에서는 오토레이아웃을 잡는 코드는 생략했습니다.)

<br />

<img width="642" alt="스크린샷 2022-10-04 오후 8 41 58" src="https://user-images.githubusercontent.com/56102421/193858107-bf721e15-5a6c-45b4-ba3b-64ea6e7232b6.png">

iOS 16부터 UIHostingController에서 view controller가 권장하는 크기와 뷰 고유의 크기에 대해 자동 업데이트 기능을 사용할 수 있습니다. `preferredContentSize`와 `intrinsicContentSize` 가 있습니다. 



```swift
// Presenting UIHostingController as a popover

let heartRateView = HeartRateView() // a SwiftUI view
let hostingController = UIHostingController(rootView: heartRateView)

// Enable automatic preferredContentSize updates on the hosting controller
hostingController.sizingOptions = .preferredContentSize

hostingController.modalPresentationStyle = .popover
self.present(hostingController, animated: true)
```

`preferredContentSize`로 `sizingOptions`프로퍼티를 설정하고 `popover`로 모달 스타일을 설정하면  팝오버 뷰의 크기는 항상 SwiftUI 콘텐츠에 맞게 설정됩니다. 

## Bridging data

UIkit 내부의 SwiftUI는 데이터를 어떻게 업데이트할까요? 데이터가 바뀔 때마다 SwiftUI가 업데이트됩니다. 

바로 예제를 보겠습니다. 

<img width="642" alt="스크린샷 2022-10-04 오후 9 04 53" src="https://user-images.githubusercontent.com/56102421/193858121-007cb806-2ba1-4b41-96a8-af0c59537e2a.png">

데이터 모델 객체가 있고 여러 view controller들이 있습니다. 이 중 하나의 UIViewController에 SwiftUI 뷰를 포함한 UIHostingController를 넣은 상황입니다. 먼저 UIkit과 SwiftUI의 데이터를 연결하는 방법부터 보겠습니다. 

<br />

SwiftUI는 데이터 흐름을 관리하는 다양한 옵션들을 제공합니다. 

<img width="642" alt="스크린샷 2022-10-04 오후 9 11 43" src="https://user-images.githubusercontent.com/56102421/193858140-244b237f-f5fb-4ad1-b4d4-c6c6f395683d.png">

SwiftUI View에서 만들고 소유하는 데이터를 저장할 떈 `@State`와 `@StateObject` 프로퍼티 래퍼가 제공됩니다. 이 2가지 프로퍼티 래퍼와 관련해서는 WWDC20의 `Data Essentials in SwiftUI` 영상을 참고하시면 더 자세히 알 수 있습니다. 이번 영상에서는 SwiftUI View 외부에서 만들고 소유되는 데이터입니다. 

<br />

<img width="642" alt="스크린샷 2022-10-04 오후 9 23 47" src="https://user-images.githubusercontent.com/56102421/193858325-5bc4ae90-ae20-4d4a-a6a9-565f84a9022b.png">

외부의 데이터를 다루는 한 가지 방법은 뷰를 초기화할 때 직접 값을 전달하는 것입니다. SwiftUI가 소유하지 않은 원시 데이터이므로 데이터가 바뀌면 `UIHostingController`를 수동으로 업데이트해야 합니다. 

한가지 예시를 들어보겠습니다.

```swift
// Passing data to SwiftUI with manual UIHostingController updates

struct HeartRateView: View {
    var beatsPerMinute: Int

    var body: some View {
        Text("\(beatsPerMinute) BPM")
    }
}

class HeartRateViewController: UIViewController {
    let hostingController: UIHostingController<HeartRateView>
    var beatsPerMinute: Int {
        didSet { update() }
    }

    func update() {
        hostingController.rootView = HeartRateView(beatsPerMinute: beatsPerMinute)
    }
}
```

`HeartRateView`라는 SwiftUI View가 있습니다. 이 뷰는 `beatsPerMinute` 프로퍼티 (분당 심박수)를 저장하고 텍스트로 표시합니다. 그리고 이 `HeartRateView`를 `UIHostingViewController`에 감싸  `HeartRateViewController` 안에 넣어줍니다. HearRateView를 HeartRateViewController가 들고 있긴 하지만, 값 타입이므로 저장하더라도 복사본이 생성되고 UI를 업데이트할 수 없습니다. 이 상황에서 `HeartRateViewController` 가 HearRateView에 들어가는 데이터 `beatsPerMinute`를 소유합니다. 만일 데이터가 변하면 update메소드를 호출하여 새로운 `beatsPerMinute` 값으로 새로운 `HeartRateView`를 만든 다음 해당 뷰를 hostingController의 루트뷰로 지정합니다. 

이 방법은 데이터가 바뀔 때마다 호스팅 컨트롤러의 루트 뷰를 수동으로 업데이트해야 합니다. 

다른 방법으론 ObservableObject 프로토콜을 준수하는 객체를 `@ObservedObject`와`@EnvironmentObject` 프로퍼티 래퍼로 참조한다면 뷰 업데이트를 자동으롤 할 수 있습니다. 

![image-20221004212441850](/Users/woody/Library/Application Support/typora-user-images/image-20221004212441850.png)

이번 영상에서는 `@ObservedObject`에 대해 알아볼 예정이고 `@EnvironmentObject`에 대해 알고 싶다면  WWDC20의 `Data Essentials in SwiftUI` 영상을 추천해줍니다. 

<br />

방법을 바로 알아보겠습니다. 

<img width="642" alt="스크린샷 2022-10-04 오후 9 28 12" src="https://user-images.githubusercontent.com/56102421/193858355-3c5f39ee-1c2d-4623-95ef-67d6af98d6af.png">

사용하는 데이터 모델을 `ObservableObject` 프로토콜을 준수하게 합니다. 그리고 모델을 SwiftUI 뷰에서 `@ObservedObject` 프로퍼티 래퍼로 참조합니다. SwiftUI에 `ObservableObject`를 연결하면 모델이 변경될 때 뷰를 업데이트할 수 있습니다. 

<br />

바로 예시로 알아보겠습니다.

```swift
// Passing an ObservableObject to automatically update SwiftUI views

class HeartData: ObservableObject {
    @Published var beatsPerMinute: Int

    init(beatsPerMinute: Int) {
       self.beatsPerMinute = beatsPerMinute
    }
}

struct HeartRateView: View {
    @ObservedObject var data: HeartData

    var body: some View {
        Text("\(data.beatsPerMinute) BPM")
    }
}
```

1. 데이터 모델에 ObservableObject 프로토콜을 준수합니다. 
2. 그리고 데이터에 `@Published` 프로퍼티 래퍼를 추가합니다. 이 프로퍼티 래퍼는 SwiftUI 뷰에 변경 사항을 업데이트하게 합니다. 
3. 마지막으로 SwiftUI 뷰에서 데이터에 `@ObservedObject` 프로퍼티 래퍼를 추가합니다. 

<br />

```swift
// Passing an ObservableObject to automatically update SwiftUI views

class HeartRateViewController: UIViewController {
    let data: HeartData
    let hostingController: UIHostingController<HeartRateView>  

    init(data: HeartData) {
        self.data = data
        let heartRateView = HeartRateView(data: data)
        self.hostingController = UIHostingController(rootView: heartRateView)
    }
}
```

view controller는 SwiftUI에 들어가는 HeartData를 저장합니다. 이 프로퍼티는 SwiftUI 뷰 내부에 있는 게 아니라 속성 래퍼를 사용할 필요가 없습니다. 

이제 HeartData 데이터가 변하면 어떻게 되는지 도식으로 보여드리겠습니다. 

<img width="642" alt="스크린샷 2022-10-04 오후 9 42 11" src="https://user-images.githubusercontent.com/56102421/193858694-f99be46c-c30e-4346-a45e-adca5ad55675.png">

<img width="642" alt="스크린샷 2022-10-04 오후 9 42 29" src="https://user-images.githubusercontent.com/56102421/193858866-cc91c565-4d29-4807-a4a0-de511b44107a.png">

78 BPM을 저장하는 HeartData 데이터가 있습니다. 이는 HeartRateViewController를 초기화할 때 78BPM, 해당 값으로 HeartRateView를 초기화하고 UIHostingController의 루트뷰로 초기화힙니다. HeartData가 94로 업데이트가 된다면 ObservableObject 프로토콜의 @Published 데이터가 변경되었기 때문에 HeartRateView가 자동으로 업데이트가 되어 새 값을 보여줍니다. (호스팅 컨트롤러를 수동으로 업데이트할 필요가 없다.)

## SwiftUI in cells

iOS 16부터 제공하는 `UIHostingConfiguration`은 UIKit, collectionView, tableView 에서 SwiftUI의 기능을 활용할 수 있도록 도와줍니다. Cell들을 SwiftUI로 쉽게 사용할 수 있도록 해줍니다. <br />

기존 UIkit의 Cell configurations에 대해 먼저 알아보면, cell appearnce을 가볍게 구성할 수 있는 구조체로, composable(조립 가능)하며 tableView, collectionView 두곳 모두 사용 가능합니다. (Modern cell configuration WWDC20 참고)

<br />

그럼 contentConfiguration을 알아보겠습니다. 

```swift
// Building a custom cell using SwiftUI with UIHostingConfiguration

cell.contentConfiguration = UIHostingConfiguration {
    HeartRateTitleView()
}

struct HeartRateTitleView: View {
    var body: some View {
        HStack {
            Label("Heart Rate", systemImage: "heart.fill")
                .foregroundStyle(.pink)
                .font(.system(.subheadline, weight: .bold))
            Spacer()
            Text(Date(), style: .time)
                .foregroundStyle(.secondary)
                .font(.footnote)
        }
    }
}
```

`UIHostingConfiguration`은 SwiftUI 빌더에 의해 초기화되는 `contentConfiguration`입니다. 즉 SwiftUI 코드를 내부에 바로 생성할 수 있습니다.

Cell의 contentConfiguration 프로퍼티로 설정된 SwiftUI 뷰는 기본적으로 자신이 들어 있는 context의 기본적인 스타일을 따라갑니다. SwiftUI Modifier(수정자)를 이용해서 context의 스타일을 수정할 수 있습니다. SwiftUI Cell로 만든다면 아래와 같은 결과가 나올 수 있습니다. (Chart 프레임워크를 사용)

<img src="https://user-images.githubusercontent.com/56102421/193858708-b37ed789-9290-4d9f-9879-cdd15c4b1459.png">

```swift
// Building a custom cell using SwiftUI with UIHostingConfiguration

cell.contentConfiguration = UIHostingConfiguration {
    VStack(alignment: .leading) {
        HeartRateTitleView()
        Spacer()
        HStack(alignment: .bottom) {
            HeartRateBPMView()
            Spacer()
            Chart(heartRateSamples) { sample in
                LineMark(x: .value("Time", sample.time),
                         y: .value("BPM", sample.beatsPerMinute))
                   .symbol(Circle().strokeBorder(lineWidth: 2))
                   .foregroundStyle(.pink)
            }
        }
    }
}
```



<br />

UIHostingConfiguration이 지원하는 4가지 특별한 기능이 있습니다.

1. **마진** 

- 루트 SwiftUI 뷰는 UIKit의 Cell Layout 마진을 기준을 따릅니다. 
- 마진을 더 주거나 Cell의 테두리까지 확장하게 할 수 있습니다. 

```swift
cell.contentConfiguration = UIHostingConfiguration {
    HeartRateBPMView()
}
.margins(.horizontal, 16) // ✅
```

2. **배경색**

- Cell의 배경색도 바꿀 수 있습니다. 

```swift
cell.contentConfiguration = UIHostingConfiguration {
   HeartTitleView()
} 
.background(.pink) // ✅
```

UIHostingConfiguration의 배경과 SwiftUI 뷰(콘텐츠) 사이에는 중요한 차이가 있습니다. 

| -                   | Background                   | Content                                   |
| ------------------- | ---------------------------- | ----------------------------------------- |
| Position in Cell    | Behind content & accessories | On Top of background, next to accessories |
| Margins             | X                            | O (default)                               |
| Affects cell sizing | X                            | O                                         |

배경은 Cell과 악세서리의 뒤쪽에 위치합니다. Cell의 콘텐츠 뷰 아래에 깔립니다. 또 콘텐츠는 일반적으로 셀의 테두리(inset)부터 삽입되는데 배경은 edge to edge 까지 쭉 펼쳐져 있습니다. 마지막으로 크기를 스스로 조절하는 Cell은 콘텐츠만 크기에 영향을 미칩니다.

3. **List separators 자동 정렬** 

<img width="642" alt="%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA_2022-09-21_%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE_5 53 20" src="https://user-images.githubusercontent.com/56102421/193858987-8f6f54ee-ea09-4ec1-86d7-ab29f5445a63.png">

CollectionView List나 TableView List에서 separator는 자동으로 정렬됩니다. 예시에서 separator는 왼쪽 시작 지점이 Cell의 텍스트와 정렬되기 때문에 이미지를 지나고부터 시작됩니다. 만일 SwiftUI 뷰에 맞춰 separator를 정렬해야 한다면, `alignmentGuide` 수정자를 사용합니다. 

4. 행에 대한 스와이프 동작

<img width="642" alt="%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA_2022-09-21_%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE_5 53 51" src="https://user-images.githubusercontent.com/56102421/193859008-759578c2-9b3b-4467-81cd-397951f2f862.png">

```swift
cell.contentConfiguration = UIHostingConfiguration {
    MedicalConditionView()
        .swipeActions(edge: .trailing) { … }
}
```

`swipeActions` 수정자 안에 버튼을 만들면 셀을 스와이프하여 사용자 지정 동작을 표시하고 수행할 수 있습니다. 버튼의 동작을 수행할 떄는 `indexPath`를 사용하지 않아야 합니다. Cell이 visible한 상태에서 바뀌게 된다면 잘못된 Cell이 동작할 수 있습니다. 

<br />

`UIHostingConfiguration`을 Cell에서 사용할 때 tap, isHighlighed, isSelected와 같은 Cell 상호 작용은 여전히 CollectionView와 TableView에서 처리됩니다. 

UIKit의 Cell 상태와 상관없이 SwiftUI 뷰를 따로 바꾸고 싶다면, Cell의 `configurationUpdateHandler` 안에 `UIHostingConfiguration`을 만들고 재적용합니다. `configurationUpdateHandler`는 셀의 상태가 변할 때마다 다시 실행되고 새로운 상태에 대한 `UIHostingConfiguration`을 만들어 셀에 적용합니다.



## Data flow for cells

이제 UIHostingConfiguration을 사용하여 CollectionView나 TableView의 Cell을 구성했을 때 데이터 흐름에 대해서 알아보겠습니다. 바로 예제를 보겠습니다. SwiftUI 셀로 채워진 UIKit의 CollectionView가 있는 앱 화면이 있습니다.

<br />

<img width="642" alt="%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA_2022-09-21_%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE_5 59 01" src="https://user-images.githubusercontent.com/56102421/193859018-dbc96ba2-7f09-4f3a-b629-8c1697e94a2e.png">

앱에는 MedicalCondition 객체의 Collection이 있고 CollectionView와 CollectionView에 연결된 디퍼블 데이터 소스가 있습니다. 다음 디버플 데이터 소스에 더해질 스냅샷도 필요합니다. 이 스탭샷은 MedicalCondition 모델 각 객체마다 구별해주는 식별자를 포함합니다. 

<br />

<img width="642" alt="%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA_2022-09-21_%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE_6 03 24" src="https://user-images.githubusercontent.com/56102421/193859026-706af182-5565-4aec-9ed1-159cd40417f1.png">

스냅샷은 MedicalCondition 객체마다의 고유 식별자를 가지고 있기 때문에 디퍼블 데이터 소스는 식별자를 정확하게 추적하고 나중에 새로운 스냅샷을 적용할 때 새로운것과 이전것에 대한 변경 사항을 올바르게 계산할 수 있습니다. CollectionView의 각 Cell은 UIHostingConfiguration의 SwiftUI 뷰를 사용해 MedicalCondition을 표시하도록 구성되었습니다. 

<br />

이제 데이터가 변했을 때 UI업데이트 처리에 대해 봅시다. 변경사항에는 2가지 유형이 있습니다.

<img width="642" alt="%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA_2022-09-21_%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE_6 07 29" src="https://user-images.githubusercontent.com/56102421/193859621-dc8f46a0-4090-47af-b411-21115a9d405c.png">

1. 첫 번째는 데이터 컬렉션 자체가 바뀌는 유형입니다. <br />

   새로운 항목 삽입, 정렬 뒤바뀜, 항목 삭제 등.. 이런 변경사항은 새 스냅샷을 적용해 처리합니다. 데이터 컬렉션 자체의 변화는 Cell 내부에는 영향을 미치지 않기 때문에 Cell을 UIKit이든 SwiftUI든 변경 사항 처리 방식은 동일합니다. 

<br />

<img width="642" alt="%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA_2022-09-21_%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE_6 09 33" src="https://user-images.githubusercontent.com/56102421/193859630-52601d9f-3914-4311-8def-27e573df71b9.png">

2. 두 번째는 개별 모델 객체의 프로퍼티가 바뀌는 유형입니다. <br />이런 변경 사항은 셀의 뷰를 업데이트해야 합니다. 디퍼블 데이터 소스는 스냅샷에 식별자만 포함해서 기존 항목의 프로퍼티가 언제 변경이 되는지 모르기 때문에 기존 UIKit으로 Cell을 만들던 대는 디퍼블 데이터 소스 원본에 스냅샷의 항목을 재구성하거나 다시 로딩하여 수동으로 변경 사항을 알렸습니다. 하지만 SwiftUI로 Cell을 만들면 ObservableObject 타입을 ObservedObject 프로퍼티에 저장하면서 Published 프로퍼티 래퍼로 선언된 프로퍼티가 변하면 자동으로 SwiftUI를 작동시켜 뷰를 새로 고침합니다. <br />
   즉, Cell 내부의 SwiftUI 뷰와 모델이 직접적으로 연결이 되어있습니다. 디퍼블 데이터 소스나 UICollectionView를 거치지 않습니다.

<br />

2번 유형과 같이 변경된다면 문제상황이 있습니다. 

Cell의 데이터가 바뀌면 Cell이 새로운 내용에 맞게 커지거나 작아지는 Self-resizing cell이었습니다. 하지만 SwiftUI Cell의 콘텐츠가 UIKit을 거치지 않고 바로 뷰가 업데이트가 된다면 CollectionView는 어떻게 Cell의 크기를 resizing할까요?

<img width="642" alt="%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA_2022-09-21_%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE_6 12 32" src="https://user-images.githubusercontent.com/56102421/193859636-e9cd426f-b1c4-40e4-8c20-7c9b6c39c305.png">

iOS 16부터 collection과 tableview의 Cell은 콘텐츠가 바뀌면 자동으로 리사이징을 합니다. (WWDC22 What's new in UIKIt 참고)



<br />

<img width="642" alt="%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA_2022-09-21_%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE_6 13 27" src="https://user-images.githubusercontent.com/56102421/193859821-954a4a27-d741-4fe2-893b-5c5c605a1b55.png">

또 하나의 데이터 흐름은 SwiftUI 뷰의 데이터를 앱의 다른 부분으로 다시 전송할 수 있다는 것입니다. ObservableObject 프로토콜이 가능하게 해줍니다. ObservableObject 타입의 Published 프로퍼티에 대해 양방향 바인딩할 수 있습니다. 즉, SwiftUI -> Model 과 Model -> SwiftUI 가 가능해집니다. 

<br />

하나의 예를 보겠습니다. `TextField("Condition", text: $condition.text)`와 같이 양방향 바인딩할 수 있습니다. 

```swift
// Creating a two-way binding to data in SwiftUI

class MedicalCondition: Identifiable, ObservableObject {
    let id: UUID
   
    @Published var text: String
}

struct MedicalConditionView: View {
    @ObservedObject var condition: MedicalCondition

    var body: some View {
        HStack {
						TextField("Condition", text: $condition.text)
            Spacer()
        }
    }
}
```

### 마무리 

UIKit 안에 SwiftUI를 사용하는 2가지 방법에 대해 알아보았습니다. 

<img width="642" alt="%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA_2022-09-21_%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE_6 16 31" src="https://user-images.githubusercontent.com/56102421/193859970-4ace2a12-cfac-456e-ad4c-629ac9105f25.png">

첫 번째는, UIHostingController를 이용하여 SwiftUI 콘텐츠를 UIKit 앱에 넣는 방법입니다. UIHostingController는 UIKit이 view controller를 쓰는 모든 위치에서 사용 가능하기 때문에 모든 위치에 SwiftUI 콘텐츠를 넣을 수 있습니다. 

두 번째는, UIHostingConfiguration을 Cell에 적용하면 UIViewController 없이 SwiftUI 뷰가 호스트됩니다. UIHostingConfiguration은 SwiftUI의 대부분의 기능을 지원합니다. 하지만 UIViewControllerRepresentable에 종속된 SwiftUI 뷰는 Cell 내에서 사용할 수 없습니다. 

`UIHostingController`와 `UIHostingConfiguration` 2가지 방법으로 UIKit 앱에 SwiftUI를 통합해볼 수 있습니다. 



<br />

<br />



- [Use SwiftUI with UIKit - WWDC22 - Videos - Apple Developer](https://developer.apple.com/wwdc22/10072)
