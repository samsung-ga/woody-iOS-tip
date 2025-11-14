### Today I Learned

----

2022.10.20 (목)

오늘부터 애니메이션 프로젝트를 시작합니다:) 🚀 이번 프로젝트에서 애니메이션을 조금 많이 쓰다보니 어쩌다 시작하게 됐지만 애니메이션을 뿌셔보겠습니다. 오늘은 방금 간단하게 Core Animation을 이용해서 로딩 애니메이션을 만들었습니다. Core Animation에는 정말 여러 종류의 애니메이션이 존재하는데 그 중에서 오늘 사용해본 것들은 아래와 같습니다. 또한 구현을 하다보니 CAReplicatorLayer에 대해서도 공부하게 되었는데 자세한 내용은 [블로그](https://wodyios.tistory.com/69)에 작성했습니다. 

계속 문서를 읽으면서 애니메이션을 하나씩 구현해보고 프로젝트로 정리하여 올리려고 합니다. 어디까지 만들어볼 수 있을까요!

<img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/circular%20loading.gif" width="300">

----

### CABasicAnimation

CAKeyframeAnimation과 마찬가지로 keypath를 이용해서 초기화합니다. 해당 내용은 [블로그](https://wodyios.tistory.com/25)에 작성했습니다.

### CAKeyframeAnimation

keypath를 이용해서 초기화합니다. `values`와 `keyTimes`프로퍼티를 사용해서 애니메이션을 지정합니다. 그럼 Core Animation은 지정한 값과 현재값 사이의 값들을 생성해서 애니메이션을 실행합니다. 

```swift
let colorKeyframeAnimation = CAKeyframeAnimation(keyPath: "backgroundColor")
colorKeyframeAnimation.values = [UIColor.red.cgColor,
                                 UIColor.green.cgColor,
                                 UIColor.blue.cgColor]
colorKeyframeAnimation.keyTimes = [0, 0.5, 1]
colorKeyframeAnimation.duration = 2
```

### CASprintAnimation

이것도 마찬가지로 keypath를 이용해서 초기화합니다. 이 객체이는 스프링을 조절할 수 있는 프로퍼티가 있습니다. `damping`, `initialVelocity`, `mass`, `settlingDuration`, `stiffness` 입니다. 프로퍼티에 관한 내용은 문서를 참고해주세요!

```swift
let animation = CASpringAnimation(keyPath: "path")
 animation.fromValue = createPath(point: fromPoint)
 animation.toValue = createPath(point: .init(x: view.bounds.maxX / 2, y: 100))
 animation.initialVelocity = 20
 animation.stiffness = 1000
 animation.duration = animation.settlingDuration
```





- 애플 문서 참고
