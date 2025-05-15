import * as buttons from '../../page_compolents/buttons'
import { PickerPhoto,FileUpload,search_upload_images,LocalFileUpload,
  checkUploadStatus} from '../../page_compolents/imgUpload'
import axios, { AxiosResponse } from '@ohos/axios';
import prompt from '@system.prompt';
import Badge from '../../class/Badge'
import { router } from '@kit.ArkUI';
import {updateTaskImages} from '../../page_compolents/badgeTask'
import { deleteUploadImage } from '../../page_compolents/deleteImage';
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
  @StorageLink('taskid') taskid: string = ''
  @StorageLink('uid') uid: string = ''
  @State imgSrc: string = ""
  @State prompt: string = "随机帮我生成动漫图像"
  @State isButtonDisabled: boolean = false;
  @State handlePopup: boolean = false
  @State isShow: boolean = false

  @Builder
  select_sheet() {
    Search_upload_images({
      selectedimg: $imgSrc, // 使用 @Link 传递状态
      isShow: $isShow, // 使用 @Link 传递状态
      uid: $uid
    })
  }

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
          Button(this.isButtonDisabled ? '生成中...' : '立即绘制')
            .fontSize(10)
            .width(60)
            .height(25)
            .padding({ left: 0, right: 0 })
            .enabled(this.isButtonDisabled ? false : true)
            .onClick(async () => { // 改为异步函数
              this.handleSubmit()
            })
        }
        .padding({ left: 15 })
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
        .enabled(this.isButtonDisabled ? false : true)
        .onClick(async () => {
          this.handlePopup = !this.handlePopup
        })
        .bindPopup(this.handlePopup, {
          message: '选择图片源路径',
          placementOnTop: true,
          showInSubWindow: false,
          primaryButton: {
            value: '选择手机相册图片',
            action: async () => {
              const res = await PickerPhoto();
              if (res == undefined) {
                return
              }
              this.isButtonDisabled = true
              await LocalFileUpload(res, this.uid); // 等待上传完成后再继续
              this.imgSrc = await checkUploadStatus(this.uid); // 只有上传成功才查询状态
              console.log("现在的图片", this.imgSrc);
              this.handlePopup = !this.handlePopup;
              this.isButtonDisabled = false
            }
          },
          // 第二个按钮
          secondaryButton: {
            value: '选择之前上传过的图片',
            action: () => {
              this.handlePopup = !this.handlePopup
              this.isShow = true // 打开模态选择器
              //    console.info('cancel Button click')
            }
          },
          onStateChange: (e) => {
            //  console.info(JSON.stringify(e.isVisible))
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
          .enabled(this.imgSrc != '' ? true : false)
          .onClick(async () => {
            console.log("照片元:", this.imgSrc)
            console.log(`taskid${this.taskid},ori_url${this.imgSrc}`)
            this.badge_create.oriImg_url = await updateTaskImages(this.taskid, this.imgSrc)
            this.badge_create.modified_url = this.badge_create.oriImg_url
            router.pushUrl({
              url: "pages/badgeCreate/image_edit"
            })
          })
          .enabled(!this.isButtonDisabled)
          .opacity(this.isButtonDisabled ? 0.3 : 1)


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


interface Query_Contents {
  iid:number
  url: string;
}

@Component
struct Search_upload_images {
  @Link selectedimg:string; // 使用 @Link 接收父组件的状态
  @Link isShow: boolean; // 使用 @Link 接收父组件的状态
  @Link uid:string;
  @State query_content: Query_Contents[] = [];

  @Builder
  MenuBuilder(iid: number,iurl:string) {
    Column() {
      Button("确认删除")
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.Red)
        .buttonStyle(ButtonStyleMode.TEXTUAL)
        .onClick(() => {
          this.showDeleteDialog(iid,iurl);
        });
    }
  }
  private showDeleteDialog(iid: number,iurl:string) {
    const dialog: AlertDialogParamWithConfirm = {
      title: "确认删除",
      message: "您确定要删除此项吗？",
      confirm: {
        value: "确定",
        action: async () => {
          await deleteUploadImage(iid)
          if(this.selectedimg == iurl)
            this.selectedimg = ''
          prompt.showToast({ message: "已删除" });
          await this.loadImages(); // ✅ 删除后刷新图片列表
        }
      },
      cancel: () => {
        // 取消删除操作
        prompt.showToast({ message: "已取消删除" });
      }
    };
    AlertDialog.show(dialog);
  }

  build() {
    Scroll() {
      if(this.query_content.length==0)
      {
        Text("还没有上传文件哦，请先上传或生成图片")
      }
      else
      {
        Grid() {
          ForEach(this.query_content, (item: Query_Contents) => {
            GridItem() {
              Column({ space: 5 }) {
                Image(item.url)
                  .width(128)
                  .borderRadius(16)
                  .aspectRatio(1)
                  .draggable(false)
              }.onClick(() => {
                this.selectedimg = item.url
                this.isShow = false
                //console.log(this.selectedimg)
              }).bindContextMenu(this.MenuBuilder(item.iid,item.url), ResponseType.LongPress);

            }
          })
        }
        .columnsTemplate('1fr 1fr')
        .width('100%')
        .height('100%')
        .rowsGap(10)
        .columnsGap(10);
      }

    }.width('90%')
    .height('100%');

  }
  // 组件初始化时加载历史图片
  aboutToAppear() {
    console.log("现在的id是",this.uid)
    this.loadImages();

  }

  private async loadImages() {
    try {
      const urls = await search_upload_images(this.uid); // 替换为实际的uid
      this.query_content = urls;
    } catch (error) {
      console.error('加载历史图片失败:', error);
      prompt.showToast({ message: '加载历史图片失败' });
    }
  }


}