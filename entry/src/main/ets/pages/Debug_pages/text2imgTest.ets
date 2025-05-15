import * as buttons from '../../page_compolents/buttons'
import { PickerPhoto,FileUpload,search_upload_images,LocalFileUpload,
  checkUploadStatus} from '../../page_compolents/imgUpload'
import axios, { AxiosResponse } from '@ohos/axios';
import prompt from '@system.prompt';
import Badge from '../../class/Badge'
import * as server from '../../class/ServerKits'


// 定义请求参数接口
interface Text2ImgRequest {
  prompt: string;
}

interface GenerateResponse {
  success: boolean;
  imageUrl?: string;
  error?: string;
}

// 配置服务实例
const instance = axios.create({
  baseURL: `${server.postBaseUrl}${server.AIPort}`,
  timeout: 60000,
  headers: {
    'content-type': 'application/json'
  }
});

@Entry
@Component
struct Upload_picture {
  @StorageLink('badge_create') badge_create: Badge = {} as Badge
  @StorageLink('taskid') taskid: string = '4_1746348384066'
  @StorageLink('uid') uid: string = '4'
  @State imgSrc: string = ""
  @State prompt: string = "随机帮我生成动漫图像"
  @State isButtonDisabled: boolean = false;
  @State handlePopup: boolean = false
  @State isShow: boolean = false

  onBackPress(): boolean {
    // 返回 true 表示拦截返回事件，阻止默认行为
    return true;
  }

  build() {
    Stack() {
      Image($r("app.media.select_flash_back_backgroud")).expandSafeArea()
      Column({ space: 20 }) {
        Column() {
          buttons.back_button()
            .alignSelf(ItemAlign.Start)
            .padding({ bottom: 20 })
            .enabled(this.isButtonDisabled ? false : true)
            .opacity(this.isButtonDisabled ? 0.3 : 1)
          Text("上传柄图")
            .fontSize(36)
            .fontWeight(FontWeight.Bold)
            .alignSelf(ItemAlign.Start)
        }.width('100%')

        Column() {
          Image(this.imgSrc == '' ? $r("app.media.image_blank") : this.imgSrc).width(256)
            .borderRadius(16)
            .width(256)
            .aspectRatio(1)
            .id('generatedImg')
        }

        Row() {
          Image($r('app.media.ai_ass')).height(22)
          TextInput({ placeholder: "输入一段描述，让AI生成图像！" })
            .width(200)
            .fontSize(12)
            .placeholderFont({ size: 12 })
            .backgroundColor('#f5f5f5')
            .padding({ left: 10, right: 5 })
            .onChange((content: string) => {
              this.prompt = content
            })
            .id('promptInput')
          Button(this.isButtonDisabled ? '生成中...' : '立即绘制')
            .fontSize(10)
            .width(60)
            .height(25)
            .padding({ left: 0, right: 0 })
            .enabled(this.isButtonDisabled ? false : true)
            .onClick(async () => { // 改为异步函数
              this.handleSubmit()
            })
            .id('generateBtn')
        }
        .padding({ left: 15 })
        .width('90%')
        .height(34)
        .backgroundColor('#f5f5f5')
        .borderRadius(16)
        .alignItems(VerticalAlign.Center)
      }.width('100%')
      .height('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: 20, right: 20 })
    }

  }

  private async handleSubmit() {
    if (this.isButtonDisabled) {
      prompt.showToast({ message: "图像正在生成中......" });
      return;
    }
    // 增强 prompt 校验
    const trimmedPrompt = this.prompt.trim();
    if (trimmedPrompt.length < 3) {
      prompt.showToast({ message: '请输入至少3个字符的描述文字' });
      return;
    }

    const payload: Text2ImgRequest = {
      prompt: trimmedPrompt
    };

    this.isButtonDisabled = true;

    try {
      const response: AxiosResponse<GenerateResponse> = await instance.post(
        '/api/ai/text2img/generate',
        payload
      );

      if (response.data.success && response.data.imageUrl) {
        const oss_url = await FileUpload(response.data.imageUrl, this.uid);
        this.imgSrc = oss_url as string;
        prompt.showToast({ message: '图片生成成功' });
      } else {
        throw new Error(response.data.error || '图片生成失败');
      }

    } catch (error) {
      console.error('生成请求失败:', error.message);
      if (error.response?.status === 400) {
        const errorMessage =  '请求参数错误，请检查描述文字';
        prompt.showToast({ message: errorMessage });
      } else {
        prompt.showToast({ message: '网络请求失败，请检查网络连接' });
      }
    } finally {
      this.isButtonDisabled = false;
    }
  }
}

