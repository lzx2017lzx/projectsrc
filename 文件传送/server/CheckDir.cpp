#include"CheckDir.h"
int checkdir(char *dirname,vector<string>&vfile)
{
    if(dirname==NULL)
    {
        cout<<"ERROR"<<endl;
        return -1;
    }
    int flaghasfile=0;
    while(1)
    {
        sem_wait(&sem_id1);
        DIR *dir=opendir(dirname);//如果是文件不是目录，是否要考虑判断dir是不是NULL
        flaghasfile=0;
        if(dir==NULL)
        {
            cout<<"there is no directory."<<endl;
            return -1;
        }
        struct dirent * pdir=readdir(dir);
        cout<<"checkdir"<<endl;
        while(pdir!=NULL)
        {
            try
            {
                if(pdir->d_type==DT_REG)
                {
                    flaghasfile=1;
                    cout<<"there is file"<<endl;
                    vfile.push_back(string(dirname)+"/"+pdir->d_name);
                    cout<<"vfile from dir:"<<*(vfile.end()-1)<<endl;
                }
                pdir=readdir(dir);
            }catch(exception&e)
            {
                cout<<"exception:"<<e.what()<<endl;
            }
            sleep(1);
        }
        if(!flaghasfile)
        {
            cout<<"there is no file"<<endl;
        }
        closedir(dir);
        sem_post(&sem_id2);
    }

    return 0;
}
