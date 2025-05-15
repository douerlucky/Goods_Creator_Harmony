import {AVPlayerDemo} from './audio_test'
@Entry
@Component
struct Video_test {
  private controller: VideoController = new VideoController()
  private videoSrc: string = 'https://goods-creator-data.oss-cn-hangzhou.aliyuncs.com/videos/dynamic_badge/test.mp4' // 使用时请替换为实际视频加载网址
  @State isVideoVisible: boolean = true // 新增状态变量，控制视频的显示与隐藏

  build() {
    Column() {
      if (this.isVideoVisible) {
        Video({
          src: this.videoSrc,
          controller: this.controller
        })
          .size({ width: 100 * 3.5, height: 100 * 3.5 })
          .clipShape(new Circle({ width: 100 * 3.5, height: 100 * 3.5 })) // 圆形裁剪
          .muted(true) // 设置是否静音
          .controls(false) // 设置是否显示默认控制条
          .autoPlay(true) // 设置是否自动播放
          .loop(false) // 设置是否循环播放
          .objectFit(ImageFit.Fill) // 设置视频适配模式
          .onFinish(() => {
            this.isVideoVisible = false // 视频播放完毕后隐藏视频
            this.controller.pause() // 停止播放
          })
      }
      Button("暂停/播放/显示/隐藏")
        .onClick(() => {
          if (this.isVideoVisible) {
            this.controller.pause() // 暂停播放
          } else {
            this.controller.start() // 开始播放
            let audio = new AVPlayerDemo
            audio.avPlayerLiveDemo()
          }
          this.isVideoVisible = !this.isVideoVisible // 切换视频的显示与隐藏状态

        })
      Button("音频")

    }
    .height('100%')
    .width('100%')
  }

}
