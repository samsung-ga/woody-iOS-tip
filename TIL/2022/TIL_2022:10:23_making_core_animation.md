### Today I Learned

----

2022.10.23 (일)

어제 애니메이션 구현을 완료하고 오늘은 반짝이는 별 애니메이션을 구현해보았습니다. 구현 방법에 대해서 [블로그](https://wodyios.tistory.com/73)에 작성해보았습니다. 하지만 구현하면서 생각한 것은 애니메이션을 만드는 것은 단순히 개발의 영역이 아니라는 것입니다. 속도와 지연 시간, 위치 등등 여러가지 요소들을 종합하여 만들어지는 하나의 애니메이션인데 혼자 이것저것 프로퍼티 값을 바꿔가면서 애니메이션을 만들고 있으니 이렇게 하는 게 맞는 건가 싶었습니다.. 그런데 하나하나 조절해가면서도 재밌고 설레면 이 일이 잘 맞는 거겠죠? 이제 인터렉션이 섞인 애니메이션을 구현해보는 일만 남았는데 이 단기간 프로젝트가 끝나더라도 한달에 하나씩은 저만의 애니메이션을 구현해봐야곘습니다! 

<img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/2022-10-23%2020.09.08.gif" width="300"> 



----

### 랜덤 함수

swift에서 제공하는 랜덤함수 종류는 **`arc4random()` / `arc4random_uniform(UInt32)` / `drand48()`**가 있습니다. 세가지 모두 성격이 다릅니다. 첫 번째는 **0 ~ 2^32-1** 사이의 랜덤 UInt32 타입의 값을 리턴합니다. 두 번째는 0 ~ 입력한 값-1 사이의 랜덤 UInt32 타입의 값을 리턴합니다. 마지막으로는 **0~1.0** 사이의 랜덤 Double 타입을 리턴합니다. 

그럼 이를 이용해서 프레임에서 랜덤한 위치를 표현하기 위해서는 아래의 코드를 작성할 수 있습니다. `arc4random()`를 이용해서 난수 하나를 뽑고 width와 height로 나눈 나머지로 구할 수 있습니다. 

```swift
func generateRandomPosition() -> CGPoint {
    let height = frame.height
    let width = frame.width

    return CGPoint(
        x: CGFloat(arc4random()).truncatingRemainder(dividingBy: width),
        y: CGFloat(arc4random()).truncatingRemainder(dividingBy: height)
    )
}
```

### Ref

- https://zeddios.tistory.com/214

