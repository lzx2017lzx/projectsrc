%module tools

%include <std_string.i>
%{
#include "../../frame/common/tools.h"
%}

/* Let's just grab the original header file here */
%include "../../frame/common/tools.h"
