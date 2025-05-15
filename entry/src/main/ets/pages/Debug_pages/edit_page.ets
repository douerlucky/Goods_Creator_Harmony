import { CropModel, CropView } from '@xinyansoft/oh-crop';
import { image } from '@kit.ImageKit';
import fs from '@ohos.file.fs';
import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import util from '@ohos.util';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  @State private model: CropModel = new CropModel()
    .setFrameWidth(1000)
    .setEllipseFrame(true)
    .setFrameRatio(1);
  @State private cropUri?: string = undefined;
  @State private imageUrl: string = '';
  @State filePath: string = '';

  private updateModel(src: string) {
    this.model.setImage(src)
      .setFrameWidth(1000)
     .setEllipseFrame(true)
      .setFrameRatio(1);
  }

  build() {
    Column() {
      TextInput({ placeholder: '请输入网络图片URL' })
        .onChange((value) => {
          this.imageUrl = value;
        })
        .width('90%')
        .margin({ top: 20 })

      Button('下载并裁剪图片')
        .onClick(() => {
          this.downloadAndCropImage();
        })
        .width('90%')
        .margin({ top: 10 })

      //Image(this.filePath)

      if (this.cropUri) {
        Image(this.cropUri)
          .layoutWeight(1)
          .objectFit(ImageFit.Contain)
          .width('100%')
      } else {
        CropView({
          model: this.model
        })
          .layoutWeight(1)
          .width('100%')
      }

      Divider()
      Button('确定裁剪')
        .onClick(() => {
          this.crop();
        })
        .width('90%')
        .margin({ bottom: 20 })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 20, right: 20 })
  }

  private async downloadAndCropImage() {
    if (!this.imageUrl) {
      promptAction.showToast({ message: '请输入有效的图片URL' });
      return;
    }
    try {
      const filePath = await this.downloadImage(this.imageUrl);
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
        const fileName = `${util.generateRandomUUID()}.jpg`; // 自动生成唯一文件名
        const filePath = `${cacheDir}/${fileName}`;

        // 写入文件
        fs.open(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
          .then(file => {
            fs.write(file.fd, data.result as ArrayBuffer)
              .then(() => {
                fs.close(file.fd);
                const fileUri = `file://${filePath}`;
                promptAction.showToast({ message: `保存成功：${fileUri}` });
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
      await this.packToFile(getContext(this), pm);
    } catch (error) {
      promptAction.showToast({ message: `裁剪失败: ${error.message}` });
    }
  }

  async packToFile(context: Context, pixelMap: PixelMap): Promise<void> {
    const fPath = `${context.cacheDir}/${this.getTimeStr()}.jpg`;
    const writeFd = await fs.open(fPath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
    const opts: image.PackingOption = { format: 'image/jpeg', quality: 100 };
    const imagePacker = image.createImagePacker();
    await imagePacker.packToFile(pixelMap, writeFd.fd, opts);
    fs.closeSync(writeFd.fd);
    this.cropUri = `file://${fPath}`;
  }

  getTimeStr(): string {
    const now = new Date();
    return `${now.getFullYear()}${now.getMonth() + 1}${now.getDate()}_${now.getHours()}${now.getMinutes()}${now.getSeconds()}`;
  }
}
