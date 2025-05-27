import cloud, { Database, DatabaseCollection, ObjectTypeInfo } from '@hw-agconnect/cloud';
import { buffer } from '@kit.ArkTS';
import { yeye } from "../yeye"
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction, router } from '@kit.ArkUI';

@Entry
@Component
struct Index_callFunctionPage {
  @State message: string = 'Hello World';
  private agcDatabase:Database | null = null
  param:Record<string,number> | null = null;
  loadObjectInfo(): Promise<ObjectTypeInfo> {
    return new Promise(async (resolve: Function) => {
      const context = getContext(this)
      const value = await context.resourceManager.getRawFileContent('schema.json');
      let json: string = buffer.from(value as ArrayBufferLike).toString('utf8');
      let objectTypeInfo: ObjectTypeInfo = JSON.parse(json);
      resolve(objectTypeInfo)
    })
  }

  aboutToAppear(): void {
    this.loadObjectInfo().then((res) => {
      this.agcDatabase = cloud.database({zoneName:'default',objectTypeInfo:res});
    })

    this.param = router.getParams() as Record<string,number>
  }

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('Index_callFunctionPageHelloWorld')
        .fontSize($r('app.float.page_text_font_size'))
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick( async () => {

         try{
           this.agcDatabase?.collection(yeye).upsert(new yeyeTo(191,880))
             .then((res)=>{

             })

         }catch (e) {
           AlertDialog.show({
             message:(e as BusinessError).message + '>>>' + (e as BusinessError).code
           })
         }


        })
    }
    .height('100%')
    .width('100%')
  }
}

class yeyeTo {
  height:number = 0
  weight:number = 0

  constructor( height: number, weight: number) {
    this.height = height;
    this.weight = weight;
  }



}