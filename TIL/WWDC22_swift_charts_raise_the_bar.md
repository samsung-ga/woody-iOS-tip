### WWDC22 Swift Charts: Raise the bar

----



## Marks and composition<br />마크와 마크 구성  

![스크린샷 2022-11-01 오후 10.20.24](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-01%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%2010.20.24.png)

Mark는 데이터를 나타내는 그래픽 요소입니다. 위 차트는 막대 마크이고 여섯 개의 마크가 있으며 각각 팬케이크의 유형과 판매량을 나타냅니다.

<br />

![스크린샷 2022-11-01 오후 10.23.26](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-01%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%2010.23.26.png)

코드를 살펴보겠습니다. 위 코드는 단일 차트를 표현할 때 가장 적절한 유형입니다. 차트의 제목과 빈 차트를 볼 수 있습니다.

<br />

![스크린샷 2022-11-01 오후 10.24.43](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-01%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%2010.24.43.png)

차트에 마크를 추가할 수 있습니다. 차트의 형태는 해당 뷰에 딱 맞는 형태로 들어갑니다. 

<br />

![스크린샷 2022-11-01 오후 10.26.32](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-01%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%2010.26.32.png)

새 막대 마크를 추가하면 두 번째 막대가 등장합니다. 이것을 반복하면 막대를 늘릴 수 있습니다.

<br />

![스크린샷 2022-11-01 오후 10.27.35](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-01%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%2010.27.35.png)

차트에 들어갈 콘텐츠를 구조체나 튜플 배열을 통해 제공할 수 있습니다. ForEach를 사용해서 각 요소의 값으로 막대 마크를 만들 수 있습니다. 

<br />

![스크린샷 2022-11-01 오후 10.29.46](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-01%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%2010.29.46.png)

만약 ForEach가 차트의 유일한 콘텐츠일 경우 아래와 같이 단축시킬 수도 있습니다.

<br />

여러 SwiftUI modifier를 이용해서 마크에 활용할 수 있습니다.

![스크린샷 2022-11-01 오후 10.30.05](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-01%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%2010.30.05.png)

`foregroundStyle`을 이용해서 막대 색을 설정할 도 있고

<br />

![스크린샷 2022-11-01 오후 10.32.32](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-01%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%2010.32.32.png)

`accessibilityLabel`과 `accessibilityValue` modifier를 이용하여 VoiceOver 사용자에게도 차트 정보를 제공할 수 있습니다. 

<br/>

Mark의 종류도 여러가지가 있습니다. 아래는 날짜가 x축이고 판매량이 y축인 차트입니다. 

![스크린샷 2022-11-01 오후 10.37.20](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-01%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%2010.37.20.png)

먼저, 막대 마크를 이용해 차트를 그릴 수 있습니다.

<br />

![스크린샷 2022-11-01 오후 10.38.01](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-01%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%2010.38.01.png)

그리고 BarMark를 LineMark로 수정한다면 꺽은선 차트를 그릴 수 있습니다.

<br />

![스크린샷 2022-11-01 오후 10.41.21](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-01%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%2010.41.21.png)

두가지 데이터를 하나의 차트로 그렸습니다. 튜플 배열을 이용해서 Chart 내에 2개의 콘텐츠를 삽입했습니다. 각 마크는 `foregroundStyle`을 통해 색깔을 구분했습니다. 시스템은 각 마크가 구분될 수 있도록 색깔을 자동으로 지정해줍니다. (색맹인 사용자도 구분 가능) 각 색상이 의미하는 legend가 추가됩니다. 그리고 `symbol(by:)` modifier를 통해 선에 기호를 추가했습니다. 마지막으로 선이 부드러워 보이도록 보간법을 이용해서 꺽은선을 곡선으로 표현했습니다. 

<br />

![스크린샷 2022-11-01 오후 10.45.30](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-01%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%2010.45.30.png)

이번엔 막대 차트를 그렸습니다. (stacked bar chart) 기본 막대 차트는 두 도시의 총 판매량을 쉽게 파악할 수 있지만 두 도시를 비교하기에는 적절하지 않기에 `position(by:)` modifier를 추가하여 두 도시의 판매량을 쉽게 구분지었습니다. 

<br />

![스크린샷 2022-11-01 오후 10.51.32](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-01%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%2010.51.32.png)

막대 마크와 꺽은선 마크 이외에도 점, 영역, 괘선, 직사각형 마크 등이 있습니다. 이러한 마크들을 결합하면 복잡한 차트가 탄생합니다. 

<br />

![스크린샷 2022-11-01 오후 10.54.59](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-01%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%2010.54.59.png)

꺽은선 마크와 영역 마크의 조합입니다. `opacity`를 주어 꺽은 선이 보이도록 했습니다.

<br />

![스크린샷 2022-11-01 오후 10.56.34](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-01%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%2010.56.34.png)

막대 마크와 직사각형 마크의 조합입니다. 마크의 높이와 너비를 설정할 수 있습니다. 

<br />

