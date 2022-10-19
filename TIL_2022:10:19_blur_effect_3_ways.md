### Today I Learned

----

2022.10.19 (수)



원래 블로그에 작성하려한 정보이지만 티스토리가 현재 문제가 있기 떄문에 TIL에 작성했습니다. 

지금까지 UIKit의 BlurEffect를 이용해서 Blur 효과를 낼 수 있다고만 알고 있었습니다. (무지..) 그런데 줄곧 아이폰을 사용하면서 아이폰의 잠금화면은 어떻게 Blur처리를 한걸까라는 생각을 했습니다. 그리고 이제야 Core Image라는 개념에 다가갈 수 있었습니다. 

### UIBlurEffect를 이용하여 Image를 Blur처리하기

`UIBlurEffect`는 UIKit의 UI 요소입니다. 콘텐츠의 가장 위에 Blur 효과를 얹을 수 있습니다. 

```swift
let blurEffect = UIBlurEffect(style: .light)
let blurEffectView = UIVisualEffectView()
blurEffectView.frame = CGRect(x: 0, y: 0, width: imageView.frame.width, height: 400)
blurEffectView.center = imageView.center
self.imageView.addSubview(blurEffectView)
blurEffectView.effect = blurEffect
```

<img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/Simulator%20Screen%20Shot%20-%20iPhone%2014%20Pro%20-%202022-10-19%20at%2011.11.19.png" width="250"><img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/Simulator%20Screen%20Shot%20-%20iPhone%2014%20Pro%20-%202022-10-19%20at%2010.48.58.png" width="250">  

`UIVisualEffectView`를 사용하게 되면 두가지 Layer가 더 생기게 됩니다. `UIVisualEffectBackdropView`  와 `UIVisualEffectSubView`. 레이어가 더 생긴다는 의미는 이미지를 렌더링하는데 시간이 더 걸린다는 뜻입니다. 

<img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-10-19%20%E1%84%8B%E1%85%A9%E1%84%8C%E1%85%A5%E1%86%AB%2010.51.35.png" width="500">

UIBlurEffect를 이용하면 UIKit레벨에서 간단하게 blur효과를 처리할 수 있습니다. (Core Image 의 더 자세한 내용은 학습하지 않아도 됩니다.) 하지만, 단점이 많습니다. 커스텀이 불가능하기 때문에 built-in 시스템 필터들을 사용할 수 밖에 없습니다. 또한, 콘텐츠에 레이어가 추가되는 작업으로 콘텐츠가 직접 바뀌지 않습니다. (퍼포먼스가 떨어집니다.) 마지막으로 GPU 연산이 되지 않고 CPU 연산만 사용하는 UIKit 프레임워크 요소입니다. 

### Image에 CIFilter 사용하기

CIFilter는 Core Image 프레임워크의 이미지 프로세서입니다. Core Image 프레임워크는 다수의 built-in 필터들과 커스텀 필터를 만들 수 있는 기능을 제공합니다. 이는 OpenGL/OpenGL ES를 이용하여 GPU 기반의 렌더링을 통해 높은 퍼포먼스를 보여줍니다.

<img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-10-19%20%E1%84%8B%E1%85%A9%E1%84%8C%E1%85%A5%E1%86%AB%202.31.43.png">

```swift
    func blurredImage(radius: CGFloat) -> UIImage {
        guard let ciImage = CIImage(image: self) else { return self }
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(radius, forKey: kCIInputRadiusKey)
        guard let output = filter?.outputImage else { return self }
        return UIImage(ciImage: output)
    }
```

<img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/Simulator%20Screen%20Shot%20-%20iPhone%2014%20Pro%20-%202022-10-19%20at%2011.11.26.png" width="250">   <img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/Simulator%20Screen%20Shot%20-%20iPhone%2014%20Pro%20-%202022-10-19%20at%2012.17.15.png" width="250">

> radius를 10 / 60 처리한 이미지 결과입니다. 



처음에 필터링을 걸쳐 나온 이미지를 보여주었는데 밑에 공백이 생겼습니다. 그래서 이것저것 찾아보니까 같은 이슈를 겪은 분들을 찾을 수 있었습니다. 

- https://stackoverflow.com/questions/18315684/cifilter-is-not-working-correctly-when-app-is-in-background
- https://zeddios.tistory.com/m/1144

