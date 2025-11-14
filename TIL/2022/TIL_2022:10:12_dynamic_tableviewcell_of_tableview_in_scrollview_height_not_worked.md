### Today I Learned

----

2022.10.12 (수)

<br />

- [이슈 46번](https://github.com/wody-d/woody-iOS-tip/issues/46)



## 🚨 문제상황 

개발을 하다가 이상한 UI 버그를 만났습니다. <br/>scrollView 안에 tableView가 위치해있는 UI입니다. 스크롤은 scrollView만 되고 tableView의 `isScrollEnabled` 프로퍼티는 false로 설정했습니다. 이 때 tableView의 콘텐츠에 따라 스크롤뷰의 contentSize가 변해야하는데 tableView의 datasource에 데이터가 제대로 configure됐음에도 불구하고 contentSize가 늘어나지 않고 tableView의 높이가 제멋대로 설정되는 이슈를 만났습니다. 

> 상황 설명이 이해되도록 스토리보드의 hierachy를 그려보았습니다.<br />스크롤뷰 안에 StackView를 삽입했고 상하좌우 constriant를 잡아주었고 tableView의 height constraint를 잡은 상황입니다. 

<div align="center"><img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-10-13%20%E1%84%8B%E1%85%A9%E1%84%8C%E1%85%A5%E1%86%AB%201.36.58.png" width="600" ></div>

위와 같은 구조에서는 tableView가 리로드 이벤트 호출 시 레이아웃 업데이트를 처리하면 됩니다. 

```swift
weak var tableViewheightConstraint: NSLayoutConstraint!

self.tableView.reloadData()
self.tableViewheightConstraint.constant = self.commentHight * CGFloat(commentCount)
self.view.layoutIfNeeded()
```

혹은,

```swift
override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
  	self.tableViewheightConstraint.constant = self.tableView.contentSize.height
		self.view.layoutIfNeeded()
}
```

에서 처리해줍니다. [예전에도 한번 겪었던 트러블 슈팅](https://github.com/wody-d/woody-iOS-tip/issues/1)이었습니다. 

```swift
// 만약 collectionView라면, collectionViewLayout의 collectionViewContentSize 프로퍼티의 height 할당
collectionView.reloadData()
collectionViewHeightConstraint.constant = collectionView.collectionViewLayout.collectionViewContentSize.height
view.layoutIfNeeded()
```



예전에 만난 이슈는 Cell의 높이가 정적이었지만 이번엔 동적인 경우입니다. 아래와 같이 Label과 버튼으로 이루어져있는 Cell이고 Label의 콘텐츠의 길이가 정해져 있지 않아 무한으로 늘어날수 있습니다. (`numberOfLines = 0`)

<div align="center"> <img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-10-13%20%E1%84%8B%E1%85%A9%E1%84%8C%E1%85%A5%E1%86%AB%202.25.27.png"></div>

## 원인

테이블뷰 reload 이벤트 호출 시 셀은 자신의 높이를 파악합니다. 하지만 동적으로 높이가 정해지는 셀이라면 연산이 될 때까지 셀의 높이를 알 수 없습니다. 따라서 매번 `contentSize`의 높이가 달라지고 처음에 한번에 정할 수 없습니다. 

## 해결 방법

해결하는 방법으로는 여러가지가 있습니다. 먼저, 테이블뷰 셀의 높이를 지정해주면 됩니다. Cell의 높이 * Cell의 개수는 결국 contentSize의 높이가 됩니다. 하지만 이것은 동적인 높이의 셀을 만들 때는 사용하지 못합니다. 

```swift
let commentHight: CGFloat = 88.0
let commentCount = commentModels.count
self.tableViewheightConstraint.constant = self.commentHight * CGFloat(commentCount)
```

두 번째로는, Cell의 높이를 연산해줍니다. 이미 데이터를 모두 가져왔기 때문에 해당 데이터가 UI에 그려진다 가정하고 높이를 계산하는 방법입니다. 위에서 나온 이슈 상황에서는 `UILabel`의 높이를 text Size에 맞추어야 합니다. 이 때 아래처럼 `intrinsicContentSize`를 이용해서 실제 label의 width가 뷰의 width보다 몇 배 긴가에 따라 높이를 곱해주는 방법을 이용할 수 있습니다. . 

```swift
let label = UILabel()
label.numberOfLines = 0
label.lineBreakMode = .byCharWrapping
label.text = "iOS 개발자 이재용! 삼성 회장님과 이름이 같다고 안드로이드를 개발하지 않아요~ 오해말아요."

let newSize = label.intrinsicContentSize
label.frame.size = newSize

if label.frame.width > label.frame.width {
    let shareOfDivision = ceil((testLabel.frame.width / view.frame.width))
    let newHeight = label.frame.height * shareOfDivision
    label.frame.size = CGSize(width: view.frame.width, height: newHeight)
}

print(label.frame.size.height)
```

각 Cell마다 연산하고 최종 나온 높이를 할당하면 됩니다. 

```swift
self.tableViewheightConstraint.constant = totalHeight
```

세 번째론, UI 구조를 완전히 바꾸는 방법이 있습니다. 테이블뷰가 스크롤뷰안에 있는 구조에서 only 테이블뷰만 있는 구조로 바꾸면 해당 이슈는 사라집니다. 하지만, 이 방법은 추천하지 않습니다. 테이블 뷰가 아닌 컴포넌트들도 모두 리로드가 되는데 이 상황은 좋지 않습니다. 저도 예전에 사용해봤지만 리로드 이벤트는 모든 아이템을 리로드되고 보여지고 있는 아이템 셀들이 다시 그려지기 때문에 깜박일 수 있습니다. (애니메이션도 이쁘게 되지 않습니다.) 사실 디퍼블 데이터 소스를 이용하는 것도 하나의 방법입니다만, 디퍼블 데이터소스는 아직까지 많이 익숙치 못해 개발을 빠르게 해야했던 오늘 상황과는 맞지 않았습니다. 디퍼블 데이터소스는 아직 새로 생기거나 수정된 아이템을 재 apply하고 dataSource에서 itemIdentifier를 꺼내는 과정이 익숙하지 않았습니다. ~~더욱 훈련해야겠다~~

너무 오랜만에 테이블뷰 In 스크롤뷰 구조를 그리다보니 생각치못한 트러블을 만나서 세시간정도 고생했습니다. 마음도 급했어서 해결과정이 빠르게 생각이 나지 않았습니다. 그래도 이슈을 해결했을 때는 기분이 뿌듯합니다. 

> 이쁘진 않지만 이슈 해결한 UI 

<div align="center"><img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/2022-10-13%2003.42.04.gif" width="300"></div>