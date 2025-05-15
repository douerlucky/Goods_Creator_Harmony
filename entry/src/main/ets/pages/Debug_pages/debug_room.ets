import { router } from '@kit.ArkUI';

@Entry
@Component
struct Debug_room {
  @State message: string = 'Hello World';
  build() {
    Column()
    {
      Button("网络测试").onClick(()=>{
        router.pushUrl({
          url:"pages/Debug_pages/Internet"
        })
      })
      Button("上传测试").onClick(()=>{
        router.pushUrl({
          url:"pages/Debug_pages/upload_test"
        })
      })
      Button("ECS测试").onClick(()=>{
        router.pushUrl({
          url:"pages/Debug_pages/Server_Test"
        })
      })
      Button("图片网络显示测试").onClick(()=>{
        router.pushUrl({
          url:"pages/Debug_pages/show_image_test"
        })
      })
      Button("图片上传到oss测试").onClick(()=>{
        router.pushUrl({
          url:"pages/Debug_pages/image_to_oss"
        })
      })
      Button("搜索测试").onClick(()=>{
        router.pushUrl({
          url:"pages/Debug_pages/search_badge_test"
        })
      })
      Button("海螺AI测试").onClick(()=>{
        router.pushUrl({
          url:"pages/Debug_pages/AI_image_painting_test"
        })
      })
      Button("图片编辑测试").onClick(()=> {
        router.pushUrl({
          url: "pages/Debug_pages/edit_page"
        })
      })
        Button("图片下载测试").onClick(()=> {
          router.pushUrl({
            url: "pages/Debug_pages/download_img_test"
          })
        })
      Button("图片裁剪测试").onClick(()=> {
        router.pushUrl({
          url: "pages/Debug_pages/croppage_test"
        })
      })
      Button("视频播放测试").onClick(()=> {
        router.pushUrl({
          url: "pages/Debug_pages/video_test"
        })
      })
      Button("吧唧互动化测试").onClick(()=> {
        router.pushUrl({
          url: "pages/Badge_Create_pages/choose_interaction"
        })
      })
      Button("shangchuan").onClick(()=> {
        router.pushUrl({
          url: "pages/Debug_pages/new_upload_test"
        })
      })
      }
    }
  }