원인을 생각해본다면 "CIFilter를 거쳐 생성된 이미지의 크기가 원본 이미지보다 크다."였습니다. 사진의 모서리에 blur처리가 되었기 때문에 기존 이미지 가장자리와 달라진 것입니다. 

>  사실 이 원인은 아직 이해가 가지 않습니다. 그래서 이 글을 작성하고 Core Image프레임워크를 더 깊게 파보아야겠습니다:)

위 링크를 통해 CIAffineClamp 필터 -> CIGaussianBlur 필터 chaining을 통해 해결하는 방법이 적혀있습니다.

```swift
func blurredImage(with context: CIContext = .init(), radius: CGFloat) -> UIImage {
    guard let ciImage = CIImage(image: self),
          let clampFilter = CIFilter(name: "CIAffineClamp") else {
        return self
    }
    clampFilter.setValue(ciImage, forKey: kCIInputImageKey)
    let blurredImage = clampFilter.outputImage?.applyingFilter("CIGaussianBlur", parameters: [
        kCIInputRadiusKey: radius
    ])
    guard let output = blurredImage,
          let cgimg = context.createCGImage(output, from: ciImage.extent) else {
        return self
    }
    return UIImage(cgImage: cgimg)
}
```

위 방식은 이미지를 전부 blur 처리하는 함수이지만 부분 처리하고 싶다면 크롭하는 과정을 추가하고 composited를 이용하여 합성하면 될 줄 알았는데 작동하지 않습니다.

> 그 원인을 찾기 위해라도 Core Image 문서를 하나하나 읽어보며 뒤져보고 있습니다.

```swift
// ❌
func blurredImage(with context: CIContext = .init(), radius: CGFloat, atRect rect: CGRect) -> UIImage {
    guard let ciImage = CIImage(image: self) else { return self }

    let croppedImage = ciImage.cropped(to: rect)
    let blurFilter = CIFilter(name: "CIGaussianBlur")
    blurFilter?.setValue(croppedImage, forKey: kCIInputImageKey)
    blurFilter?.setValue(radius, forKey: kCIInputRadiusKey)

    if let ciImageWithBlurredRect = blurFilter?.outputImage?.composited(over: ciImage),
       let outputImage = context.createCGImage(ciImageWithBlurredRect, from: ciImageWithBlurredRect.extent) {
        return .init(cgImage: outputImage)
    }
    return self
}
```

<img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/Simulator%20Screen%20Shot%20-%20iPhone%2014%20Pro%20-%202022-10-19%20at%2012.50.48.png" width="250">

위는 두번의 필터 과정을 거쳐서 나온 결과물입니다. 

아래는 UIBurEffect에서 레이어를 쌓는 것과는 달리 이미지 콘텐츠 자체를 변경한 것을 확인할 수 있습니다.

<img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-10-19%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%2012.54.15.png" width="500">

**장단점**
Core Image로 접근하게 된다면 정말 여러가지의 Image Filter를 사용할 수있고 커스텀까지 가능합니다. 또한 GPU 기반 렌더링이므로 높은 퍼포먼스를 보입니다. 그리고 CIFliter는 이미지 콘텐츠 자체에 바꿔버려 렌더링이 적용됩니다. 하지만 Core Image 개념을 잘 알아야 다루기 쉽다는 단점이 있습니다. 또한 오류가 쉽게 나는 key-value 코딩이 필요합니다.

### Metal 사용하기

Metal은 GPU한테 직접적으로 연산과 그래픽 작업을 수행하게 합니다. CPu를 전혀 안쓰기 때문에 CPU는 다른 작업을 수행할 수 있습니다. CPU보다 GPU가 그래픽 처리에 더 빠르고 효율적인 이유는 병렬적인 작업에 최적화되어있기 때문입니다. Core Image 프레임워크 또한 Metal을 이용해서 GPU한테 그래픽 작업을 시킵니다. 마찬가지로 Core ML도 Metal을 이용합니다. 

> Metal을 사용하기 위해선 더 자세하게 들어가야합니다. 그래서 일단 Core Image 프레임워크를 먼저 공부하고 오려고 합니다. 



- https://betterprogramming.pub/three-approaches-to-apply-blur-effect-in-ios-c1c941d862c3
