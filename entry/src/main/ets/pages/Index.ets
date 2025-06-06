import creator_page from "./badgeCreate/creator_page"
import home_page from "./badgeManage/home_page"
import image from '@ohos.multimedia.image'
import square_page from "./badgeManage/square_page"
import materializePage from "./badgeMaterialize/materialize_page"
import { router } from "@kit.ArkUI"

PersistentStorage.persistProp('uid','')

@Entry()
@Component
struct Index {
  @StorageLink('uid') uid:string = ''
  @StorageLink('cid') cid:string = ''
  @State page_index: number = 0 // 页面的下标

  aboutToAppear(): void {
    if(this.cid!='')
    {
      router.pushUrl({
        url: "pages/companyPages/companyPage"
      })
    }
  }
  onBackPress(): boolean {
    // 返回 true 表示拦截返回事件，阻止默认行为
    return true;
  }
  @Builder
  tab_style(page_index: number, unselected: ResourceStr, selected: ResourceStr, title: string) {
    Stack() {
      if (page_index == this.page_index) {
        Row({ space: 5 }) {
          Image(selected)
            .width(24)
          Text(title)
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
            .fontColor('#007AFF')
        }
        .height(40)
        .width(75)
        .borderRadius(32)
        .justifyContent(FlexAlign.Center)
        .backgroundColor("#F4F1FD")
      } else {
        Row() {
          Image(unselected)
            .width(24)
        }
      }
    }
    .width('100%')
    .height(60)
    .backgroundColor('#f5f5f5')
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column()
      {
        Tabs({ barPosition: BarPosition.End }) {
          TabContent() {
              home_page()
                .width('100%')
                .height('100%')
          }.tabBar(this.tab_style(0, $r("app.media.home_icon_unhighlight"), $r("app.media.home_icon_highlight"), "主页"))


          TabContent() {
            creator_page()
              .width('100%')
              .height('100%')
          }.tabBar(this.tab_style(1, $r("app.media.creator_icon_unhighlight"), $r("app.media.creator_icon_highlight"), "创作"))

          TabContent() {
            square_page()
              .width('100%')
              .height('100%')
          }.tabBar(this.tab_style(2, $r("app.media.square_icon_unhighlight"), $r("app.media.square_icon_highlight"), "广场"))

          TabContent() {
            materializePage()
          }.tabBar(this.tab_style(3, $r("app.media.realizasion_unhighlight"), $r("app.media.realization_highlight"), "实物化"))
        }
        .onChange((index: number) => {
          this.page_index = index
        })
        .animationDuration(0)
        .scrollable(false)
        .zIndex(3)
      }

      .zIndex(2)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
      .width('100%')
      .height('100%')


      // Tab 栏容器
      Column() {
      }
      .width('100%').height(-100)
      .backgroundColor('#F5F5F5') // 设置 Tab 栏的背景颜色
      .expandSafeArea([SafeAreaType.SYSTEM],[SafeAreaEdge.BOTTOM]) // 扩展到 Safe Area 的底部

    }.expandSafeArea().backgroundImage(this.page_index == 0 ? $r('app.media.home_background') : this.page_index == 1 ? $r("app.media.select_flash_back_backgroud") : this.page_index == 2 ? $r("app.media.square_background") : this.page_index == 3 ? $r("app.media.materialize_background") : undefined)
    .zIndex(0)
    .backgroundImageSize(ImageSize.FILL)
  }
}