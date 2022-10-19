### Today I Learned

----

2022.10.19 (수)



![스크린샷 2022-10-19 오전 2.31.43](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-10-19%20%E1%84%8B%E1%85%A9%E1%84%8C%E1%85%A5%E1%86%AB%202.31.43.png)

오늘은 Core Animation과 OpenGL ES, Graphics Hardware 프레임워크에 대해 다뤄보겠습니다. 
그리고 마지막엔 UIKit의 UIBurEffect와 UIVibrancyEffect를 알아보겠습니다.

## Core Animation Pipline

> 파이브라인이 행해지는 곳 
> Application -> Render Server -> GPU -> (Display)



![스크린샷 2022-10-19 오전 2.36.40](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-10-19%20%E1%84%8B%E1%85%A9%E1%84%8C%E1%85%A5%E1%86%AB%202.36.40.png)

5단계로 이루어집니다. (2021년도에 단계가 위 사진과 다르게 아래와 같이 나옵니다)

> Event발생 -> Commit -> Render prepare -> Render execute -> Display 

총 3개의 Frame동안 진행되거나 더 여러개의 frame동안 진행될 수 있습니다.(hitch 발생) 어쨋거나 파이프라인은 병렬적으로 진행되기 때문에 앱은 잘 작동합니다. (high refresh rate)





## Commit Transaction

Commit Transaction에 대해서 자세히 살펴보겠습니다. 

1. Layout - Set up the views
2. Display - Draw the views
3. Prepare - Additional Core Animation work
4. Commit - Package up layers and send them to render server 

> 직독직해보다 영어가 더 이해가 쉬워서 그대로 가져왔습니다. 

### Layer 단계

- `layoutSubviews`가 불립니다.
-  이 단계에서는 view hierarchy에 `addSubview`를 이용해 layer를 추가합니다. 
- 콘텐츠를 채우거나 데이터베이스에서 무엇인가를 합니다. (localized strings)
- Usually CPU and I/O bound

### Display 단계

- `drawRect`가 불립니다.
- String이 그려집니다. 
- 애플은 CGContext를 통해 이를 렌더링합니다. (core graphic)
- Usually CPU or memory bound

### Prepare 단계

- Image 디코딩 (뷰계층에 이미지가 있을시)
- Image 변환 (GPU로 변환이 되지않는 이미지가 있을 경우)

### Commit 단게

- Layer 정보 담고 render server한테 보냅니다.
- 반복작업 (재귀)
- layer 트리가 복잡할 경우 비싼 작업입니다. 

> Layer 트리는 가능하다면 가장 평평하게 (flat) 만드는 것이 이 commit 단계에서는 가장 효율적입니다. 

## Animation 

> 3가지 프로세스로 이루어집니다.

1. (Application) 애니메이션을 생성하고 View hierarchy를 업데이트합니다. 

   (ex) `UIView.animate(withDuration:animations:completion:)` )

2. (Applcation) 애니메이션을 준비하고 commit합니다. 

   (위 단계에서 본 commit Transaction의 `layoutSubviews`와 `drawRect`단계입니다.)

3. (Render server) 애니메이션이 commit된 순간, render server에서 해당 커밋 내용(UI 변경 사항)을 받습니다. 

## Rendering concepts

### 타일 기반 렌더링

- 화면은 NxN 픽셀단위의 타일로 쪼개져있습니다. 
- 각 타일은 SoC 캐시에 저장되어있습니다. 
- 지오메트리는 타일 버킷(tile bucket)으로 분할됩니다.
- 모든 지오메트리는 제출된 후, Rasterization을 시작할 수 있습니다. 

예를들면, 

- CoreAnimation의 CALayer는 2개의 삼각형입니다. 
- 두개의 (파란색) 삼각형을 위 이미지에서 보면 여러 타일에 걸쳐져 있습니다. 
- GPU는 각 타일의 (파란색) 삼각형을 분할하기 시작하여 (빨간색 삼각형 형성) 각 타일을 개별적으로 렌더링할 수 있습니다. 

> 빨간색이 GPU가 하는일입니다. CALayer는 큰 2개의 삼각형이라고하면 GPU는 이를 더 쪼개서 개별적으로 렌더링합니다. 

### Rendering pass

