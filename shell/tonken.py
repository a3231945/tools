#!/usr/bin/env python
import pyotp



#获取google author 动态密码

#自己机器的密码
PASSWD='xxxxxx'
#秘密成长因子
TONKEN='xxxxxx'


def get_passwd(passwd,token):
    totp = pyotp.TOTP('%s' % token)
    newpasswd = PASSWD + totp.now()
    return  newpasswd

if __name__ == '__main__':
    a = get_passwd(PASSWD,TONKEN)
    print a
