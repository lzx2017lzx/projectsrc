#include "configure_file.h"


namespace shove
{
    configure_file::configure_file(string filename)
    {
        m_filename = filename;

        FILE* fp;

        char buf[4096];

        if ((fp = fopen(m_filename.c_str(), "r")) == NULL)
        {
            if ((fp = fopen(m_filename.c_str(), "w")) == NULL)
            {
                return;
            }

            fclose(fp);

            if ((fp = fopen(m_filename.c_str(), "r")) == NULL)
            {
                return;
            }
        }

        while (fgets(buf, 4096, fp) != NULL)
        {
            string line = buf;
            int locate = line.find_first_of("=");

            if (locate < 0)
            {
                continue;
            }

            string key = line.substr(0, locate);
            string value = line.substr(locate + 1, line.length() - locate - 1);
            value = value.erase(0, value.find_first_not_of(" "));
            value = value.erase(0, value.find_first_not_of("\r\n"));
            value = value.erase(value.find_last_not_of(" ") + 1);
            value = value.erase(value.find_last_not_of("\r\n") + 1);

            Node node;
            node.key = key;
            node.value = value;

            v.push_back(node);
        }

        fclose(fp);
    }

    string configure_file::read_string(string key)
    {
        if (v.size() == 0)
        {
            return "";
        }

        for (vector<Node>::iterator it = v.begin(); it != v.end(); ++it)
        {
            if (it->key == key)
            {
                return it->value;
            }
        }

        return "";
    }

    int configure_file::read_int(string key)
    {
        string str = read_string(key);

        if (str.empty())
        {
            str = "0";
        }

        int number = 0;
        std::stringstream ss;
        ss << str;
        ss >> number;

        //if (!ss.good())
        //{
        //    return 0;
        //}

        return number;
    }
}
