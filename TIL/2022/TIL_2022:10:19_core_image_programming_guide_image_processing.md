### Today I Learned 

----

2022.10.19 (수)

[Core Image Programming Guide에서 이미지 처리하기(Image Processing)](https://developer.apple.com/library/archive/documentation/GraphicsImaging/Conceptual/CoreImaging/ci_tasks/ci_tasks.html#//apple_ref/doc/uid/TP30001185-CH3-TPXREF101)을 읽으려다 [잘 작성된 글](https://sujinnaljin.medium.com/core-image-programming-guide-이미지-처리하기-1648cc5ac5de)이 있어서 함께 읽으며 공부했습니다. 전부는 이해하지 못했지만 Core Image객체를 이전보단 이해하며 문서를 읽을 수 있게 된 것 같습니다. 



### Core Image를 통해 이미치 처리하기 

- 이 의미는 이미지 필터를 적용한다는 것과 같습니다.
- 이미지 처리는 `CIFilter`와 `CIImage` 클래스를 통해 이뤄집니다. 
  - `CIFilter`에 `CIImage`를 적용하고 그 결과를 나타내기 위해 다른 시스템 프레임워크를 통합허가나
  - `CIContext` 클래스로 자신만의 렌더링 처리 과정을 만들어내야 합니다.

----

### Come Image 처리 예제

```swift
import CoreImage
 
let context = CIContext()                                           // 1
 
let filter = CIFilter(name: "CISepiaTone")!                         // 2
filter.setValue(0.8, forKey: kCIInputIntensityKey)
let image = CIImage(contentsOfURL: myURL)                           // 3
filter.setValue(image, forKey: kCIInputImageKey)
let result = filter.outputImage!                                    // 4
let cgImage = context.createCGImage(result, from: result.extent)    // 5
```

1. `CIContext` 객체 생성, 항상 필요한 것은 아니지만, 자신만의 렌더링 처리과정을 만들어내기 위해선 필요합니다. 무거운 객체이기 때문에 앱 전체에서 하나를 만들고 재사용합니다. 
2. `CIFilter` 객체 생성하고 파라미터값을 줍니다. 
3. `CIImage` 객체를 생성하고 위에서 생성한 필터의 파라미터 값으로 넣어줍니다.
4. 필터의 output을 통해 `CIImage`객체를 얻을 수 있습니다. 이 시점은 아직 필터가 시행되지 않은 상태입니다. image 객체는 단지 특정한 `filter`,`parameters`, `input`을 가지고 어떻게 이미지를 생성할 지에 대한 "레시피"일 뿐입니다. 
5. 아웃풋 이미지를 `Core Graphics`이미지로 렌더링해서 보거나 파일로 저장가능하게 만듭니다. 

----

### Images are the Input and Output of Filters

- `CIImage` 객체는 `CIFilter`의 input이자 output입니다. 

- 그럼 CIImage 객체는 무엇일까요?

- `CIImage`객체는 이미지를 나타내는 변하지 않는 객체이지만 실제 이미지 비트 맵 데이터를 나타내지 않습니다. 

- 대신, 이미지 생성을 위한 "레시피"입니다. 

- Core Image는 화면에 표시되기 위해 이미지 렌더링이 요청될 때에야 레시피를 수행합니다.

- Core Image의 image객체는 거의 모든 이미지 데이터를 이용해서 만들 수 있습니다. 

  - 이미지 파일을 나타내는 URL이나 이미지 파일 데이터를 담고 있는 NSData 객체

  - `Quartz2D`, `UIKit`, 또는 `AppKit` 의 이미지 표현들(`CGImageRef`, `UIImage`, 또는 `NSBitmapImageRep` 객체)

  - `Metal`, `OpenGL`, 또는 `OpenGL ES` textures

  - CoreVideo image 나 pixel buffers 

  - 프로세스와 이미지 데이터를 공유하는 `IOSurfaceRef` 객체

  - 메모리에 있는 이미지 비트맵 데이터 

- `CIImage` 객체가 담고 있는 렌더링 요청은 `CIContext`의 render 또는 draw 메소드를 통해 명시적으로 작성할 수도 있습니다. 
- 또한, Core Image와 함께 동작하는 많은 시스템 프레임워크 중 하나를 사용해서 이미지를 보여주는 방법과 같이 암시적으로 할 수도 있습니다. 

- 렌더링 요청이 이뤄질 때까지 이미지 처리를 미루는 건 퍼포먼스적으로 좋습니다. (빠르고, 효율적)
- 렌더링할 때, Core Image는 이미지에 하나이상의 필터가 적용되는 지 확인하고, 자동으로 모든 "레시피"를 통합하고 중복 작업은 제거하여 각 픽셀은 한번만 처리되기 떄문입니다. 

----

### Filters Describe Image Processing Effects

- `CIFilter` 객체는 이미지 처리 효과와 처리 정도를 컨트롤하기 위한 파라미터를 변경할 수 있는 객체입니다.
- 필터를 사용하기 위해서는 `CIFilter` 객체를 만들고 input 파라미터를 설정하고 output 이미지를 뽑아냅니다. 
- 시스템이 이미 알고 있는 필터의 이름을 사용해서 필터 객체를 생성하려면 `filterWithname:` 생성자를 호출합니다.



- 대부분의 필터의 input 파라미터는 `NSNumber`와 같이 데이터 타입을 명시하는 attribute class가 있습니다. 
- 또한 optional하게 다른 attribute를 가질 수 있습니다. 
  - 예를들어, `CIColorMonochrome`필터는 처리될 이미지, 색깔, 적용강도와 같은 세개의 input 파라미터가 있습니다. 
- Filter파라미터는 key-value쌍으로, `valueForKey:` 나`setValue:forKey:` 메소드를 이용하거나` Core Animation`과 같이`key-value `코딩을 기반으로 하는 다른 기능을 사용해 파라미터를 사용합니다. 
  - `key`는 세팅된 값.

> CIFilter 객체는 변경이 가능합니다. 따라서 다른 스레드 간에 안전한 공유를 보장할 수 없습니다. 각각의 스레드는 자신만의 CIFilter 객체를 만들어야합니다. 하지만 필터의 `input`과 `output`에 해당하는 `CIImage`객체는 변경이 불가능하기 때문에 스레드 간 전달도 안전합니다. 

----

### Chaining Filters for Complex Effects

- 필터는 `CIImage`객체를 input으로 받고 output으로 생성하므로 이는 연속적으로 시퀸스를 이룰 수 있습니다.
- 야래 사진처럼 Color filter -> Bloom filter -> Crop filter를 거쳐 `CIImage`객체를 생성할 수 있습니다.

<img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-10-19%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%203.38.51.png" width="600">

- 위에서도 이야기했듯이 Core Image는 필터를 연속적으로 사용해도 중복 작업은 모두 제거하고 한번의 처리 과정을 거치기 때문에 최적화되어있습니다. "레시피"일뿐 
- 아래 사진이 더 정확한 과정을 보여줍니다. 

<img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-10-19%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%203.43.09.png" width="600">

- 위 사진에서 Crop과정이 마지막에서 첫번째로 옮겨진 것을 확인할 수 있습니다. 
- 이를 통해 크롭을 첫번째로 시행하여 비싼 이미지 처리 과정을 필요한 부분에만 적용할 수 있습니다. (최적화)

```swift
func applyFilterChain(to image: CIImage) -> CIImage {
    // The CIPhotoEffectInstant filter takes only an input image
    let colorFilter = CIFilter(name: "CIPhotoEffectProcess", withInputParameters:
        [kCIInputImageKey: image])!
    
    // Pass the result of the color filter into the Bloom filter
    // and set its parameters for a glowy effect.
    let bloomImage = colorFilter.outputImage!.applyingFilter("CIBloom",
                                                             withInputParameters: [
                                                                kCIInputRadiusKey: 10.0,
                                                                kCIInputIntensityKey: 1.0
        ])
    
    // imageByCroppingToRect is a convenience method for
    // creating the CICrop filter and accessing its outputImage.
    let cropRect = CGRect(x: 350, y: 350, width: 150, height: 150)
    let croppedImage = bloomImage.cropping(to: cropRect)
    
    return croppedImage
}
```

---

### Using Special Filter Types for More Options

- 대부분의 필터는 현재까지 말한 방식대로 동작합니다. (input -> filter -> output)
- 하지만, 더 특별한 효과들을 만들 때는 더 복잡한 workflow를 만들기 위해서 다른 필터와 결합할 때 사용할 수 있는 다른 타입들도 있습니다. 

| 필명              | 기능                                                         |
| ----------------- | ------------------------------------------------------------ |
| `compositing`필터 | 사전 공식에 따라 두이미지를 합칩니다. [CISourceInCompositing](https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/filter/ci/CISourceInCompositing)나 [CIMultiplyBlendMode](https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/filter/ci/CIMultiplyBlendMode) 필터 등이 있고 더 많은 composing 필터를 알고 싶다면 [CICategoryCompositeOperation](https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/uid/TP30000136-SW71) 카테고리를 query하면 된다. |
| `generator`필터   | input 이미지를 받지 않습니다. 대신 scratch에서 새로운 이미지를 생성하기 위해 다른 input파라미터를 받습니다. |
| `reduction` 필터  | input 이미지 위에서 동작하지만 기존의 방식대로 output image를 생성하기 보다는 output은 input image의 정보를 나타냅니다. 예를 들어, [CIAreaMaximum](https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/filter/ci/CIAreaMaximum) 필터는 이미지의 특정 부분에서 가장 밝은 색상값을 나타냅니다. 이 필터의 output으로는 비트 맵 이미지 데이터로 사용하지 않고 single-pixel, single-row 이미지를 익거나 다른 필터의 input으로 사용합니다. |
| `transition` 필터 | 두 개의 input 이미지를 받습니다. 그리고 독립 변수에 따라 그 결과가 달라집니다. 주로 시간을 변수로 둬서 하나의 이미지로 시작해서 다른 이미지로 끝나며 흥미로운 시간 효과로 진행되는 애니메이션을 만들 수 있게 도와줍니다. |

---

### Integrating with Other Frameworks

- Core Image는 iOS, macOS, tvOS의 다른 기술들과 상호작용할 수 있습니다. 
- Core Image를 사용하기 위해 system framework가 제공하는 편리한 점이 무엇일까요?

**1. UIKit과 AppKit**

- 여행앱은 목적지에 스톡 사진이 있습니다. 이것들에 필터를 적용해서 각 목적지의 상세 페이지에 subtle background를 만들 수 있습니다. 
- 소셜 앱은 유저의 아바타 사진에 기분을 나타내기 위해 필터를 적용할 수 있습니다.
- iOS, tvOS 에서는 `UIImage` 객체에 많은 Core Image 필터를 적용한 것을 볼 수 있습니다. 

```swift
// Applying a filter to an image view (iOS/tvOS)

class ViewController: UIViewController {
    let filter = CIFilter(name: "CISepiaTone",
                          withInputParameters: [kCIInputIntensityKey: 0.5])!
    @IBOutlet var imageView: UIImageView!
    
    func displayFilteredImage(image: UIImage) {
        // Create a Core Image image object for the input image.
        let inputImage = CIImage(image: image)!
        // Set that image as the filter's input image parameter.
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        // Get a UIImage representation of the filter's output and display it.
        imageView.image = UIImage(CIImage: filter.outputImage!)
    }
}
```

> Core Image를 유저 인터페이스 디자인의 일부에 blur 효과를 만드는데 사용하지 마세요. 이미 있는 system appearance를 이용해서 효과적인 실시간 렌더링을 처리하세요.

**2. AV Foundation 영상처리**

- AV Foundation 프레임워크는 비디오 및 오디오 처리를 돕는 높은 레벨의 유틸리티를 제공합니다. 
- 이 중 `AVVideoComposition` 클래스를 이용해서 비디오와 오디오 트랙을 하나의 결과물로 결합할 수 있습니다.

```swift
// Applying a filter to a video composition

let filter = CIFilter(name: "CIGaussianBlur")!
let composition = AVVideoComposition(asset: asset, applyingCIFiltersWithHandler: { request in
    
    // Clamp to avoid blurring transparent pixels at the image edges
    let source = request.sourceImage.clampingToExtent()
    filter.setValue(source, forKey: kCIInputImageKey)
    
    // Vary filter parameters based on video timing
    let seconds = CMTimeGetSeconds(request.compositionTime)
    filter.setValue(seconds * 10.0, forKey: kCIInputRadiusKey)
    
    // Crop the blurred output to the bounds of the original image
    let output = filter.outputImage!.cropping(to: request.sourceImage.extent)
    
    // Provide the filter output to the composition
    request.finish(with: output, context: nil)
})
```

- `videoCompositionWithAsset:applyingCIFiltersWithHandler:` 생성자를 통해 필터를 만들때, 비디오의 각 프레임에 필터 적용을 책임지는 핸들러를 제공해야합니다. 
- `AVFoundation`은 재생이나 추출할 때 자동으로 핸들러를 호출합니다. 
- 이 핸들러에서는 제공된 `AVAsynchronousCIImageFilteringRequest` 객체를 사용해서 필터 처리되어야하는 비디오 프레임을 가져오고 필터 처리된 이미지를 제공합니다.
- 생성된 비디오를 재생하기 위해서는 `AVPlayerItem`객체를 만들고 위에서 만든 compostion을 `videoComposition`프로퍼티에 할당합니다.

> 위 예제에서 blur필터는 디폴트로 이미지의 가장자리도 blur 처리를합니다. 이러한 효과는 비디오에 필터를 입힐 때 의도하지 않을 수 있습니다.
>
> 따라서 이런 효과를 피하기 위해서는 `imageByClampingToExtent` 메소드 (또는 [CIAffineClamp](https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/filter/ci/CIAffineClamp) filter)를 사용합니다. (오 여기 이 개념이 나오네요. BlurEffect 트러블 슈팅할 때 사용헀던 AffineClamp) Clamping은 이미지를 무한한 사이즈로 만들기 때문에 블러 후에 이미지를 잘라야합니다. 

**3. SpriteKit과 SceneKit에서 게임 컨텐츠 관리**

- SpriteKit은 2D 게임이나 고도로 동적인 컨텐츠의 특성을 가진 앱을 만드는데 쓰이는 기술입니다. 
- SceneKit은 3D assert을 만들고 3D 장면을 렌더링하고 보여주며 3D 게임을 만듭니다. 
- 이 두 프레임워크 모두 장면에 대해 Core Image 처리를 적용하는 간편한 방법과 함께 고성능의 실시간 렌더링을 제공합니다. 

 **3.1 SpriteKit**

- SpriteKit에서는 SKEffectNode 클래스를 사용해서 Core Image를 적용할 수 있습니다. 
- SpriteKit 게임 템플릿을 Xcode 프로렉트에서 생성한 후 GameScene 클래스의 `touchesBegan:withEvent:`함수를 아래처럼 변경합니다. 

```swift
// Applying filters in SpriteKit

override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    for touch in touches {
        let sprite = SKSpriteNode(imageNamed:"Spaceship")
        sprite.setScale(0.5)
        sprite.position = touch.location(in: self)
        sprite.run(.repeatForever(.rotate(byAngle: 1, duration:1)))
        
        let effect = SKEffectNode()
        effect.addChild(sprite)
        effect.shouldEnableEffects = true
        effect.filter = CIFilter(name: "CIPixellate",
                                 withInputParameters: [kCIInputScaleKey: 20.0])
        
        self.addChild(effect)
    }
}
```

- `SKScene` 클래스는 `SKEffectNode`의 subclass이기 때문에 모든 SpriteKit scene에 Core Image필터를 적용할 수 있습니다. 

**3.2 SceneKit**

- `SCNNode` 클래스의 `filters` 속성을 통해 3D scene 요소에 Core Image 필터를 적용할 수 있습니다. 
- SceneKit 게임템플릿을 Xcode 프로젝트에서 생성한 후 `GameViewController` 클래스의 `viewDidLoad` 부분을 아래와 같이 수정하면 확인 가능합니다. 

```swift
// Applying filters in SceneKit

let ship = rootNode.childNode(withName: "ship", recursively: true)!
 
// Add these lines after it:
let pixellate = CIFilter(name: "CIPixellate",
                         withInputParameters: [kCIInputScaleKey: 20.0])!
ship.filters = [ pixellate ]
```

- SpriteKit과 SceneKit 모두 뷰의 Scene에 추가적인 시각효과를 더하기 위해 transition을 사용할 수 있습니다. 
  - SpriteKit의 `presentScene:transition:`
  - SceneKit의 `presentScene:withTransition:incomingPointOfView:completionHandler:`
- `SKTransition`클래스와`transitionWithCIFilter:duration:` 생성자를 사용해서 Core Image transition 필터를 통한 transition animation을 만들 수 있습니다. 

**4. macOS에서 Core Animation Layer 처리**

- macOS에서 CALayer 콘텐츠에 필터를 적용하고 싶을때나 시간의 흐름에 따라 필터 파라미터가 변화하는 애니메이션을 주고 싶을 때 `filters`프로퍼티를 사용할 수 있습니다.

----

### Building Your Own Workflow with a Core Image Context

- system 프레임워크를 이용하면 자동으로 Core Image가 이미지를 처리하고 결과를 렌더링할 수 있습니다. 이를 통해 성능을 최적화하고 쉽게 사용할 수 있습니다.
- 하지만, 정밀하게 앱의 성능 특성을 제어하거나 렌더링 기술과 Core Image를 통합하고 싶다면 `CIContext` 클래스를 이용할 수 있습니다. 
- `CIContext`는 CPU, GPU 컴퓨팅 기술, 리소스, 필터를 처리하고 이미지를 생상하는데 필요한 설정을 나타냅니다. 

**1. Automatic Context**

- 기본적인 `init`이나 `initWithOptions`생성자를 사용하여 Core Image context를 만들면 자동으로 Core Image는 현재 디바이스와 선택된 options에 알맞게 CPU 또는 GPU 렌더링 기술을 선택합니다. 

> 명시적으로 렌더링 대상을 정하지 않은 context는 `drawImage:inRect:fromRect:`메소드를 사용할 수 없습니다. 이 함수는 렌더링 대상에 따라 변하기 떄문에 생성할 때 지정하거나 `render`, `create`함수를 사용해서 명시적 대상을 지정할 수 있습니다.

**2. Metal**

- Metal 프레임워크는 그래픽 렌더링 및 병렬 컴퓨팅 작업에 대해 높은 성능을 보여주며 GPU 접근에 낮은 오버헤드 접근을 제공합니다. 
- 이는 이미지 처리에 필수적이기 떄문에 Core Image는 최대한 Metal 프레임워크 위에서 진행합니다. 
- 만일 Metal을 이용하여 그래픽을 렌더링하는 앱을 만들거나 실시간 성능을 얻기 위해 Metal을 이용한다면 자신의 Core Image context를 만드는 Metal 디바이스를 사용합니다. 



- 아래 예시는 `MTKView`를 이용해서 Core Image를 렌더링하는 예시입니다. 

```swift
// Setting up a Metal view for Core Image rendering

class ViewController: UIViewController, MTKViewDelegate {  // 1
    
    // Metal resources
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var sourceTexture: MTLTexture!                         // 2
    
    // Core Image resources
    var context: CIContext!
    let filter = CIFilter(name: "CIGaussianBlur")!
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        device = MTLCreateSystemDefaultDevice()            // 3
        commandQueue = device.newCommandQueue()
        
        let view = self.view as! MTKView                   // 4
        view.delegate = self
        view.device = device
        view.framebufferOnly = false
        
        context = CIContext(mtlDevice: device)             // 5
        
        // other setup
    }
}
```

- sourceTexture 프로퍼티는 필터에 의해 처리될 이미지를 가지고 있는 Metal texture를 가지고 있습니다. 
- 이 texture를 초기화할 방법은 많습니다. - 예를 들어,  `MTKTextureLoader` 클래스를 이용해 이미지를 가져와 할당할 수 있고, 혹은 이전에 렌더링되어 결과로 나온 texture를 다시 input으로 사용할 수 있습니다. 
- `MTLCreateSystemDefaultDevice` 클래스를 이용해 사용할 GPU를 초기화합니다. `MTLCommandQueue`는 GPU에 내릴 연산과 렌더링 명령들을 실행하는 클래스입니다. 
- Metalkit view를 configure합니다.
- CIContext를 생성합니다. 이때 위에서 생성한 Metal 디바이스를 사용하여 초기화합니다. 같은 자원을 공유하여 Core Image는 CPU와 GPU 메모리 버퍼를 통해 이미지 데이터를 복사해서 전달할 비용을 줄일 수 있습니다. 



- MetalKit은 뷰가 표시될 때  `drawInMTKView`함수를 호출합니다. (기본적으로 MetalKit은 초당 60번까지 부를 수 있다.)

```swift
// Drawing with Core Image filters in a Metal view

public func draw(in view: MTKView) {
    if let currentDrawable = view.currentDrawable {              // 1
        let commandBuffer = commandQueue.commandBuffer()
        
        let inputImage = CIImage(mtlTexture: sourceTexture)!     // 2
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(20.0, forKey: kCIInputRadiusKey)
        
        context.render(filter.outputImage!,                      // 3
            to: currentDrawable.texture,
            commandBuffer: commandBuffer,
            bounds: inputImage.extent,
            colorSpace: colorSpace)
        
        commandBuffer.present(currentDrawable)                   // 4
        commandBuffer.commit()
    }
}
```

> 이 내요은 blur 효과를 줄 때 봤던 방법인데 여기 나오다니.. 나중에  [*Metal Programming Guide*](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40014221)를 공부해보자 .

**3. OpenGL나 OpenGL ES**

- Core Image는 고성능을 위해 GPS기반 렌더링의 OpenGL(macOS)과 OpenGL ES(iOS,tvOS)를 사용할 수 있습니다. 
- Metal로는 사용불가능한 오래된 하드웨어를 사용하고 싶을 때 혹은 OpenGL, OpenGL ES에서 Core Image를 적용하고 싶은 상황에 이 옵션을 사용합니다. 

**4. Quartz 2D**

- 앱이 실시간 성능을 요구하지 않고 CoreGraphics를 사용하여 뷰 콘텐츠를 그리는 경우에는 `contextWithCGContext:options` 생성자를 사용하여 이미 다른 drawing에 사용중인 Core Graphics context와 직접 work가 가능한 Core Image Context를 생성할 수 있습니다.







- https://developer.apple.com/library/archive/documentation/GraphicsImaging/Conceptual/CoreImaging/ci_tasks/ci_tasks.html#//apple_ref/doc/uid/TP30001185-CH3-SW5
- https://sujinnaljin.medium.com/core-image-programming-guide-이미지-처리하기-1648cc5ac5de

