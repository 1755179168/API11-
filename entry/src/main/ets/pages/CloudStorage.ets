import cloud, { AuthUser, ProgressEvent, UploadParam } from '@hw-agconnect/cloud';
import { AuthMode, Login } from '@hw-agconnect/auth-component';

import { fileIo, picker } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';


@Entry
@Component
struct CloudStorage {
  @StorageLink('user') user: AuthUser | null | undefined = null;
  @State isShowButton: boolean = true;
  @State image: Resource | PixelMap = $r('app.media.empty_image');
  @State progress: string = '';
  @State accessAddress: string = '';
  @State publicAccessAddress: string = '';
  @State imageUploadingProgress: number = 0;
  @State canUpload: boolean = true;
  @State imgUri: string = '';

  aboutToAppear() {
    this.user = AppStorage.get<AuthUser>('user')
  }

  // photoViewPicker
  initImagePicker(): Promise<string> {
    return new Promise((resolve: Function, reject: Function) => {
      let uri: string;
      const photoSelectOptions = new picker.PhotoSelectOptions();
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 1;
      const photoPicker = new picker.PhotoViewPicker();
      photoPicker.select(photoSelectOptions).then((photoSelectResult: picker.PhotoSelectResult) => {
        uri = photoSelectResult.photoUris[0];
        this.imgUri = uri
        resolve(uri)
      }).catch((err: Object) => {
        reject(err)
      })
    })
  }

  upLoadImage() {
    this.initImagePicker().then((res: string) => {
      this.canUpload = false;
      let cloudPath: string = `testcloud/demo_${new Date().getTime()}.jpg`
      let uploadParam: UploadParam = {
        localPath: res,
        cloudPath: cloudPath,
        onUploadProgress: (pe: ProgressEvent) => {
          console.log(`onUploadProgress:bytes:${pe.loaded} total:${pe.total}`)
          let percentCompleted = Math.round(
            (pe.loaded * 100) / pe.total
          )
          this.imageUploadingProgress = percentCompleted;
        }
      }
      cloud.storage().upload(uploadParam).then((res) => {
        this.getDownloadUrl(cloudPath)
      }).catch((err: Object) => {
        this.canUpload = true;
        console.log('uploadError', JSON.stringify(err))
      })

    })
  }

  getDownloadUrl(path: string) {
    cloud.storage().getDownloadURL(path).then(async (downUrl: string) => {
      this.accessAddress = downUrl
      this.publicAccessAddress = downUrl
      let file = fileIo.openSync(this.imgUri, fileIo.OpenMode.READ_ONLY)
      const imageSource = image.createImageSource(file.fd)
      let decodingOptions: image.DecodingOptions = {
        editable: true,
        desiredPixelFormat: 3,
      }
      this.image = await imageSource.createPixelMap(decodingOptions)
      this.canUpload = true;
    }).catch((err: Object) => {
      this.canUpload = true;
      console.log('getDownloadURLError', JSON.stringify(err))
    })
  }

  build() {
    Column() {
      Navigation()
        .title($r('app.string.cloudStorage_label'))
        .height('50vp')
        .width('100%')
        .margin({ bottom: 10 })
        .titleMode(NavigationTitleMode.Mini)

      Column() {
        Row() {
          Text($r('app.string.cloudStorage_description')).fontSize($r('app.float.body_font_size'))
        }.margin({ bottom: 15 })

        Row() {
          if (this.user !== null && this.user !== undefined) {
            Button($r('app.string.cloudStorage_uploadButton'), { type: ButtonType.Normal })
              .borderRadius(4)
              .width('100%')
              .opacity(this.canUpload ? 1 : 0.5)
              .enabled(this.canUpload)
              .height(40)
              .onClick(() => {
                this.upLoadImage()
              })
          } else {
            Column() {
              Login({
                modes: [AuthMode.PHONE_VERIFY_CODE],
                onSuccess: (user: AuthUser) => {
                  this.isShowButton = false
                  AppStorage.Set<AuthUser>('user', user);
                }
              }) {
                Button($r('app.string.cloudStorage_uploadButton'), { type: ButtonType.Normal })
                  .borderRadius(4)
                  .width('100%')
                  .opacity(this.canUpload ? 1 : 0.5)
                  .enabled(this.canUpload)
                  .height(40)
              }
            }
          }
        }

        Stack() {
          if (this.imageUploadingProgress !== 0) {
            Row() {
              Text($r('app.string.cloudStorage_progressLabel')).fontSize($r('app.float.body_font_size'))
              Text(': ' + this.imageUploadingProgress.toString().substr(0, 5) + ' %')
                .fontSize($r('app.float.body_font_size'))
            }
            .margin({ top: 10 })
          }
        }
      }.alignItems(HorizontalAlign.Start).width('90%').margin({ bottom: 20 })

      Column() {
        Row() {
          Image(this.image).objectFit(ImageFit.Contain).height(250)
            .backgroundColor($r('app.color.black'))
        }
      }.width('90%').margin({ bottom: 15 })
      Stack() {
        if (this.accessAddress !== '' && this.publicAccessAddress !== '') {
          Column({ space: 10 }) {
            Flex({ justifyContent: FlexAlign.SpaceBetween }) {
              Column() {
                Text($r('app.string.cloudStorage_accessAddressLabel'))
                  .fontSize($r('app.float.list_item_font_size'))
                  .fontWeight(FontWeight.Bold)
                  .textAlign(TextAlign.Start)
                  .width('100%')
                Text(this.accessAddress)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .textAlign(TextAlign.Start)
                  .wordBreak(WordBreak.BREAK_ALL)
                  .width('100%')
                  .maxLines(1)
                  .fontSize($r('app.float.list_item_font_size'))
              }.height(30).layoutWeight(3)
            }

            Flex({ justifyContent: FlexAlign.SpaceBetween }) {
              Column() {
                Text($r('app.string.cloudStorage_publicAccessAddressLabel'))
                  .fontSize($r('app.float.list_item_font_size'))
                  .fontWeight(FontWeight.Bold)
                  .textAlign(TextAlign.Start)
                  .width('100%')
                Text(this.publicAccessAddress)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .textAlign(TextAlign.Start)
                  .wordBreak(WordBreak.BREAK_ALL)
                  .width('100%')
                  .maxLines(1)
                  .fontSize($r('app.float.list_item_font_size'))
              }.height(30).layoutWeight(3)
            }
          }.width('90%').margin({ right: 10 })
        }
      }
    }.height('100%')
  }
}