import * as buttons from '../../page_compolents/buttons'
import { PickerPhoto,FileUpload,search_ai_paintings} from '../../page_compolents/AI_Paintings_to_oss'
import http from '@ohos.net.http';
import axios, { AxiosResponse } from '@ohos/axios';
import prompt from '@system.prompt';
import Badge from '../../class/Badge'

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
  baseURL: 'http://120.55.76.15:3500/api/ai/text2img',
  timeout: 60000,
  headers: {
    'content-type': 'application/json'
  }
});

@Entry
@Component
struct Upload_picture {
  @StorageLink('badge_create') badge_create:Badge = { } as Badge
  @State imgSrc:string  = ""
  @State prompt:string = "随机帮我生成动漫图像"
  @State isButtonDisabled: boolean = false;
  @State handlePopup: boolean = false
  @State uid:string='1'
  @State isShow: boolean = false

  @Builder select_sheet() {
    Select_AI_Paintings({
      selectedimg: $imgSrc, // 使用 @Link 传递状态
      isShow: $isShow, // 使用 @Link 传递状态
      uid: $uid
    })
  }

  build() {
    Stack() {
      Image($r("app.media.select_flash_back_backgroud")).expandSafeArea()
      Column({ space: 20 }) {
        buttons.back_button().alignSelf(ItemAlign.Start)
        Blank().height(20)
        Text("上传柄图")
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .alignSelf(ItemAlign.Start)
        Column() {
          Image(this.imgSrc=='' ? $r("app.media.image_blank"):this.imgSrc ).width(256)
            .borderRadius(16)
            .width(256)
            .aspectRatio(1)
        }
        Row() {
          Image($r('app.media.ai_ass')).height(22)
          TextInput({placeholder:"输入一段描述，让AI生成图像！"})
            .width(200)
            .fontSize(12)
            .placeholderFont({ size :12 })
            .backgroundColor('#f5f5f5')
            .padding({left:10,right:5})
            .onChange((content:string)=>{
              this.prompt = content
            })
          Button(this.isButtonDisabled ? '生成中...' : '立即绘制')
            .fontSize(10)
            .width(60)
            .height(25)
            .padding({left:0,right:0})
            .enabled(this.isButtonDisabled ? false : true)
            .onClick(async () => { // 改为异步函数
              this.handleSubmit()
            })
        }
        .padding({left:15})
        .width('90%')
        .height(34)
        .backgroundColor('#f5f5f5')
        .borderRadius(16)
        .alignItems(VerticalAlign.Center)
        Column() {
          Image($r('app.media.photo_galaary')).width(42)
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
          this.handlePopup = !this.handlePopup
        }).bindPopup(this.handlePopup, {
          message: '选择图片源路径',
          placementOnTop: true,
          showInSubWindow: false,
          primaryButton: {
            value: '选择手机相册图片',
            action: async () => {
              const res = await PickerPhoto()
              this.imgSrc = res
              console.log(this.imgSrc)
              this.handlePopup = !this.handlePopup
              console.info('confirm Button click')
            }
          },
          // 第二个按钮
          secondaryButton: {
            value: '选择之前AI绘制过的图片',
            action: () => {
              this.handlePopup = !this.handlePopup
              this.isShow = true // 打开模态选择器
              console.info('cancel Button click')
            }
          },
          onStateChange: (e) => {
            console.info(JSON.stringify(e.isVisible))
            if (!e.isVisible) {
              this.handlePopup = false
            }
          }
        })
        .bindSheet($$this.isShow, this.select_sheet(), {
          detents: [SheetSize.MEDIUM, SheetSize.LARGE, 350],
          title: { title: "选择一个图像" }
        })
        buttons.next_step_button()
          .onClick(()=>{
            this.badge_create.img_url=this.imgSrc
          })
      }.width('100%')
      .height('100%')
      .padding({ left: 20, right: 20 })
    }

  }

  private async handleSubmit() {
    if(this.isButtonDisabled==true)
    {
      prompt.showToast({message:"图像正在生成中......"})
      return
    }
    if (!this.prompt.trim()) {
      prompt.showToast({ message: '请输入有效的描述文字' });
      return;
    }

    this.isButtonDisabled = true;

    try {
      // 提交生成请求
      const payload: Text2ImgRequest = {
        prompt: this.prompt
      };

      const response: AxiosResponse<Text2ImgResponse> = await instance.post(
        '/post',
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
          '/checkStatus',
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

        //this.progressText =status.toString();

        if (status == 5) {
          this.imgSrc = imageUrl || '';
          clearInterval(intervalId);
          this.isButtonDisabled = false;
          FileUpload(this.imgSrc,this.uid)
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
          this.imgSrc = imageUrl;
        }

      } catch (error) {
        console.error('状态轮询失败:', error);
        prompt.showToast({ message: '获取任务状态失败，请重试' });
        clearInterval(intervalId);
        this.isButtonDisabled = false;
      }
    }, 3000);
  }

}


interface Query_Contents {
  AI_pid:number
  url: string;
}

@Component
struct Select_AI_Paintings {
  @Link selectedimg:string; // 使用 @Link 接收父组件的状态
  @Link isShow: boolean; // 使用 @Link 接收父组件的状态
  @Link uid:string;
  @State query_content: Query_Contents[] = [];

  build() {
    Scroll() {
      Grid() {
        ForEach(this.query_content, (item: Query_Contents) => {
          GridItem() {
            Column({ space: 5 }) {
              Image(item.url)
                .width(128)
                .borderRadius(16)
                .aspectRatio(1)
              }.onClick(()=>{
                this.selectedimg=item.url
                this.isShow=false
              console.log(this.selectedimg)
            })
            }
          });
      }
      .columnsTemplate('1fr 1fr')
      .width('100%')
      .height('100%')
      .rowsGap(10)
      .columnsGap(10);
    }.width('90%')
    .height('100%');

  }
  // 组件初始化时加载历史图片
  aboutToAppear() {
    this.loadImages();
  }

  private async loadImages() {
    try {
      const urls = await search_ai_paintings(this.uid); // 替换为实际的uid
      this.query_content = urls;
    } catch (error) {
      console.error('加载历史图片失败:', error);
      prompt.showToast({ message: '加载历史图片失败' });
    }
  }


}