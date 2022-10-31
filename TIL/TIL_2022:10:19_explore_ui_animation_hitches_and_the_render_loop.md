### Today I Learned

----

2022.10.19 (수)



### Hitch?

Hitch는 예상했던 것보다 화면이 더 늦게 나오는 현상입니다. 스크롤할 때 버벅이는 현상을 Hitch라고 합니다. 스크롤을 할 때, 손가락을 계속 올리긴 하지만, 다음 콘텐츠가 보이지 않고 이전 콘텐츠가 보이면 Hitch가 발생했다고 합니다. Hitch는 Render Loop가 프레임 계산을 제시간안에 실패하면 나타납니다. 

Render Loop는 유저가 터치하고 나서부터 OS가 프레임을 연산하고 UI를 바꿀때까지의 과정을 말합니다. 이 과정은 게속 반복되는 과정이기에 루프라고 합니다. 아이폰은 초에 60프레임입니다. (1프레임은 16.67ms임) 아이패드 프로는 120프레임입니다. 

프레임의 시작점마다 디바이스는 VSYNC라는 이벤트를 방출하는데 VSYNC(브이싱크)는 새 프레임이 준비되어야 하는 시점입니다. 이 VSYNC가 방출되는 시점은 디바이스마다 다릅니다.

프레임이 준비되는 과정은 총 세단계입니다. 첫 번째는 App에서 이벤트가 처리되어 UI 변경사항을 결정하는 단계입니다. 두 번째는 Render Server에서 실제로 렌더링되는 단계, 그리고 세 번째는 프레임을 표시하는 단께입니다. 

> App에서 UI 변경 결정 -> Render Server에서 렌더링 -> 프레임 표시 (Ui 표시)

App과 Render Server에서 각각 1프레임을 잡아먹어, UI에 프레임을 표시하기 전에 총 2프레임을 잡아먹는 이중 버퍼링이 되지만 다른 방법으론 Render Server에서 렌더링하는데 1프레임을 추가 제공되기도 합니다.(Falling mode)

Render Loop는 총 5단계로 이루어졌습니다. 

> Event -> Commit -> Render prepare -> Render execute -> Display

Event : 유저가 터치하는 단계, UI를 변경할건가 결정 단계
Commit : 앱이 UI를 변경을 요청하고 render server에 전달하는 단계
Render prepare : commit 단계에서 전달받은 변경 사항을 GPU에서 그릴 수 있도록 준비하는 단계
Render execute : UI를 그리는 단계
Display : 사용자에게 프레임을 보여주는 단계



![event_phase](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/event_phase.png)

예시로 사용자가 bound를 변경시키는 이벤트를 발생시켰다고 해봅시다. 
Event단계에서는 Core Animation은 다시 계산해야 하는 하위 뷰의 레이아웃을 식별하기 위해 `setNeedLayout`을 호출합니다. 
Commit단계에서는 다시 그려야할 layout을 다음 업데이트 주기에 반영하도록 `setNeedsDisplay`를 호출합니다.
Render prepare단계에서는 commit단계에서 전달받은 변경사항을 그립니다. 이 때 렌더링 순서는 위에서부터 아래 순서로 진행됩니다.
Render execute단계에서는 Prepare Phase에서 준비해준대로 그려주는 작업을 합니다. 
마지막 display 단계에서는 렌더링 결과를 보여주기만 하면 됩니다.

하나의 프레임을 완성하는 각 과정은 병렬적으로 일어나는데 하나의 파이프라인이라도 다음 VSYNC가 발생하기 전에 처리되지 못하면 병목현상이 발생합니다. 즉, 다음 VSYNC가 발생하기까지 처리를 못하면 hitch가 발생합니다. 

![def](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/def.png)

### Hitch 종류

- Commit 
- Render



![dfasd](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/dfasd.png)

단계 하나가 자신의 VSYNC 주기에 처리되지 않고 다음 VSYNC에 마무리가 되면 다음 단계들도 줄줄이 밀립니다. 위 사진에선 App에서 event단계가 밀렸기때문에, commit단계도 다음 VSYNC에 처리가 되는 상황을 볼 수 있습니다. 



### Measuring hitch time

![dsakjbfsad](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/dsakjbfsad.png)

하나의 프레임만 만들 때 Hitch가 발생한 정도를 측정하긴 쉽지만 스크롤이나 애니메이션 등의 이벤트에서 hitch가 일어나고 모든 이벤트가 render server로 UI변경사항을 전달하는 게 아니라 정확히 측정하긴 어렵습니다. 

> **대신 hitch가 발생한 시간을 총 시간으로 나눠서 계산하는 방법을 사용합니다. -> hitch time ratio**

![vdfdj](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/vdfdj.png)

30프레임이 모두 자신의 VSYNC 안에서 해결된다면 hitch는 발생하지 않고 당연히 hitch time ratio도 0이 됩니다. 

![udf](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/udf.png)

만약, 몇군데 밀리게 된다면 hitch time / duration 을 통해 hitch time ratio를 측정할 수 있습니다. 

> hitch time ratio = hitch time / duration 



![sinho](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/sinho.png)

애플은 이 hitch time ratio에 색깔도 부여했습니다. 이 hitch time ratio가 노란색이면 고쳐야합니다. 

