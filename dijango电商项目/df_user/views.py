from django.shortcuts import render,redirect
from django.http import HttpResponseRedirect
from models import *
from hashlib import sha1
from . import user_decorator
from df_goods.models import *

# Create your views here.
def register(request):
    return render(request,'df_user/register.html')

def register_handle(request):
    #accept user's input
    print("register")
    post=request.POST
    uname=post.get('user_name')
    upwd=post.get('pwd')
    upwd2=post.get('cpwd')
    uemail=post.get('email')
    #judge twice password
    if upwd!=upwd2:
        return redirect('/user/register/') 
    #password encode
    s1=sha1()
    s1.update(upwd)
    upwd3=s1.hexdigest()
    #create object
    user=UserInfo()
    user.uname=uname
    user.upwd=upwd3
    user.uemail=uemail
    user.save()
    #register success, turn to login page
    return redirect('/user/login/')

def register_exist(request):
    uname=request.GET.get('uname')
    count=UserInfo.objects.filter(uname=uname).count()
    return JsonResponse({'count':count})

def login(request):
    uname=request.COOKIES.get('uname','')
    context={'title':'user login','error_name':0,'error_pwd':0,'uname':uname}
    return render(request,'df_user/login.html',context)

def login_handle(request):
    post=request.POST
    uname=post.get('username')
    upwd=post.get('pwd')
    jizhu=post.get('jizhu',0)

    users=UserInfo.objects.filter(uname=uname)
    print "name:"+uname
    print "len(users):"+str(len(users))

    if len(users)>=1:
        s1=sha1()
        s1.update(upwd)
        print "s1.hexdigest():"+s1.hexdigest()
        print "users[0].upwd:"+users[0].upwd
        if s1.hexdigest()==users[0].upwd:
            red=HttpResponseRedirect('/user/info/')
            
            if jizhu!=0:
                red.set_cookie('uname',uname)
            else:
                red.set_cookie('uname','',max_age=-1)
            request.session['user_id']=users[0].id
            request.session['user_name']=uname
            return red
        else:
            context={'title':'user login','error_name':0,'error_pwd':1,'uname':uname,'upwd':upwd}
            return render(request,'df_user/login.html',context)

    else:
        context={'title':'user login','error_name':1,'error_pwd':0,'uname':uname,'upwd':upwd}
        return render(request,'df_user/login.html',context)

def logout(request):
    request.session.flush()
    return redirect('/')

def order(request):
    context={'title':''}
    return render(request,'df_user/cart.html',context)

@user_decorator.login
def info(request):
    user_email=UserInfo.objects.get(id=request.session['user_id']).uemail
    context={'title':'user center',
             'user_email':user_email,
             'user_name':request.session['user_name']
    }
    return render(request,'df_user/user_center_info.html',context)


@user_decorator.login
def order(request):
    context={'title':'user center'}
    return render(request,'df_user/user_center_order.html',context)


@user_decorator.login
def site(request):
    user=UserInfo.objects.get(id=request.session['user_id'])
    if request.method=='POST':
        post=request.POST
        user.ushou=post.get('ushou')
        usre.uaddress=post.get('uaddress')
        user.uyoubian=post.get('uyoubian')
        user.uphone=post.get('uphone')
        user.save()
    context={'title':'user center','user':user}
    return render(request,'df_user/user_center_site.html',context)
