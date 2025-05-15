interface Item {
  Name: string;
  dialogue:string;
  id:number
}

@Entry
@Component
struct SearchExample {
  @State changeValue: string = ''
  @State submitValue: string = ''
  controller: SearchController = new SearchController()
  scroller: Scroller = new Scroller();
  private arr: number[] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];

  build() {
    Column() {
      Search({ value: this.changeValue, placeholder: 'name', controller: this.controller })
        .searchButton('SEARCH')
        .width('100%')
        .height(40)
        .backgroundColor('#F5F5F5')
        .placeholderColor(Color.Grey)
        .placeholderFont({ size: 14, weight: 400 })
        .textFont({ size: 14, weight: 400 })
        .onSubmit((value: string) => {
          this.submitValue = value
        })
        .onChange((value: string) => {
          this.changeValue = value
        })
        .margin(20)
      Scroll(this.scroller) {
        Column() {
          ForEach(this.arr, (item:number) => {
            Text(item.toString())
              .width('90%')
              .height(75)
              .backgroundColor(0xFFFFFF)
              .borderRadius(15)
              .fontSize(16)
              .textAlign(TextAlign.Center)
              .margin({ top: 10 })
          })
        }.width('100%')
        .margin({top:20,bottom:60})
      }
      .backgroundColor(0xDCDCDC)
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.On)
      .scrollBarColor(Color.Gray)
      .scrollBarWidth(10)
      .edgeEffect(EdgeEffect.Spring)


    }.width('100%')
  }
}