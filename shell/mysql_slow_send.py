#!/usr/bin/env python
#coding: utf-8  

import smtplib  
from email.mime.text import MIMEText  
from email.header import Header  
from email.Utils import COMMASPACE

from email.mime.multipart import MIMEMultipart
from email.mime.application import MIMEApplication

import time
import os 
import re
import commands

def cut_log(logfile,result):
    """
    cut log
    """
    today='# Time: 17%s ' % commands.getoutput("date +%m%d")
    yesterday='# Time: 17%s ' % commands.getoutput("""date -d "-1 day" +%m%d""")
    start=re.compile(r'%s' % yestorday)
    end=re.compile(r'%s' % today)
    #a=file('mysql-slow.log','r')
    #b=file('result.log','w')
    a=file('%s'% logfile,'r')
    b=file('%s'% result,'w')
    flag=0
    for i in a.readlines():
        print i
        if start.search(i) :
            flag=True
        if flag:
            b.write(i)
        if end.search(i):
            flag=0
            break
    a.close()
    b.close()

def send_mail(host,mailbody,filename): 
    """
    send mail
    """
    #收件人
    receiver = 'xxxxxxx'
    subject = host + "-" + time.strftime("%Y-%m-%d") + u' Mysql慢查询日志'
    smtpserver = 'smtp.exmail.qq.com'  
    #发件人
    username = 'xxxxxxx'
    #发件人密码
    password = 'xxxxxxx'  
    sender = username
      
    msg = MIMEMultipart()
    msg['Subject'] = Header(subject, 'utf-8')  
    msg['From'] = username
    msg['To'] = receiver

    # 邮件内容 
    puretext = MIMEText(mailbody)
    msg.attach(puretext)

    # 添加附件
    xlsxpart = MIMEApplication(open('%s' % filename, 'rb').read())
    xlsxpart.add_header('Content-Disposition', 'attachment', filename='mysql_slow.log'  )
    msg.attach(xlsxpart)

    smtp = smtplib.SMTP()  
    smtp.connect(smtpserver)  
    smtp.login(username, password)  
    smtp.starttls()
    smtp.sendmail(msg['From'], msg['To'], msg.as_string())  
    smtp.quit() 
    smtp.close()  


if __name__  == '__main__':
    #指定慢查询日志全路径
    logfile='xxxxxxxxx'
    result='result.log'
    host=commands.getoutput("rm -rf %s" % result)
    try:
        if os.path.getsize(logfile) == 0:
            print "%s 为空" % logfile
        else:
            cut_log(logfile,result)
            if os.path.getsize(result) != 0:
                host=commands.getoutput("hostname -i")
                send_mail(host,"详情见附件",result.log)
    except:
        print "%s 不存在" % logfile

    """
    result='/tmp/result.log'
    send_mail("127.0.0.1","详情见附件",result)
    """
