import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

Future<bool> sendMail(String email, String code, BuildContext context) async {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.greenAccent,
        ),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "验证码发送中，如果没收到，请检查垃圾邮件或者换个邮箱或者联系管理员",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }));
  bool sendStates;
  List<Mail> mails = new List();
  mails.add(new Mail("fastsearch@sohu.com", "KR3XZJ1MUIV", "smtp.sohu.com"));
  mails.add(new Mail("3523972574@qq.com", "ivxyyjlltxfbchhg", "smtp.qq.com"));
  mails.add(new Mail("jisusousuo@sohu.com", "X97WZIEHTQVA0L", "smtp.sohu.com"));
  mails.add(new Mail("sousuojisu@sohu.com", "WQ83DIZTPVHAN2", "smtp.sohu.com"));

  try {
    Mail mail = mails[Random().nextInt(mails.length)];
    String _username = mail.username;
    String _password = mail.password;

    final smtpServer = new SmtpServer(mail.stmp,
        username: _username,
        password: _password,
        port: 465,
        ignoreBadCertificate: false,
        ssl: true,
        allowInsecure: true);

    /* final smtpServer=hotmail(_username, _password); */

    // Create our message.
    final message = Message()
      ..from = Address("$_username")
      ..recipients.add('$email')
      ..subject = "疾速搜索邮箱验证码"
      ..html =
          "<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'><html xmlns='http://www.w3.org/1999/xhtml'>    <head>        <meta http-equiv='Content-Type' content='text/html; charset=UTF-8' />        <title></title>        <style>        body{        background:#000000;        color:green;        }        </style>    </head>    <body>    <!-- 最外层table-->    <table border='0' cellpadding='0' cellspacing='0' height='100%' width='100%' style='padding:15px;'>        <tr>            <td align='center' valign='top'>                <!-- 定宽table-->                <table border='0' cellpadding='0' cellspacing='0' width='100%' style='color:green;'>                    <tr>                        <td align='center'><h1>疾速搜索验证码</h1></td>                    </tr>                     <tr>                        <td align='left'>尊敬的用户：</td>                    </tr>                     <tr>                        <td align='left'>您的邮箱验证代码为: <span style='color:red;'>" +
              code +
              "</span>，请尽快在网页中填写，完成验证。</td>                    </tr>                    <tr>                        <td align='left'><br/></td>                    </tr>                     <tr>                        <td align='right'>E-mail: fastsearch@126.com</td>                    </tr>                    <tr>                        <td align='right'>QQ群：921919979</td>                    </tr>                </table>            </td>        </tr>    </table>    </body></html>";

    try {
      await send(message, smtpServer);
      sendStates = true;
    } on MailerException catch (e) {
      sendStates = false;
    }
  } catch (Exception) {
    //Handle Exception
  } finally {
    Navigator.pop(context);
  }
  return sendStates;
}

class Mail{
  String username;
  String password;
  String stmp;
  Mail(this.username,this.password,this.stmp);
}
