import { BusinessError, request } from '@kit.BasicServicesKit';
import {PickerPhoto,FileUpload} from '../../page_compolents/image_update_to_oss';

@Entry
@Component
struct image_to_oss {
  @State uid: string = ''
  @State user_file_name: string = ''
  @State imgSrc: string | undefined = ''

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
      TextInput({placeholder:"请输入您的uid"})
        .onChange((content:string)=>{
          this.uid=content
        })
      TextInput({placeholder:"请输入徽章名"})
        .onChange((content:string)=>{
          this.user_file_name=content
        })
      Button("上传图片")
        .onClick(() => {
          if (this.imgSrc&&this.uid&&this.user_file_name) {

            const result = FileUpload(this.imgSrc,this.uid,this.user_file_name);

          } else {
            AlertDialog.show({
              title: "错误",
              message: '请将信息填完整!'
            })
            console.error('未选择图片');
          }
        })
    }
  }

}