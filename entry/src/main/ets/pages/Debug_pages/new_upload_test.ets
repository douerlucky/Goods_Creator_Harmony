import { NavBar, ImageUploader, ImageBean, UploadImage } from '@peakmain/library/Index';

@Entry
@Component
struct PkLoaderPage{
  @State
  imgBean: ImageBean[] = []
areaHeight: number = 0

  async submit()
  {
    const result = await UploadImage(this.imgBean, 'http://120.55.76.15:3100/api/upload-image/to_oss/fromLocal', )
    let tmp: string[] = []
    tmp = result.map(url => {
      return url.url
    })
    AlertDialog.show({
      message: `上传图片后的结果:${tmp}`
    })
  }

  build(){
    Column(){
      NavBar({
        title: "ImageLoader图片上传"
      })
      ImageUploader({
        title: '文件预览',
        canUpload: true,
        imgBean: this.imgBean,
        maxSelectNumber: 3,
        onSelectImageChange: (bean: ImageBean[]) => {
          this.imgBean = bean
        },
      })
        .layoutWeight(1)

      Button("提交", { type: ButtonType.Capsule })
        .fontColor(Color.White)
        .fontSize(16)
        .height(50)
        .width(125)
        .onClick(() => {
          this.submit()
        })

    }
    .height("100%")
  }
}