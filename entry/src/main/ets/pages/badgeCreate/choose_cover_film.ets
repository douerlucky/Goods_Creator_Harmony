import * as buttons from "../../page_compolents/buttons"
import { router } from '@kit.ArkUI'
import Badge from '../../class/Badge'

const scale =3.5

@Entry
@Component
struct Choose_Cover_Film {
  @StorageLink('badge_create') badge_create:Badge = {specification:56 } as Badge
  @State now_film_cover: string = "film_cover_original"
  @State now_fc_name:string = '无'
  @State isShow: boolean = false
  @StorageLink('taskid') taskid:string = ''
  @StorageLink('uid') uid:string = ''
  @State now_img:string = "" //原始图像

  @Builder select_sheet() {
    select_Film_Cover({
      selectedFilmCover: $now_film_cover, // 使用 @Link 传递状态
      selectedFCname: $now_fc_name,
      isShow: $isShow // 使用 @Link 传递状态
    })
  }

  private refreshInterval: number | null = null;
  aboutToAppear(): void {
    // 启动定时刷新任务
    this.refreshInterval = setInterval(() => {
      this.refreshImage();
    }, 1000);
  }

  aboutToDisappear(): void {
    // 页面消失时清除定时任务
    if (this.refreshInterval) {
      clearInterval(this.refreshInterval);
    }
  }

  private refreshImage() {
    let timestamp = new Date().getTime();
    this.now_img = `${this.badge_create.modified_url}?t=${timestamp}`;
  }

  build() {
    Stack() {
      Image($r("app.media.select_flash_back_backgroud")).expandSafeArea()
      Column({ space: 20 }) {
        Column()
        {
        buttons.back_button({ content: "上一步" ,isdouble:true}).alignSelf(ItemAlign.Start)
        Blank()
          .height(20)

          Text("选择覆膜")
            .fontSize(36)
            .fontWeight(FontWeight.Bold)
            .alignSelf(ItemAlign.Start)
        }.width('100%')

        Column() {
          Stack()
          {
            // 闪底图片
            Image($r(this.badge_create.flash_bottom))
              .width(this.badge_create.specification *scale )
              .aspectRatio(1)
              .clipShape(new Circle({ width:this.badge_create.specification * scale ,height:this.badge_create.specification * scale })) // 圆形裁剪
              .width(this.badge_create.specification * scale)
              .aspectRatio(1)
              .clipShape(new Circle({ width:this.badge_create.specification * scale,height:this.badge_create.specification * scale })) // 圆形裁剪
            // 底层图片（原始图像）
            Image(this.now_img)
              .width(this.badge_create.specification *scale )
              .aspectRatio(1)
              .clipShape(new Circle({ width:this.badge_create.specification * scale ,height:this.badge_create.specification * scale })) // 圆形裁剪
              .width(this.badge_create.specification * scale)
              .aspectRatio(1)
              .clipShape(new Circle({ width:this.badge_create.specification * scale,height:this.badge_create.specification * scale })) // 圆形裁剪
            // 遮罩层（覆膜效果）
              Image($r(this.now_film_cover))
                .width(this.badge_create.specification * scale)
                .aspectRatio(1)
                .clipShape(new Circle({  width:this.badge_create.specification * scale,height:this.badge_create.specification * scale   })) // 同形裁剪
                .opacity(1) // 50% 透明度，可根据效果调整
                .blendMode(BlendMode.DARKEN) // 混合模式（可选：Screen、Overlay 等）

          }
        }
        .width('100%')
        .height(350)
        .onClick(() => {
          this.isShow = true
        })
        .bindSheet($$this.isShow, this.select_sheet(), {
          detents: [SheetSize.MEDIUM, SheetSize.LARGE, 350],
          title: { title: "选择一个覆膜种类" }
        })

        buttons.next_step_button()
          .onClick(()=>{

            this.badge_create.film_cover = this.now_film_cover
            this.badge_create.fc_name = this.now_fc_name
            router.pushUrl({ url: 'pages/badgeCreate/choose_interaction' })

          })


      }.width('100%')
      .height('100%')
      .padding({ left: 20, right: 20 })
      .justifyContent(FlexAlign.SpaceBetween)
    }
  }
}

interface Film_Covers {
  name: string
  image_res: string
}

@Component
struct select_Film_Cover {
  @Link selectedFilmCover: string; // 使用 @Link 接收父组件的状态
  @Link selectedFCname:string
  @Link isShow: boolean; // 使用 @Link 接收父组件的状态

  film_cover: Film_Covers[] = [
    { name: "珠光膜", image_res: ('app.media.film_cover_pearl') },
    { name: "十字镭射膜", image_res: ('app.media.film_cover_cross_razer') },
    { name: "哑膜", image_res: ('app.media.film_cover_dump') },
    { name: "触感膜", image_res: ('app.media.film_cover_touch') },
    { name: "碎玻璃膜", image_res: ('app.media.film_cover_glass') },
    { name: "镭射膜", image_res: ('app.media.film_cover_razer') },
  ];

  build() {
    Column() {
      Button('不使用闪底')
        .buttonStyle(ButtonStyleMode.TEXTUAL)
        .width('100%')
        .onClick(() => {
          this.selectedFilmCover = ("app.media.film_cover_original"); // 更新父组件的状态
          this.selectedFCname = '无'
          this.isShow = false; // 关闭选择面板
        })

      Column() {
        Grid() {
          ForEach(this.film_cover, (item:Film_Covers, index: number) => {
            GridItem() {
              Column() {
                Image($r(item.image_res))
                  .width(64)
                Text(item.name)
              }
            }.backgroundColor('#f5f5f5')
            .padding(5)
            .borderRadius(32)
            .onClick(() => {
              this.selectedFilmCover = item.image_res; // 更新父组件的状态
              this.selectedFCname = item.name
              this.isShow = false; // 关闭选择面板
            })
          })
        }
        .width('100%')
        .columnsTemplate('1fr 1fr 1fr')
        .columnsGap(20)
        .rowsGap(20)
        .padding(5)
        Blank().height(100)
      }
    }.width('100%')
    .padding({ left: 20, right: 20 })
  }
}