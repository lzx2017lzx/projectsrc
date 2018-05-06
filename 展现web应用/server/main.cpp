#include "server_manager.h"                                  

void signal_handle(int v)
{

}
int main(int argc, char* argv[])
{
    signal(SIGHUP,signal_handle);
//    signal(SIGINT,SIG_IGN);
    lizongxin::manager::server_manager* sm = new lizongxin::manager::server_manager();     
    if(sm == NULL)
    {
        printf("Error: run service error, this server's memery not enough.\n");  
        return -1;
    }
    sm->initial();                                                               
    sm->run_service();                                                           
    delete sm;                                                                   
    return 0;
}       