![스크린샷 2022-11-01 오후 10.58.25](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-01%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%2010.58.25.png)

이번엔 위 마크의 opacity를 주어 흐려지게 한 후, RuleMark를 추가했습니다. RuleMark는 연간 평균을 보여 준다는 것을 표시하고자  `annotation` modifier를 이용해서 주석을 추가했습니다. RuleMark 위 선행 정렬과 함께 텍스트 레이블이 추가됐습니다.

<br />

![스크린샷 2022-11-01 오후 11.01.28](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-01%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%2011.01.28.png)

이렇게 마크를 조합하여 박스 플롯 차트, 멀티 시리즈 꺽은선 차트, 인구 피라미드 레인지 플롯 차트,스트림 그래프 멀티 시리즈 산점 차트 등 여러가지 차트를 그릴 수 있습니다. 

## Plotting data with mark properties<br/>마크 속성을 이용한 데이터 그리기

![스크린샷 2022-11-01 오후 11.05.20](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-01%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%2011.05.20.png)

SwiftUI Charts는 3가지 주요 데이터를 지원합니다. 양적, 명목적, 시간적 데이터입니다. 양적 데이터는 상품 판매량, 온도, 상품 가격 등의 수치입니다. 명목적 데이터 또는 범주형 데이터는 사람의 이름이나 대륙, 상품 유형 등과 같은 개별적 범주 혹은 그룹을 나타냅니다. 시간적 데이터는 특정 하루의 길이나 정확한 거래 시각 등과 같은 특정 시각이나 시간의 간격을 나타냅니다. 

<br />

![스크린샷 2022-11-01 오후 11.09.33](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-01%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%2011.09.33.png)

막대 마크의 동작은 X축과 Y축 프로퍼티로 표시된 데이터 유형에 따라 달라집니다. 막대의 방향은 양적 속성의 위치에 따라 달라집니다.  만약 X축에 판매량이 위치하면 막대 마크는 가로를 향한 모양이고 Y축에 판매량이 위치하면 막대 마크는 위 사진과 같이 세로를 향한 모양입니다.

<br />

![스크린샷 2022-11-02 오전 2.12.43](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-02%20%E1%84%8B%E1%85%A9%E1%84%8C%E1%85%A5%E1%86%AB%202.12.43.png)

마크 유형은 6가지이고 데이터의 유형은 3가지로 배열할 수 있는 조합은 여러가지 입니다. 덕분에 여러가지 기본 빌딩 블록으로 폭 넓은 차트 디자인을 지원합니다.

<br />

![스크린샷 2022-11-02 오전 2.15.39](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-02%20%E1%84%8B%E1%85%A9%E1%84%8C%E1%85%A5%E1%86%AB%202.15.39.png)

Chart는 마크 프로퍼티를 이용해서 데이터를 그리면 매핑을 생성해서 추상적인 데이터를 적절한 속성값으로 변환합니다. 이 경우 판매량 값을 화면 공간의 Y 좌표로 변환합니다. 여기서 스케일이라는 용어가 사용되는데 스케일은 위치 속성에서 입력값을 적절한 화면 좌표로 변환할 때 몇가지 비율을 이용해 크기를 조절하기 때문에 붙여진 이름입니다. 마크로 데이터를 그릴 때 스케일이 생성되고 데이터를 해당 마크 속성으로 변환합니다. 

<br />

![스크린샷 2022-11-02 오전 2.19.20](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-02%20%E1%84%8B%E1%85%A9%E1%84%8C%E1%85%A5%E1%86%AB%202.19.20.png)

예륻 들면, 위 차트에는 3개의 스케일이 있습니다. 각각의 요일을 X로, 판매량을 Y로, 도시를 foreground style로 변환합니다. 기본적으로 Swift Charts는 데이터에서 자동으로 스케일을 추정해서 즉시 차트를 완성합니다. 

<br />

![스크린샷 2022-11-02 오전 2.24.42](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-02%20%E1%84%8B%E1%85%A9%E1%84%8C%E1%85%A5%E1%86%AB%202.24.42.png)

스케일을 직접 조절할 수 있습니다. 위 예시의 차트는 Y 스케일은 0~150으로 자동으로 선택됩니다. 이때, `chartYScale(domain:)` modifier를 이용해서 스케일의 영역을 0~200으로 고정시킬 수 있습니다. foreground style 또한 `chartForegroundStyleScale` modifier를 이용하여 색을 바꿀 수 있습니다.



## Custumizations<br />사용자 옵션

![스크린샷 2022-11-02 오전 2.27.39](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-02%20%E1%84%8B%E1%85%A9%E1%84%8C%E1%85%A5%E1%86%AB%202.27.39.png)

차트는 axes, legend, plot area로 구성됩니다. axes, legend는 차트를 해석할 수 있도록 돕고, plot area는 두 축 사이의 공간으로 데이터를 그리는 공간입니다. Swift Charts는 이 모든 요소를 커스텀(사용자 지정) 할 수 있습니다.

<br />

