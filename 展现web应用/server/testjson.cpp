#include <iostream>
//#include<string>
#include"json.h"
using namespace std;

#define MAX 1;
int main(int argc, char *argv[])
{
#if 0
    Json json;
    
    string in;
    in="{\"username\":\"lzx\",\"password\":\"lzx\"}";
   
    Json &jsonref=json.parse(in);

    cout<<jsonref<<endl;

    string str=json["username"].stringify();
    cout<<str<<endl;
#endif
//    Json json;
    
    auto json=Json(JObject{{"abc",1},{"deft","json"}});

    cout<<"json['abc']:"<<json["abc"]<<endl;

	return 0;
}
