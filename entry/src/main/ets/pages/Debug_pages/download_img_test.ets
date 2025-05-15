import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import util from '@ohos.util';
import fs from '@ohos.file.fs';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct ImageDownloader {
  @State url: string = "https://goods-creator-data.oss-cn-hangzhou.aliyuncs.com/images/temp_images/10_mod.jpg"; // 示例图片URL

  build() {
    Column() {
      Text(this.url).margin(10);
      Button("下载到Cache")
        .onClick(() => this.downloadToCache(this.url))
        .margin(10)
        .padding(10)
        .border({ width: 1, color: "#ccc" })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  // 下载并保存到Cache目录
  downloadToCache(imgUrl: string) {
    http.createHttp().request(imgUrl, (error, data) => {
      if (error) {
        promptAction.showToast({message:`下载失败: ${error.message}`});
        return;
      }
      if (!(data.result instanceof ArrayBuffer)) {
        promptAction.showToast({message:"数据格式不支持"});
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
              promptAction.showToast({message:`保存成功：${filePath}`});
              console.info("Cache路径：", filePath);
            })
        })
    });
  }
}