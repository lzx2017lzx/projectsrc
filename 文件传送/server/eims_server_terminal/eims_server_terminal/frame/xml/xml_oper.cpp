 #include "xml_oper.h"

xml_oper::xml_oper()
{
	//ctor
}

xml_oper::~xml_oper()
{
	//dtor
	clear_all_nodes();
}

int xml_oper::load_xml_data(string data, string roottag)
{
	clear_all_nodes();
	XMLResults xe;
	m_root_node_ = XMLNode::parseString((XMLCSTR)data.c_str(), NULL, &xe);
	if(xe.error != eXMLErrorNone)
	{
		return (int)xe.error;
	}
	return (int)eXMLErrorNone;
}

void xml_oper::clear_all_nodes()
{
	if(!m_root_node_.isEmpty())
		m_root_node_ = XMLNode::emptyNode();
}

//路径是相对于根结点的，比如根结点为XML，要查找的结点路径为XML/MSG/ID，那么此时路径应该传入MSG/ID
//根结点不算入路径中，如果只是查找根结点下的某个子节点。则只要传入节点名即可
string xml_oper::get_node_value(string node_path)
{
	if(m_root_node_.isEmpty())
		return "";
	XMLNode xn = m_root_node_.getChildNodeByPath(node_path.c_str(), 0);
	if(xn.isEmpty())
		return "";
	if(NULL == xn.getText())
		return "";
	return xn.getText();
}


string xml_oper::get_node_attribute_value(string node_path, string attr_name = "")
{
	XMLNode xn = m_root_node_.getChildNodeByPath(node_path.c_str(), 0);
	if(xn.isEmpty())
		return "";
	if(attr_name == "")
	{
		if(NULL == xn.getAttributeValue())
			return "";
		return xn.getAttributeValue();
	}
	else
	{
		if(NULL == xn.getAttribute(attr_name.c_str()))
			return "";
		return xn.getAttribute(attr_name.c_str());
	}

}
int xml_oper::set_node_value(string node_path, string node_value)
{
	XMLNode xn = m_root_node_.getChildNodeByPath(node_path.c_str(), 0);
	if(xn.isEmpty())
		return -1;
	xn.updateText(node_value.c_str());
	return 0;
}
int xml_oper::del_node(string node_path)
{
	XMLNode xn = m_root_node_.getChildNodeByPath(node_path.c_str(), 0);
	if(xn.isEmpty())
		return -1;
	xn.deleteNodeContent();
	return 0;
}
int xml_oper::add_child_node(string name, string value, string path = "")
{
	if("" == path)
	{
		m_root_node_.addChild(name.c_str()).updateText(value.c_str());
	}
	else
	{
		XMLNode xn = m_root_node_.getChildNodeByPath(path.c_str(), 0);
		if(xn.isEmpty())
			return -1;
		XMLNode xn_1 = xn.addChild(name.c_str());
		if(xn_1.isEmpty())
			return -2;
		xn_1.updateText(value.c_str());
	}
	return 0;
}
string xml_oper::get_child_node_value(string node_name)
{
	return "";
}

string xml_oper::create_xml_string()
{
	char* ret = m_root_node_.createXMLString(false);
	string retstr(ret);
	free(ret);
	return retstr;
}
