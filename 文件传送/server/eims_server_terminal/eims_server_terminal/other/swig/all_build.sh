#!/bin/sh

swig -c++ -lua db_oper.i

swig -c++ -lua log_oper.i

swig -c++ -lua xml_oper.i

swig -c++ -lua tools.i
