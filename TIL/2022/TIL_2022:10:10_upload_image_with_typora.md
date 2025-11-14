### Today I Learned 

----

2022.10.10 (월)



Typora로 이미지 바로 업로드하기 

타이포라로 글을 작성하는데 매번 이미지를 올릴 떄마다 너무 귀찮았습니다. 처음엔 글을 다 작성한 후 이미지를 하나하나 다 올려줬는데 올린 후 이미지 위치와 사이즈 조절까지... 👿 그래서 바로 이미지 올리는 방법을 오늘 적용해봤습니당

먼저, upic이라는 중국에서 만든 프로그램을 다운받아야합니다. 터미널에 명령어 `brew install bigwig-club/brew/upic --cask` 입력해주세요. 그리고 프로그램을 실행하게 되면, 아래와 같이 메뉴바에서 upic 프로그램을 볼 수 있고 선택후 `Preferences` -> `Host`를 눌러줍니다. 

<div align="center"><img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-10-10%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%205.34.32.png" width="400"></div>

아래와 같은 설정 창이 나옵니다. 처음에는 SMMS라는 것만 호스트에 존재합니다. SMMS를 지웁니다. 지워주지 않으면 나중에 메뉴바에서 upic 선택 후 Github을 선택해야 업로드가 정상적으로 동작이 됩니다. (더 귀찮음..) Owner는 내 github 닉네임, Repo는 내 github 저장소, Token은 Github에서 발급받은 토큰입니다. 토큰을 발급받는 방식은 생략할게요. 그리고 Save를 눌러줍니다. 

<div align="center"><img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202022-10-10%20%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE%205.35.22.png" width="500"></div>



마지막으로, Typora의 설정에서 이미지 -> 이미지 업로드 설정의 이미지 업로더를 uPic으로 선택하고 재실행합니다. 그럼 이제 타이포라에서 이미지를 복사 붙여넣기 하면 이미지 업로드라는 항목이 나오고 선택하면 바로 지정 레포지토리에 업로드 후, URL을 가져옵니다. 🎉

<div align="center"><img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/2022-10-10%2017.42.33.gif" width="700"><br /><img src="https://raw.githubusercontent.com/hello-woody/img-uploader/master/uPic/woody2.png" width="200"></div>









- https://kilbong0508.tistory.com/450