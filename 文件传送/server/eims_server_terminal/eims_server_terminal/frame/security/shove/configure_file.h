#ifndef SHOVE_CONFIGURE_FILE_H
#define SHOVE_CONFIGURE_FILE_H


#include <string>
#include <stdio.h>
#include <vector>
#include <cstdlib>
#include <sstream>

using namespace std;

namespace shove
{
    class configure_file
    {

    public:

        configure_file(string filename);

        string read_string(string key);
        int read_int(string key);

    private:

        struct Node
        {
            string key;
            string value;
        };

        vector<Node> v;

        string m_filename;
    };
}

#endif // SHOVE_CONFIGURE_FILE_H
