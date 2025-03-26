import { BusinessError, request } from '@kit.BasicServicesKit';
import {PickerPhoto,FileUpload} from '../../page_compolents/file_update';

@Entry
@Component
struct ImageUploadPage {
  @State imgSrc: string | undefined = "app.media.iridescent_brushed.wire";

  build() {
    Column() {
      Button("点击选择图片")
        .onClick(async () => {
          try {
            const res = await PickerPhoto();
            if (res) {
              this.imgSrc = res;
              console.log('选择的图片 URI:', this.imgSrc);
            } else {
              console.error('未获取到有效的图片 URI');
            }
          } catch (error) {
            console.error('选择图片出错:', JSON.stringify(error));
          }
        })
      Image(this.imgSrc).width(200);
      Button("上传图片")
        .onClick(() => {
          if (this.imgSrc) {

            FileUpload(this.imgSrc);
          } else {
            console.error('未选择图片');
          }
        })
    }
  }

}