- render server가 commit된 뷰 계층을 디코딩했다면, OpenGL 또는 메탈을 이용해 렌더링을 시작합니다. 
- render server는 GPU한테 명령합니다. 
- GPU는 명령 buffer를 받고 작업을 시작합니다. 
- Tiler stage(타일 단계): 정점 처리는 정점 정점 셰이더가 실행되는 곳입니다. 이것은 모든 정점을 화면 공간으로 변환하므로 실제 타일링인 두 번째 단계를 수행할 수 있습니다. 
- Tiler 단계의 출력을 파라미터 버퍼라고 합니다.
- GPU는 다음 중 하나가 될 때까지 대기합니다.
  - 모든 지오메트리가 계산되어서 파라미터 버퍼에 놓였을 때까지
  - 파라미터 버퍼가 꽉 찰 때까지
  - Renderer stage: 픽셀 연산이 끝난 시점 
    - Renderer stage의 출력을 Renderer 버퍼라고 불립니다.

### Masking

![mask](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/mask.png)

- Pass1에서, texture layer를 마스킹합니다.
- Pass2에선, texture 콘텐츠 layer를 마스킹합니다.
- Pass3에선, compositioning pass라고도 불리며, layer 마스크는 콘텐츠 layer와 합성되어 파란색 아이콘이 보여집니다. 

> texture가 정확히 무슨 의민지 이해하지 못했습니다. 다만, layer mask -> layer content -> 합성 적용 의 단계를 거쳐 렌더링이 되는 것을 알 수 있습니다. 

### UIBlurEffect 

![uiblur](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/uiblur.png)

- Pass 1에선, 콘텐츠를 렌더링합니다.
- Pass 2에선, 렌더링된 콘텐츠를 축소합니다. 이 축소는 디바이스(하드웨어)에 따라 다릅니다. 
- Pass 3와 4에선, Horizontal, Vertical blur를 적용합니다. 같이 실행되도 될 것 같지만 따로 실행함으로써 메모리를 많이 아낄 수 있습니다. 
- 마지막 Pass 5에선, blur처리가 끝난 이미지를 확대하고 tint를 입힙니다. 

Performance:

- Pass 1, 5는 GPU 시간을 더 필요로 합니다. (content 렌더링, 확대, 틴트)
- 이 둘 사이의 Pass들은 context switching을 위한 GPU idle time(유휴시간)은 짧지만, 그 사이 pass들이 많아질수록, 이 시간은 길어집니다. 이 idle 타임은 각각 0.1~0.2ms이고 이 말은 `UIBlurEffect`를 적용하는 것은 0.4~0.8ms의 GPU idle time이 소요됩니다. 한프레임이 16.67ms이기 때문에 제 시간안에 끝날 수 있습니다. 
- UIBlurEffect가 더 어두울수록 성능은 향상합니다. 

> GPU idle time은 GPU가 대기상태라는 뜻입니다. 즉 CPU의 연산작업이 길어질수록 길어지는 시간입니다. 낮은 성능의 CPU, 혹은 비효율적인 루프나 검색 시간 등에 의해서 GPU로 다시 context switching이 되기까지의 대기시간이 발생하게 됩니다. 

### UIBlurEffect + UIVibrancyEffect (생동감 주는 효과)

![vibrancy](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/vibrancy.png)

- 1 ~ 5 pass는 blur처리를 위해 사용됩니다. 
- 그리고나서, texture layer content를 렌더링합니다. 
- blur 결과와 texture 결과를 합성합니다. 

Performace:

- Blur처리를 위한 Pass는 비싼 작업입니다. 
- Pass 6의 렌더링 작업 또한, 콘텐츠 크기에 따라서 비싼 작업입니다.
- filter pass는 가장 비싼 작업이 됩니다. 
- 추가된 2개의 Pass들로 인해 GPU idle time이0.6~1.2ms로 더 길어집니다. 

Tips:

- screen의 작은 일부만 vibrancy를 적용합니다. 
- enable rasterization(CALayer의 `shouldRasterize`), -> GPU를 이용해 이미지를 합성 가능

> rasterization란? 렌더링 파이프라인의 2번째 단계입니다. 자세한 내용은 더 깊게 들어가야하기 때문에 나중에 공부합시다:) 

- CALayer의 `allowsGroupOpacity` 프로퍼티는 항상 disable 처리합니다. 







- https://www.wwdcnotes.com/notes/wwdc14/419/