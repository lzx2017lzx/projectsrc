--------------------------------------------------------
--
--	log object
--
--------------------------------------------------------

--log level
EIMS_LOG_LEVEL = {}
EIMS_LOG_LEVEL.FATAL 	= 1
EIMS_LOG_LEVEL.ERROR 	= 2
EIMS_LOG_LEVEL.WARN 	= 3
EIMS_LOG_LEVEL.INFO 	= 4
EIMS_LOG_LEVEL.DEBUG 	= 5
EIMS_LOG_LEVEL.RUNTIME 	= 6

--log writer
logger = log_oper.log_oper()