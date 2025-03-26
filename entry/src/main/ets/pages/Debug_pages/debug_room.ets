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
    }
  }
}