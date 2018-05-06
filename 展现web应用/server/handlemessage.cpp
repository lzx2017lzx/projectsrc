#include"handlemessage.h"

namespace lizongxin
{
    char *HandleMessage::handle_message(char* input, size_t len, size_t* result_len, string ip)
    {
#if 1
        //Json json;
        string temp(input,len);
        json.parse(temp);

        char result[1024]={0};
        short int indexcmd=json["indexcmd"].asInt16();

        if(indexcmd==2)
        {
            string username=json["username"].asString();
            string password=json["password"].asString();
            string sqlfind;
            sqlfind+="select username from user where username=";
            sqlfind+="\""+username+"\"";
            cout<<"sqlfind:"<<sqlfind<<endl;
            int ret=0;

            if((ret=mysqltool->select((char*)sqlfind.c_str()))>0)
            {
                cout<<"account exist:ret:"<<ret<<endl;
                Json json;
                json =Json(JObject{{"return",USEREXIST },{ "descrip","account exist" }});

                RETURN(json.stringify());
            }else if(ret<0)
            {
                printf("mysql_error:%s\n",mysqltool->mysqllib_error());
                auto json= Json(JObject{{"return",SERVERERROR },{"descrip","server error try again" }});

                RETURN(json.stringify());
            }; 
            string sqltemp;
            sqltemp+="insert into user(username,password) values(";
            sqltemp+="\""+username+"\""+","+"\""+password+"\""+")";
            cout<<"sqltemp:"<<sqltemp<<endl;

            if(mysqltool->insert((char*)sqltemp.c_str())!=0)
            {
                cout<<"error mysql:"<<endl;
                printf("mysql_error:%s\n",mysqltool->mysqllib_error());
                auto json= Json(JObject{{"return",SERVERERROR },{ "descrip","server error try again" }});

                RETURN(json.stringify());
            }; 

            auto json= Json(JObject{{"return",REGISTERSUCCESS },{ "descrip","register success" }});

            RETURN(json.stringify());

        }

        if(indexcmd==1)
        {
            string username=json["username"].asString();
            string password=json["password"].asString();
            string sqltemp;
            sqltemp+="select password from user where username=";
            sqltemp+="\""+username+"\"";
            cout<<"sqltemp:"<<sqltemp<<endl;


            if(mysqltool->select((char*)sqltemp.c_str(),result))
            {
                cout<<"error mysql:"<<endl;
                printf("mysql_error:%s\n",mysqltool->mysqllib_error());
                auto json= Json(JObject{{ "return",SERVERERROR },{ "descrip","" }});

                RETURN(json.stringify());
            }; 
            printf("result login:%s\n",result);

            if(strncmp(password.c_str(),result,3)==0)
            {
                auto json= Json(JObject{{ "return",LOGINSUCCESS },{ "descrip","" }});

                RETURN(json.stringify());
            };
            auto json= Json(JObject{{ "return",PASSWORDERROR },{ "descrip","" }});

            RETURN(json.stringify());
        }

        if(indexcmd==3)
        {
            string username=json["username"].asString();
            string sqltemp;
            sqltemp+="select * from webapplication";
            cout<<"sqltemp:"<<sqltemp<<endl;
            char *result=NULL;
            result=(char*)malloc(20401);
            result[20400]='\0';


            if(mysqltool->selectgetfieldname((char*)sqltemp.c_str(),result)<0)
            {
                cout<<"error mysql:"<<endl;
                printf("mysql_error:%s\n",mysqltool->mysqllib_error());
                auto json= Json(JObject{{ "return",SERVERERROR },{ "descrip","" }});

                RETURN(json.stringify());
            }; 
            printf("result getweburl:%s\n",result);
            Json json(JObject{{"return",GETAPPLICATIONURLSUCCESS},{"descrip",Json().parse(result)}});
            printf("jsonstringify:%s\n",json.stringify().c_str());
            RETURN(json.stringify());
            free(result);

        }
        if(indexcmd==5)
        {
            string username=json["username"].asString();
            if(username.size()==0)
            {
                auto json= Json(JObject{{ "return",UNKNOWN },{ "descrip","" }});
                RETURN(json.stringify());
            }
            string sqltemp;
            sqltemp+="select * from webapplicationstate where username='";
            sqltemp+=username+"'";
            cout<<"sqltemp:"<<sqltemp<<endl;
            char *result=NULL;
            result=(char*)malloc(20401);
            result[20400]='\0';
            int retval;


            if((retval=mysqltool->selectgetfieldname((char*)sqltemp.c_str(),result))<0)
            {
                cout<<"error mysql:"<<endl;
                printf("mysql_error:%s\n",mysqltool->mysqllib_error());
                auto json= Json(JObject{{ "return",SERVERERROR },{ "descrip","" }});

                RETURN(json.stringify());
            }; 

            if(retval==0)
            {
                // insert data
                string sqltemp;
                sqltemp+="insert into webapplicationstate(state,username) values(0,'";
                sqltemp+=username+"')";
                cout<<"sqltemp:"<<sqltemp<<endl;
                if(mysqltool->insert((char*)sqltemp.c_str())!=0)
                {
                    cout<<"error mysql:"<<endl;
                    printf("mysql_error:%s\n",mysqltool->mysqllib_error());
                    auto json= Json(JObject{{"return",SERVERERROR },{ "descrip","server error try again" }});

                    RETURN(json.stringify());
                }; 
            }
            printf("result checksyn:%s\n",result);
            Json json(JObject{{"return",TESTSYNRESPSUC},{"descrip",Json().parse(result)}});
            printf("jsonstringify:%s\n",json.stringify().c_str());
            RETURN(json.stringify());
            free(result);
        }

        if(indexcmd==6)
        {
            string username=json["username"].asString();
            string sqltemp;
            sqltemp+="select * from webapplication";
            cout<<"sqltemp:"<<sqltemp<<endl;
            char *result=NULL;
            result=(char*)malloc(20401);
            result[20400]='\0';


            if(mysqltool->selectgetfieldname((char*)sqltemp.c_str(),result)<0)
            {
                cout<<"error mysql:"<<endl;
                printf("mysql_error:%s\n",mysqltool->mysqllib_error());
                auto json= Json(JObject{{ "return",SERVERERROR },{ "descrip","" }});

                RETURN(json.stringify());
            }; 
            printf("result getweburl:%s\n",result);
            Json json(JObject{{"return",SYNRESPSUC},{"descrip",Json().parse(result)}});
            printf("jsonstringify:%s\n",json.stringify().c_str());
            RETURN(json.stringify());
            free(result);
        }
        if(indexcmd==9)
        {
            string username=json["username"].asString();
            string sqltemp;
            sqltemp+="update webapplicationstate set state=0 where username='";
            sqltemp+=username+"'";
            cout<<"sqltemp:"<<sqltemp<<endl;
            char *result=NULL;


            if(mysqltool->update((char*)sqltemp.c_str())<0)
            {
                cout<<"error mysql:"<<endl;
                printf("mysql_error:%s\n",mysqltool->mysqllib_error());
                auto json= Json(JObject{{ "return",SERVERERROR },{ "descrip","" }});

                RETURN(json.stringify());
            }; 
            printf("result getweburl:%s\n",result);
            Json json(JObject{{"return",RESPONSYNSUC},{"descrip","update finish"}});
            printf("jsonstringify:%s\n",json.stringify().c_str());
            RETURN(json.stringify());
            free(result);
        }

        Json json(JObject{{"return",UNKNOWN},{"descrip",""}});
        printf("jsonstringify:%s\n",json.stringify().c_str());
        RETURN(json.stringify());
#endif

    }

    HandleMessage::HandleMessage():json()
    {
        mysqltool=mysqllib::getInstance();
    }

    HandleMessage::~HandleMessage()
    {

    }
}
