class Badge {
  // 徽章的规格，默认值为 58
  public specification: number = 58;
  // 闪底的路径，默认指向 app.media.flash_bottom_original
  public flash_bottom: string = "app.media.flash_bottom_original";
  // 闪底的名称，默认值为 '无'
  public fb_name: string = '无';
  // 覆膜的路径，初始为空字符串
  public film_cover: string = "";
  // 覆膜的名称，默认值为 '无'
  public fc_name: string = '无';
  // 原始图片的 URL，初始为空字符串
  public oriImg_url: string = '';
  // 修改后图片的 URL，初始为空字符串
  public modified_url: string = '';
  // 歌词文件的 URL，初始为空字符串
  public lyric_url: string = '';
  // 歌词文件的名称，默认值为 '无'
  public lyric_name: string = '无';
  // 背景音乐文件的 URL，初始为空字符串
  public BGM_url: string = '';
  // 背景音乐文件的名称，默认值为 '无'
  public BGM_name: string = '';
  // 新增的歌词 ID，默认值为 -1
  public lid: number = -1;
  // 新增的 BGM ID，默认值为 -1
  public bgmid: number = -1;
  // 视频文件的 URL，初始为空字符串
  public video_url: string = '';
}

interface Updated_Badge {
  // 徽章的唯一标识符
  bid: number;
  // 用户的唯一标识符，表明该徽章属于哪个用户
  uid: number;
  // 徽章创建者的用户唯一标识符
  creator_uid: number;
  // 徽章创建者的用户名
  creator_username: string;
  // 徽章的规格，可能是尺寸、型号等相关的数值
  specification: number;
  // 徽章的标题，用于描述徽章的名称或主题
  title: string;
  // 徽章图片的 URL 地址
  img_url: string;
  // 徽章是否公开的标识，可能 0 表示不公开，1 表示公开
  isPublic: number;
  // 徽章闪底的路径
  flash_bottom: string;
  // 徽章闪底的名称
  fb_name: string;
  // 徽章覆膜的路径
  film_cover: string;
  // 徽章覆膜的名称
  fc_name: string;
  // 歌词的唯一标识符
  lid: number;
  // 歌词文件的 URL 地址
  lyric_url: string;
  // 歌词文件的名称
  lyric_name: string;
  // 背景音乐的唯一标识符
  bgmid: number;
  // 背景音乐文件的 URL 地址
  BGM_url: string;
  // 背景音乐文件的名称
  BGM_name: string;
  // 徽章相关视频的 URL 地址
  video_url: string;
  // 徽章信息的更新时间，格式为字符串
  update_time: string;
}


@Component
struct badgeDisplay
{
  // 定义缩放比例，用于控制组件内元素的大小，默认值为 1.4
  scale_size : number = 1.4
  // 定义徽章的规格尺寸，默认值为 56
  specification:number = 56
  // 存储闪底图片的资源路径，初始为空字符串
  flash_bottom:string = ''
  // 存储覆膜图片的资源路径，初始为空字符串
  film_cover:string = ''
  // 存储徽章主图的 URL 地址，初始为空字符串
  img_url:string = ''
  // 组件的构建方法，用于描述组件的 UI 结构
  build() {
    // 使用 Stack 布局组件，将内部元素堆叠显示
    Stack(){
      // 显示闪底图片
      Image($r(this.flash_bottom))
        // 设置图片的大小，根据规格和缩放比例计算
        .size({ width: this.specification * this.scale_size, height: this.specification * this.scale_size })
          // 将图片裁剪为圆形，圆形的大小同样根据规格和缩放比例计算
        .clipShape(new Circle({
          width: this.specification * this.scale_size,
          height: this.specification * this.scale_size
        }))
          // 禁止图片拖动
        .draggable(false)
      // 显示徽章主图，直接使用接口返回的 img_url
      Image(this.img_url)
        // 设置图片的大小，根据规格和缩放比例计算
        .size({ width: this.specification * this.scale_size, height: this.specification * this.scale_size })
          // 将图片裁剪为圆形，圆形的大小同样根据规格和缩放比例计算
        .clipShape(new Circle({
          width: this.specification * this.scale_size,
          height: this.specification * this.scale_size
        }))
          // 禁止图片拖动
        .draggable(false)
      // 显示覆膜图片
      Image($r(this.film_cover))
        // 设置图片的大小，根据规格和缩放比例计算
        .size({ width: this.specification * this.scale_size, height: this.specification * this.scale_size })
          // 将图片裁剪为圆形，圆形的大小同样根据规格和缩放比例计算
        .clipShape(new Circle({
          width: this.specification * this.scale_size,
          height: this.specification * this.scale_size
        }))
          // 设置图片的宽高比为 1:1
        .aspectRatio(1)
          // 设置图片的透明度为 1（不透明）
        .opacity(1)
          // 设置图片的混合模式为 DARKEN
        .blendMode(BlendMode.DARKEN)
          // 禁止图片拖动
        .draggable(false)
          // 为图片添加外部阴影效果
        .shadow(ShadowStyle.OUTER_DEFAULT_LG)
    }
  }
}

export default Badge
export {badgeDisplay,Updated_Badge}