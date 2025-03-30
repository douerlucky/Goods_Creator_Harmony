import axios, { AxiosResponse } from '@ohos/axios';
import prompt from '@system.prompt';

// 定义请求参数接口
interface Text2ImgRequest {
  prompt: string;
}

interface CheckStatusRequest {
  generateUuid: string;
}
// 定义响应数据接口

interface Data_Text2Img {
  generateUuid: string;
}

interface Text2ImgResponse {
  data: Data_Text2Img;
  message: string;
}

interface Images{
  "imageUrl":string
}

interface Data_Check{
  generateStatus:number;// 0:queued, 1:processing, 5:finished
  images: Array<Images>;
  generateUuid: string;
}

interface CheckStatusResponse {
  code: number;
  data: Data_Check;
  msg: string;
}

// 配置服务实例
const instance = axios.create({
  baseURL: 'http://120.55.76.15:3500',
  timeout: 60000,
  headers: {
    'content-type': 'application/json'
  }
});

@Entry
@Component
struct TouchStationAIPaintingDemo {
  @State inputText: string = '';
  @State progressText: string = '等待生成';
  @State imageUrl: string = '';
  @State showImage: boolean = false;
  @State isButtonDisabled: boolean = false;

  build() {

    Column({ space: 20 }) {
      // 输入框和提交按钮区域
      Row({ space: 10 }) {
        TextInput({ placeholder: "请输入你要生成的图片描述" })
          .onChange((value: string) => this.inputText = value)
          .width('70%')
          .padding(10)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)

        Button(this.isButtonDisabled ? '生成中...' : '生成')
          .width('30%')
          .onClick(() => this.handleSubmit())
          .backgroundColor(this.isButtonDisabled ? '#CCCCCC' : '#409EFF')
          .padding(10)
          .borderRadius(8)
      }

      // 进度显示和图片展示区域
      Column({ space: 10 }) {
        Text(this.progressText)
          .fontSize(16)

        if (this.showImage) {
          Image(this.imageUrl)
            .width(256)
            .height(256)
            .borderRadius(8)
        }
      }



    }
    .padding({ top: 50, left: 20, right: 20 })
  }

  private async handleSubmit() {
    if(this.isButtonDisabled==true)
    {
      prompt.showToast({message:"图像正在生成中......"})
      return
    }
    if (!this.inputText.trim()) {
      prompt.showToast({ message: '请输入有效的描述文字' });
      return;
    }

    this.resetState();
    this.isButtonDisabled = true;

    try {
      // 提交生成请求
      const payload: Text2ImgRequest = {
        prompt: this.inputText
      };

      const response: AxiosResponse<Text2ImgResponse> = await instance.post(
        '/api/ai/text2img/post',
        payload
      );

      const generateUuid = response.data.data.generateUuid;
      prompt.showToast({ message: '正在生成中...' });

      console.log(generateUuid)

      // 开始轮询
      await this.pollTaskStatus(generateUuid);

    } catch (error) {
      console.error('请求失败:', error);
      prompt.showToast({ message: '网络请求失败，请检查网络连接' });
      this.isButtonDisabled = false;
    }
  }

  private async pollTaskStatus(generateUuid: string) {
    let lastState: string | null = null;
    const intervalId = setInterval(async () => {
      try {
        // 显式创建请求体并序列化
        const payload: CheckStatusRequest = {
          generateUuid: generateUuid
        };

        console.log('发送的状态查询请求体:', JSON.stringify(payload));

        const response: AxiosResponse<CheckStatusResponse> = await instance.post(
          '/api/ai/text2img/checkStatus',
          JSON.stringify(payload),
          { headers: { 'Content-Type': 'application/json' } }
        );

        let code:number = response.data.code;
        if (code!== 0) {
          prompt.showToast({ message:  '查询失败' });
          return;
        }

        // 状态映射
        const status = response.data.data.generateStatus;
        const imageUrl = response.data.data.images[0]?.imageUrl || null;

        this.progressText =status.toString();

        if (status == 5) {
          this.imageUrl = imageUrl || '';
          this.showImage = true;
          clearInterval(intervalId);
          this.isButtonDisabled = false;
        } else if (status == 0) {
          clearInterval(intervalId);
          this.isButtonDisabled = false;
        }
        else if(status == 2)
        {
          console.log("图像正在生成中......")
          this.isButtonDisabled = true;

        }
        else if (imageUrl) {
          this.imageUrl = imageUrl;
          this.showImage = true;
        }

      } catch (error) {
        console.error('状态轮询失败:', error);
        prompt.showToast({ message: '获取任务状态失败，请重试' });
        clearInterval(intervalId);
        this.isButtonDisabled = false;
      }
    }, 3000);
  }


  private resetState() {
    this.showImage = false;
    this.progressText = '等待生成';
    this.imageUrl = '';
  }
}