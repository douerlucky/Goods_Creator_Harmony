import http from '@ohos.net.http';

interface ImageResponse {
  images: string[];
}

@Entry
@Component
struct Index {
  @State imageUrls: string[] = []

  aboutToAppear() {
    this.fetchImages()
  }

  build() {
    Column({ space: 50 }) {
      Button("显示图片").onClick(() => {
        this.fetchImages()
      })
      //Image("https://goods-creator-image-test.oss-cn-hangzhou.aliyuncs.com/test.png")
      // 展示图片
      ForEach(this.imageUrls, (url: string) => {
        Image(url)
          .width('100%')
          .height(200)
      }, (url: string) => url)
    }
    .width('100%')
  }

  // 调用后端 API 获取图片 URL
  async fetchImages() {
    const that = this; // 保存 this 引用
    try {
      // 创建 HTTP 请求对象
      const httpRequest = http.createHttp();
      httpRequest.request(
        'http://120.27.132.232:3200/api/show_images',
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json'
          }
        },
        (err, response) => {
          if (!err) {
            try {
              // 使用明确的类型来解析 JSON 数据
              const data: ImageResponse = JSON.parse(response.result.toString());
              console.log('Response data:', data); // 输出响应数据，方便调试
              // 使用保存的 this 引用更新 @State 变量
              that.imageUrls = data.images;
              console.log("获取成功");
            } catch (parseError) {
              console.error('Error parsing JSON:', parseError);
            }
          } else {
            console.error('Error fetching images:', err);
          }
        }
      );
    } catch (error) {
      console.error('Error fetching images:', error);
    }
  }
}