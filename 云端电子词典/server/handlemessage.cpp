#include"handlemessage.h"

namespace lizongxin
{
    char *HandleMessage::handle_message(char* input, size_t len, size_t* result_len, string ip)
    {
        //Json json;
        string temp(input);
        cout<<"temp in handle_message:"<<temp<<"----"<<endl;
        json.parse(temp);

        char result[1024]={0};
        short int indexcmd=json["indexcmd"].asInt16();
        cout<<"indexcmd:"<<indexcmd<<endl;

        if(indexcmd==1)
        {
            string key=json["key"].asString();
            string sqlfind;
            sqlfind+="select * from englishwords where chinesekey=";
            sqlfind+="\""+key+"\"";
            cout<<"sqlfind:"<<sqlfind<<endl;
            int ret=0;
            char result[10240]={0};
            if(mysqltool->selectgetfieldname((char*)sqlfind.c_str(),result))
            {
                cout<<"error mysql:"<<endl;
                printf("mysql_error:%s\n",mysqltool->mysqllib_error());
                auto json= Json(JObject{{ "return",SERVERERROR },{ "descrip","" }});

                RETURN(json.stringify());
            };
            printf("result getweburl:%s\n",result);
            Json json(JObject{{"return",0},{"descrip",Json().parse(result)}});
            printf("jsonstringify:%s\n",json.stringify().c_str());
            RETURN(json.stringify());
            free(result);
        }
        else if(indexcmd==2)
        {
            

        }
        auto json= Json(JObject{{ "return",UNKNOWN },{ "descrip","" }});

        RETURN(json.stringify());

    }



    HandleMessage::HandleMessage():json()
    {
        mysqltool=mysqllib::getInstance();
    }

    HandleMessage::~HandleMessage()
    {

    }
}
