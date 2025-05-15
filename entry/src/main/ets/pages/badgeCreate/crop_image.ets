import * as buttons from "../../page_compolents/buttons"
import {cropImgUpload} from "../../page_compolents/imgUpload"
import { router } from '@kit.ArkUI'
import Badge from '../../class/Badge'
import { CropModel, CropView } from '@xinyansoft/oh-crop';
import { image } from '@kit.ImageKit';
import fs from '@ohos.file.fs';
import { http } from '@kit.NetworkKit';
import util from '@ohos.util';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct crop_image {
  @StorageLink('badge_create') badge_create:Badge = { } as Badge
  @StorageLink('taskid') taskid:string = ''
  @StorageLink('uid') uid:string = ''
  @State private model: CropModel = new CropModel()
    .setFrameWidth(1000)
    .setEllipseFrame(true)
    .setFrameRatio(1)
  @State private cropUri?: string = undefined;
  @State private imageUrl: string = this.badge_create.modified_url
  @State filePath: string = '';
  @State isButtonenabled: boolean =true;

  private updateModel(src: string) {
    this.model.setImage(src)
      .setFrameWidth(1000)
      .setEllipseFrame(true)
      .setFrameRatio(1);
  }

  onBackPress(): boolean {
    // 返回 true 表示拦截返回事件，阻止默认行为
    return true;
  }

  aboutToAppear(): void {
    this.downloadAndCropImage()
    this.refreshInterval = setInterval(() => {
      this.refreshImage();
    }, 1000);
  }

  private refreshInterval: number | null = null;

  aboutToDisappear(): void {
    // 页面消失时清除定时任务
    if (this.refreshInterval) {
      clearInterval(this.refreshInterval);
    }
  }

  private refreshImage() {
    let timestamp = new Date().getTime();
    this.imageUrl = `${this.badge_create.modified_url}?t=${timestamp}`;
  }

  build() {
    Stack({alignContent:Alignment.TopStart}){
      Image($r("app.media.select_flash_back_backgroud")).expandSafeArea()
      Column(){
        Column(){
          buttons.back_button({ content: "上一步"}).alignSelf(ItemAlign.Start).padding({bottom:20}) .opacity(this.isButtonenabled ? 1 : 0.3)

          Text("柄图裁剪")
            .fontSize(36)
            .fontWeight(FontWeight.Bold)
            .alignSelf(ItemAlign.Start)
            .padding({bottom:20})
        }.width('100%')

        if (this.cropUri) {
          Image(this.cropUri)
            .layoutWeight(1)
            .objectFit(ImageFit.Contain)
            .width('100%')
            .borderRadius(1000)

        } else {
          CropView({
            model: this.model
          })
            .width('100%')
            .aspectRatio(1)
        }

        buttons.confirm_button()
          .onClick(async ()=>{
            this.isButtonenabled =false
            const  uri = await this.crop() as string;
            await cropImgUpload(uri,this.taskid)
            let timestamp = new Date().getTime();
            this.badge_create.modified_url = `${ this.badge_create.modified_url}?t=${timestamp}`
            this.isButtonenabled = true
            router.pushUrl({ url: 'pages/badgeCreate/choose_cover_film' })
          })
          .enabled(this.isButtonenabled ? true : false)
          .opacity(this.isButtonenabled ? 1 : 0.3)


      }
      .padding({left:20,right:20})
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }


  }
  private async downloadAndCropImage() {
    if (!this.imageUrl) {
      promptAction.showToast({ message: '请输入有效的图片URL' });
      return;
    }
    try {
      let filePath = await this.downloadImage(this.imageUrl);
      if (filePath) {
        this.updateModel(filePath);
        this.cropUri = undefined;
      }
    } catch (error) {
      promptAction.showToast({ message: `下载图片失败: ${error}` });
    }
  }

  private async downloadImage(imgUrl: string): Promise<string | null> {
    return new Promise((resolve) => {
      http.createHttp().request(imgUrl, (error, data) => {
        if (error) {
          console.log(imgUrl)
          promptAction.showToast({ message: `下载失败: ${error.message}` });
          resolve(null);
          return;
        }
        if (!(data.result instanceof ArrayBuffer)) {
          promptAction.showToast({ message: "数据格式不支持" });
          resolve(null);
          return;
        }

        // 生成Cache目录路径
        const context = getContext();
        const cacheDir = context.cacheDir;
        const fileName = `${util.generateRandomUUID()}.png`; // 自动生成唯一文件名
        const filePath = `${cacheDir}/${fileName}`;

        // 写入文件
        fs.open(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
          .then(file => {
            fs.write(file.fd, data.result as ArrayBuffer)
              .then(() => {
                fs.close(file.fd);
                const fileUri = `file://${filePath}`;
                //promptAction.showToast({ message: `保存成功：${fileUri}` });
                console.info("Cache路径：", fileUri);
                this.filePath = fileUri;
                resolve(fileUri);
              })
              .catch((err: Error) => {
                console.error('文件写入失败', err);
                resolve(null);
              });
          })
          .catch((err: Error) => {
            console.error('文件打开失败', err);
            resolve(null);
          });
      });
    });
  }

  async crop() {
    if (this.cropUri) {
      return;
    }
    try {
      const pm = await this.model.crop();
      const uri = await this.packToFile(getContext(this), pm);
      return uri
    } catch (error) {
      promptAction.showToast({ message: `裁剪失败: ${error.message}` });
      return null
    }
  }

  async packToFile(context: Context, pixelMap: PixelMap): Promise<string> {
    const filename = this.getTimeStr()
    const fPath = `${context.cacheDir}/${filename}.png`;
    const writeFd = await fs.open(fPath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
    const opts: image.PackingOption = { format: 'image/png', quality: 100 };
    const imagePacker = image.createImagePacker();
    await imagePacker.packToFile(pixelMap, writeFd.fd, opts);
    fs.closeSync(writeFd.fd);
    this.cropUri = `file://${fPath}`
    return `internal://cache/${filename + '.' + 'png'}`
  }

  getTimeStr(): string {
    const now = new Date();
    return `${now.getFullYear()}${now.getMonth() + 1}${now.getDate()}_${now.getHours()}${now.getMinutes()}${now.getSeconds()}`;
  }

}

