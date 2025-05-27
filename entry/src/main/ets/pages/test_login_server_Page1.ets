import cloud, { ObjectTypeInfo, SignInResult, VerifyCodeAction, VerifyCodeResult } from '@hw-agconnect/cloud'
import { VerifyCodeRequest } from '@hw-agconnect/cloud/src/main/ets/auth/server/request/VerifyCodeRequest'
import { BusinessError } from '@kit.BasicServicesKit'
import { promptAction } from '@kit.ArkUI'
import { buffer } from '@kit.ArkTS'
import { Info } from '../Info'

@Entry
@Component
struct Test_login_server_Page1 {
  @State sendInterval: number = 60
  @State buttonLen: string = '获取验证码'
  private verifyCode: string = ''
  private phone: string = '18280632051'
  private email: string = ''

  private idT:number | null = null;
  private Sending:boolean = false;
  private emailVerifyCode:string = ''
  loadObjectInfo(): Promise<ObjectTypeInfo> {
    return new Promise(async (resolve: Function) => {
      const context = getContext(this)
      const value = await context.resourceManager.getRawFileContent('schema.json');
      let json: string = buffer.from(value as ArrayBufferLike).toString('utf8');
      let objectTypeInfo: ObjectTypeInfo = JSON.parse(json);
      resolve(objectTypeInfo)
    })
  }
  timeEnd() {

    this.idT = setInterval(() => {
      this.sendInterval--;
      this.Sending = true;
      if (this.sendInterval === 0) {
        clearInterval(this.idT)
        this.Sending = false;
        this.sendInterval = 60
      }
    }, 1000)
  }

  build() {
    Column() {
      TextInput({
        text: $$this.emailVerifyCode,
        placeholder: '输入邮箱验证码'
      })

      Text('登录验证')
        .fontSize(50)
      TextInput({
        text: $$this.email,
        placeholder: '输入邮箱地址登录'
      })


      Button('login').onClick((event: ClickEvent) => {
        cloud.auth().signIn({
          credentialInfo: {
            kind: 'email',
            verifyCode: this.emailVerifyCode,
            email:this.email,
          },
          autoCreateUser:true
        })
          .then(async (value:SignInResult)=>{
            promptAction.showDialog({
              message: JSON.stringify(value.getUser().getToken(true))
            })
          //   todo 调用云函数存储用户信息
          try{
            let result = await this.loadObjectInfo();
            let database = cloud.database({zoneName:'default',objectTypeInfo:result}).collection(Info);
            await database.upsert({
              uId:Number(value.getUser().getUid()),
              token:value.getUser().getToken(true)
            })
          }catch (e) { promptAction.showDialog({message:JSON.stringify(e )})
          }
          })
          .catch((err:BusinessError)=>{
            promptAction.showDialog({
              message: JSON.stringify(err)
            })
          })
      })

      Button('退出登录').onClick((event: ClickEvent) => {
        cloud.auth().signOut()
      })
      Button(this.sendInterval !== 60 ? this.sendInterval + '秒可重新获取' : '获取验证码', {
        type: ButtonType.Capsule,
        stateEffect: false,
        role: ButtonRole.NORMAL,
      })
        .width(130)
        .backgroundColor(this.sendInterval !== 60 ? '#ff4f7cab' : '#007DFF')
        .onClick((event: ClickEvent) => {
          if(this.Sending) return;
          this.timeEnd()
          try {
            cloud.auth().requestVerifyCode({
              action: VerifyCodeAction.REGISTER_LOGIN,
              lang: 'zh-CN',
              sendInterval: this.sendInterval,
              verifyCodeType: {
                kind: 'email',
                email: this.email
              }
            })
              .then((value: VerifyCodeResult) => {
                promptAction.showDialog({
                  message: JSON.stringify(value)
                })
              })
              .catch((err: object) => {
                promptAction.showDialog({
                  message: JSON.stringify(err + '111')
                })
              })
          } catch (e) {
            promptAction.showDialog({
              message: JSON.stringify(e)
            })
          }
        })


    }
    .height('100%')
    .width('100%')
  }
}