![스크린샷 2022-11-02 오전 2.31.18](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-02%20%E1%84%8B%E1%85%A9%E1%84%8C%E1%85%A5%E1%86%AB%202.31.18.png)

먼저 axes를 커스텀해보겠습니다. 위 코드는 X축의 레이블을 수정한 예시입니다. 각 분기의 첫 달인지 확인 한 후 첫달일 경우 강조하고 아니라면 눈금이나 레이블 없이 격자 선만 표시합니다. 이 X축은 분기 데이터를 보여주도록 커스텀했습니다.

<br />

![스크린샷 2022-11-02 오전 2.34.32](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-02%20%E1%84%8B%E1%85%A9%E1%84%8C%E1%85%A5%E1%86%AB%202.34.32.png)

Y축 또한 커스텀할 수 있습니다. .extended 프리셋으로 UI와 어울리게 Y축을 설정할 수도 있고 

<br />

![스크린샷 2022-11-02 오전 2.35.22](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-02%20%E1%84%8B%E1%85%A9%E1%84%8C%E1%85%A5%E1%86%AB%202.35.22.png)

축들을 숨김처리할 수도 있습니다.

<br />

![스크린샷 2022-11-02 오전 2.35.57](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-02%20%E1%84%8B%E1%85%A9%E1%84%8C%E1%85%A5%E1%86%AB%202.35.57.png)

자동 생성되는 Legend 또한 숨김처리할 수 있습니다.

<br />

![스크린샷 2022-11-02 오전 2.37.57](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-02%20%E1%84%8B%E1%85%A9%E1%84%8C%E1%85%A5%E1%86%AB%202.37.57.png)

Plot Area를 커스텀해봅시다. `chartPlotStyle` modifier를 이용하고 후행 클로저에서는 기존 plot area를 받고 수정된 plot area를 반환하는 함수를 작성합니다. 위 예시처럼 차트의 카테고리 수에 따라 plotArea의 높이를 지정할 수 있습니다. 

<br />

![스크린샷 2022-11-02 오전 2.41.02](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-02%20%E1%84%8B%E1%85%A9%E1%84%8C%E1%85%A5%E1%86%AB%202.41.02.png)

특별한 시각효과를 만들 수도 있습니다. 예를 들어 이 다크 모드 차트에서는 `.background` modifier로 분홍색 배경을 넣고 차트가 잘 보이도록 불투명도를 0.2로 설정한 뒤 분홍색으로 1포인트 두께 테두리를 들렀습니다. 

<br />

![스크린샷 2022-11-02 오전 2.41.57](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-02%20%E1%84%8B%E1%85%A9%E1%84%8C%E1%85%A5%E1%86%AB%202.41.57.png)

앞에서 언급한 스케일은 X나 Y 같은 마크 프로퍼티에 데이터값을 매핑하는 함수입니다. Swift Charts는 `ChartProxy`를 이용해서 차트의 X와 Y 스케일에 접근할 수 있습니다. `ChartProxy`의 `position(for:)` 메소드로 주어진 데이터값의 위치를 얻을 수 있고 `value(at:)` 메소드를 사용해서 해당 위치의 데이터값을 얻을 수 있습니다. 이를 이용해서 차트와 다른 뷰를 조정할 수 있습니다.

<br />

![스크린샷 2022-11-02 오전 2.44.45](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-02%20%E1%84%8B%E1%85%A9%E1%84%8C%E1%85%A5%E1%86%AB%202.44.45.png)

예를 들어 인터랙티브 브러싱 뷰를 만들려고 합니다. 차트에서 드래그 제스처로 간격을 선택할 수 있고 그 간격은 세부 정보 뷰에서 행을 필터링하는 데 사용됩니다. `.chartOverlay`와 `chartBackground` modifier에서 `ChartProxy` 객체를 구성할 수 있습니다. 두 modifier는 SwiftUI의 오버레이, 배경 수정자와 유사하지만 `ChartProxy`를 제공합니다. 

<br />

![스크린샷 2022-11-02 오전 2.49.31](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-02%20%E1%84%8B%E1%85%A9%E1%84%8C%E1%85%A5%E1%86%AB%202.49.31.png)

제스처가 시작한 위치에서 plot area의 원점을 빼고 제스터의 현재 위치에서 plot area의 원점을 빼는 방식과 `ChartProxy`를 이용해서 드래그 범위를 구할 수 있습니다.

<br />

![스크린샷 2022-11-02 오전 2.52.53](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-02%20%E1%84%8B%E1%85%A9%E1%84%8C%E1%85%A5%E1%86%AB%202.52.53.png)

범위를 구했다면 범위를 직사각형 마크로 정의하여 현재 선택한 날짜 범위를 시각화할 수도 있고 

<br />

![스크린샷 2022-11-02 오전 2.53.33](https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-11-02%20%E1%84%8B%E1%85%A9%E1%84%8C%E1%85%A5%E1%86%AB%202.53.33.png)

막대 사탕처럼 생긴 오버레이를 만들 수 있습니다. 

<br />

**End.**