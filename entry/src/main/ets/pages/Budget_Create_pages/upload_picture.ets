import * as buttons from '../../page_compolents/buttons'
import { PickerPhoto } from '../../page_compolents/file_update'
@Entry
@Component
struct Upload_picture {
  @State imgSrc:string | undefined = "app.media.image_blank"

  build() {
    Stack() {
        Image($r("app.media.select_flash_back_backgroud")).expandSafeArea()
      Column({ space: 20 }) {
        buttons.back_button()
          .alignSelf(ItemAlign.Start)
        Blank()
          .height(20)
        Text("上传柄图")
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .alignSelf(ItemAlign.Start)
        Column()
        {
          Image($r(this.imgSrc)).width(256)
        }
        Row()
        {
          Image($r('app.media.ai_ass'))
            .height(22)
          TextInput({placeholder:"输入一段描述，让AI生成图像！"})
            .layoutWeight(4)
            .fontSize(9)
            .placeholderFont({ size :9 })
            .backgroundColor('#f5f5f5')
          Button("立即绘制")
            .fontSize(7)
            .width(80)
            .height(25)
        }
        .padding({left:15})
        .width('90%')
        .height(34)
        .backgroundColor('#f5f5f5')
        .borderRadius(16)
        .alignItems(VerticalAlign.Center)
        Column() {
          Image($r('app.media.photo_galaary'))
            .width(42)
          Text("点击此处选择图片")
            .fontColor('#8F91AC')
            .fontSize(24)
        }
        .justifyContent(FlexAlign.Center)
        .borderWidth(3)
        .width('100%')
        .height(130)
        .borderStyle(BorderStyle.Dashed)
        .borderColor('#8F91AC')
        .borderRadius(16)
        .onClick(async () => {
          const res = await PickerPhoto()
          this.imgSrc = res
        })
        buttons.next_step_button()
      }.width('100%')
      .height('100%')
      .padding({ left: 20, right: 20 })


    }
  }
}

/*
海螺API Key
eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJHcm91cE5hbWUiOiJkb3Vlcl9sdWNreSIsIlVzZXJOYW1lIjoiZG91ZXJfbHVja3kiLCJBY2NvdW50IjoiIiwiU3ViamVjdElEIjoiMTg5NDYzOTgwNzk0Mjg5MDQ2OCIsIlBob25lIjoiMTMzNDM0NjA5MjIiLCJHcm91cElEIjoiMTg5NDYzOTgwNzkzNDUwMTc3MiIsIlBhZ2VOYW1lIjoiIiwiTWFpbCI6IiIsIkNyZWF0ZVRpbWUiOiIyMDI1LTAzLTAzIDIyOjA4OjQ4IiwiVG9rZW5UeXBlIjoxLCJpc3MiOiJtaW5pbWF4In0.E3i5WYeLqne5HlRqcTSWIb8x7yGvvXLWBGJASrkyN7M5wiaiRBgJw4kqWriB9i-V0js96zm-TZSnIqmowAFQ5WV0TDyc0j6w0Ir9T9E3XmUXR2O6XHGxZZ7sZVdW14_YEW5sDBoGdiGKPU94j6v_cb9Ze3Ljz1WKNZsYcAhcl_ZFyhBhBdrFZ-tV8FicbeH5O1cPhRqyuSLgzIAZAzDNef4WsWnu5wpJvWxKg0kItVJy14yBoyRnk-jSEYpm5YVRBiUtP03-R2TQlXG5V64twJdv368rNRkKjjE04PBCklAOuy8Hh1wXNRIDAuNLxcgHN1VE6ymwXo9P5RYIF95R7A
 */