import * as buttons from "../../page_compolents/buttons"
import { router } from '@kit.ArkUI'

interface  ParamsObj{
  budget_specification: number
}

@Entry
@Component
struct Choose_Flash_Bottom {
  @State now_flash_bottom: ResourceStr = $r("app.media.original")
  @State isShow: boolean = false
  @State budget_specification: number = 58
  aboutToAppear(): void {
    const params = router.getParams() as ParamsObj
    this.budget_specification = params.budget_specification
  }


  @Builder select_sheet() {
    Select_Flash_Bottom({
      selectedFlashBottom: $now_flash_bottom, // 使用 @Link 传递状态
      isShow: $isShow // 使用 @Link 传递状态
    })
  }

  build() {
    Stack() {
      Image($r("app.media.select_flash_back_backgroud")).expandSafeArea()
      Column({ space: 20 }) {
        buttons.back_button({ content: "上一步" }).alignSelf(ItemAlign.Start)
        Blank()
          .height(20)
        Column()
        {
          Text("选择闪底")
            .fontSize(36)
            .fontWeight(FontWeight.Bold)
            .alignSelf(ItemAlign.Start)
          Text(`当前制作的是${this.budget_specification}mm的吧唧`).alignSelf(ItemAlign.Start)
        }.width('100%')

        Column()
        {
          Image(this.now_flash_bottom)
            .width(this.budget_specification*3.5)
            .onClick(() => {
              this.isShow = true
            })
              //75->262.5
              //58->203
              //3.5X
            .bindSheet($$this.isShow, this.select_sheet(), {
              detents: [SheetSize.MEDIUM, SheetSize.LARGE, 350],
              title: { title: "选择一个闪底种类" }
            })
        }.width('100%')
        .height(300)

        Blank().height(150)
        buttons.next_step_button({ push_router_url: 'pages/Budget_Create_pages/upload_picture' })

      }.width('100%')
      .height('100%')
      .padding({ left: 20, right: 20 })
    }
  }
}

interface Flash_Bottoms {
  name: string
  image_res: ResourceStr
}

@Component
struct Select_Flash_Bottom {
  @Link selectedFlashBottom: ResourceStr; // 使用 @Link 接收父组件的状态
  @Link isShow: boolean; // 使用 @Link 接收父组件的状态

  flash_bottoms: Flash_Bottoms[] = [
    { name: "哑银", image_res: $r('app.media.dumb_silver') },
    { name: "亮银", image_res: $r('app.media.light_silver') },
    { name: "哑金", image_res: $r('app.media.dumb_gold') },
    { name: "银葱", image_res: $r('app.media.silver_onion') },
    { name: "拉丝银葱", image_res: $r('app.media.brushed_silver_onion') },
    { name: "金葱", image_res: $r('app.media.golden_onion') },
    { name: "幻彩珠光", image_res: $r('app.media.iridescent_pearl') },
    { name: "幻彩拉丝", image_res: $r('app.media.iridescent_brushed_wire') },
    { name: "幻彩白葱", image_res: $r('app.media.iridescent_white_onion') },
  ];

  build() {
    Column() {
      Button('不使用闪底')
        .buttonStyle(ButtonStyleMode.TEXTUAL)
        .width('100%')
        .onClick(() => {
          this.selectedFlashBottom = $r("app.media.original"); // 更新父组件的状态
          this.isShow = false; // 关闭选择面板
        })

      Column() {
        Grid() {
          ForEach(this.flash_bottoms, (item: Flash_Bottoms, index: number) => {
            GridItem() {
              Column() {
                Image(item.image_res)
                  .width(64)
                Text(item.name)
              }
            }.backgroundColor('#f5f5f5')
            .padding(5)
            .borderRadius(32)
            .onClick(() => {
              this.selectedFlashBottom = item.image_res; // 更新父组件的状态
              this.isShow = false; // 关闭选择面板
            })
          })
        }
        .width('100%')
        .columnsTemplate('1fr 1fr 1fr')
        .columnsGap(20)
        .rowsGap(20)
        .padding(5)
        Blank().height(100)
      }
    }.width('100%')
    .padding({ left: 20, right: 20 })
  }
}