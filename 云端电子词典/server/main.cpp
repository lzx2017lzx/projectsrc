#include "server_manager.h"                                  

int main(int argc, char* argv[])
{
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

