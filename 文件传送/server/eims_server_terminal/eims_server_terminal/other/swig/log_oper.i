%module log_oper

%include <std_string.i>
%{
#include "../../frame/debug/log_oper.h"
%}

/* Let's just grab the original header file here */
%include "../../frame/debug/log_oper.h"
