 #ifndef XML_OPER_H
#define XML_OPER_H

#include <string>
#include "xml_parser.h"

using namespace std;

struct xml_node
{
	string node_path;
	string node_value;
};

class xml_oper
{
	public:
		xml_oper();

		~xml_oper();
		//加载XML字符串
		int load_xml_data(string data, string roottag);

		//获取节点的值，路径格式为：节点1/子节点1/子子节点1/...
		string get_node_value(string node_path);

		//设置节点的值，路径格式同上
		int set_node_value(string node_path, string node_value);

		//获取节点属性的值，路径同上
		string get_node_attribute_value(string node_path, string attr_name);

		//删除节点，路径上同
		int del_node(string node_path);

		//增加子节点，路径同上
		int add_child_node(string name, string value, string path);

		//获取子节点的值
		string get_child_node_value(string node_name);

		//构建一个XML字符串
		string create_xml_string();

		void clear_all_nodes();

	private:
		XMLNode m_root_node_;
};

#endif // XML_OPER_H
