import { photoAccessHelper } from '@kit.MediaLibraryKit';
import cloud from '@hw-agconnect/cloud';
import { BusinessError } from '@kit.BasicServicesKit';
@Entry
@Component
struct Upload_Page {
  @State message: string = 'Hello World';

  build() {

    Column() {
      Button('上传图片').onClick((event: ClickEvent) => {
        const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
        photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE; // 过滤选择媒体文件类型为IMAGE。
        photoSelectOptions.maxSelectNumber = 5; // 选择媒体文件的最大数目。
        let uris: Array<string> = [];
        const photoViewPicker = new photoAccessHelper.PhotoViewPicker();
        photoViewPicker.select(photoSelectOptions).then((photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
          uris = photoSelectResult.photoUris;
          console.info('photoViewPicker.select to file succeed and uris are:' + uris);
        }).catch((err: BusinessError) => {
          console.error(`Invoke photoViewPicker.select failed, code is ${err.code}, message is ${err.message}`);
        })

       let a = cloud.storage()
        let cloudPath = 'image/test2.jpg'

        // a.upload({
        //
        // })
      })
    }
    .height('100%')
    .width('100%')
  }
}