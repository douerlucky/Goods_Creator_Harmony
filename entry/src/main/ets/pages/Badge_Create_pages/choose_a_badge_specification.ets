import * as buttons from "../../page_compolents/buttons";
// 修正路由导入方式
import router from '@ohos.router';
import Badge from '../../class/Badge'

let badge = new Badge()

AppStorage.setOrCreate('badge_create',badge)

@Entry
@Component
struct choose_a_badge_specification {
  @StorageLink('badge_create') badge_create:Badge = { } as Badge
  @State specification: number = 58
  dialogController: CustomDialogController = new CustomDialogController({
    builder: MyCustomDialog({
      title: '调整自定义吧唧规格(单位为mm)',
      specification: $specification
    })
  })

  build() {
    Stack() {
      Image($r("app.media.Choose_a_buget_specification_background")).expandSafeArea()

      Column({ space: 20 }) {
        buttons.back_button({ content: "主页" }).alignSelf(ItemAlign.Start)
        Blank()
          .height(20)
        Text("选择你想要创作的\n吧唧规格")
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
        buttons.big_button({
          title: "58mm",
          desc: "最常见的大小规格\n" +
            "大多数使用场景\n" +
            "大多数人的选择",
          image_source: $r("app.media.budget_of_58mm"),
        })
          .onClick(() => {
            console.log("click")

            this.badge_create.specification=58

            router.pushUrl({
              url: "pages/Badge_Create_pages/choose_flash_bottom"
            })
          })

        buttons.big_button({
          title: "75mm",
          desc: "更大的大小规格\n" +
            "适用于扎包",
          image_source: $r("app.media.budget_of_75mm")
        }).onClick(() => {
          this.badge_create.specification=75
          router.pushUrl({
            // 修正路由路径
            url: "pages/Badge_Create_pages/choose_flash_bottom",
          })
        })
        buttons.big_button({
          title: "自定义",
          desc: "不受限制\n" +
            "由你自己个性定义",
          image_source: $r("app.media.budget_of_DIY")
        })
          .onClick(() => {
            this.dialogController.open()
          })
      }.width('100%')
      .height('100%')
      .padding({ left: 20, right: 20 })
    }
  }
}

// 自定义弹窗组件
@CustomDialog
struct MyCustomDialog {
  @StorageLink('badge_create') badge_create:Badge = { } as Badge
  @Prop title: string = ''
  @Link specification: number
  controller: CustomDialogController = new CustomDialogController({ builder: null }) // 提供默认值

  build() {
    Column() {
      Text(this.title || "请输入内容")
        .fontSize(16)
        .margin(24)
        .padding({ left: 20 })
        .width("100%")

      Row() {
        Slider({
          value: this.specification, // 绑定滑动条的值
          min: 26, // 设置最低值
          max: 88, // 设置最高值
          step: 1, // 可选，设置步长
        }).width('80%')
          .onChange((newValue) => {
            // 当滑动条的值改变时，更新绑定的变量
            this.specification = newValue;
          })
        Blank().width(20)
        Text(this.specification.toString())
      }.width('80%')

      Flex({ justifyContent: FlexAlign.SpaceAround }) {
        Button('取消')
          .onClick(() => {
            if (this.controller) {
              this.controller.close()
            }
          })
          .backgroundColor(0xffffff)
          .fontColor(Color.Black)

        Button('确定')
          .onClick(() => {
            this.badge_create.specification=this.specification
            router.pushUrl({
              url: "pages/Badge_Create_pages/choose_flash_bottom",
            })
            if (this.controller) {
              this.controller.close()
            }
          })
          .backgroundColor(0xffffff)
          .fontColor(Color.Red)
      }
      .margin({ top: 10, bottom: 10 })
    }
  }
}