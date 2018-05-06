
#include "frame/servermanager/server_manager.h"

int main(int argc, char* argv[])
{
	eims::manager::server_manager* sm = new eims::manager::server_manager();
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
