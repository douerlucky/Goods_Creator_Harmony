import * as buttons from "../../page_compolents/buttons"
import { router } from '@kit.ArkUI'
import Badge from '../../class/Badge'


@Entry
@Component
struct Choose_Flash_Bottom {
  @StorageLink('badge_create') badge_create:Badge = { } as Badge
  @State now_flash_bottom: string = ("app.media.flash_bottom_original")
  @State now_fb_name:string = '无'
  @State isShow: boolean = false
  @State badge_specification: number = this.badge_create.specification


  @Builder select_sheet() {
    Select_Flash_Bottom({
      selectedFlashBottom: $now_flash_bottom, // 使用 @Link 传递状态
      selectedFBname: $now_fb_name,
      isShow: $isShow // 使用 @Link 传递状态
    })
  }

  build() {
    Stack() {
      Image($r("app.media.select_flash_back_backgroud")).expandSafeArea()
      Column({ space: 20 }) {
        Column()
        {
        buttons.back_button({ content: "上一步" }).alignSelf(ItemAlign.Start).padding({bottom:20})

          Text("选择闪底")
            .fontSize(36)
            .fontWeight(FontWeight.Bold)
            .alignSelf(ItemAlign.Start)
          Text(`当前制作的是${this.badge_create.specification}mm的吧唧`).alignSelf(ItemAlign.Start)
        }.width('100%')

        Column()
        {
          Image($r(this.now_flash_bottom))
            .width(this.badge_specification*3.5)
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

        buttons.next_step_button()
          .onClick(()=>{
            this.badge_create.flash_bottom = this.now_flash_bottom
            this.badge_create.fb_name = this.now_fb_name
            router.pushUrl({ url: 'pages/badgeCreate/upload_picture' })

          })


      }.width('100%')
      .height('100%')
      .padding({ left: 20, right: 20 })
      .justifyContent(FlexAlign.SpaceBetween)
    }
  }
}

interface Flash_Bottoms {
  name: string
  image_res: string
}

@Component
struct Select_Flash_Bottom {
  @Link selectedFlashBottom: string; // 使用 @Link 接收父组件的状态
  @Link selectedFBname:string;
  @Link isShow: boolean; // 使用 @Link 接收父组件的状态

  flash_bottoms: Flash_Bottoms[] = [
    { name: "反光", image_res: ('app.media.flash_bottom_reflect') },
    { name: "银葱", image_res: ('app.media.flash_bottom_brushed_silver_onion') },
    { name: "亮银", image_res: ('app.media.flash_bottom_light_silver') },
    { name: "珠光", image_res: ('app.media.flash_back_pearl') },
    { name: "拉丝银葱", image_res: ('app.media.flash_bottom_dumb_silver') },
    { name: "金葱", image_res: ('app.media.flash_bottom_brushed_golden_onion') },
    { name: "幻彩珠光", image_res: ('app.media.flash_bottom_iridescent_pearl') },
    { name: "幻彩拉丝", image_res: ('app.media.flash_bottom_iridescent_brushed_wire') },
    { name: "幻彩白葱", image_res: ('app.media.flash_bottom_iridescent_white_onion') },
  ];

  build() {
    Column() {
      Button('不使用覆膜')
        .buttonStyle(ButtonStyleMode.TEXTUAL)
        .width('100%')
        .onClick(() => {
          this.selectedFlashBottom = ("app.media.flash_bottom_original"); // 更新父组件的状态
          this.selectedFBname = '无';
          this.isShow = false; // 关闭选择面板
        })

      Column() {
        Grid() {
          ForEach(this.flash_bottoms, (item: Flash_Bottoms, index: number) => {
            GridItem() {
              Column() {
                Image($r(item.image_res))
                  .width(64)
                Text(item.name)
              }
            }.backgroundColor('#f5f5f5')
            .padding(5)
            .borderRadius(32)
            .onClick(() => {
              this.selectedFlashBottom = item.image_res; // 更新父组件的状态
              this.selectedFBname = item.name
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