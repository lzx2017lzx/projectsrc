
/*
 * Copyright (C) Igor Sysoev
 * Copyright (C) Nginx, Inc.
 */

#include <ngx_config.h>
#include <ngx_core.h>
#include <ngx_http.h>


static char *ngx_http_zongxintext(ngx_conf_t *cf, ngx_command_t *cmd,
        void *conf);

static ngx_command_t  ngx_http_zongxintext_commands[] = {

    { ngx_string("zongxintext"),
        NGX_HTTP_LOC_CONF|NGX_CONF_NOARGS,
        ngx_http_zongxintext,
        0,
        0,
        NULL },

    ngx_null_command
};


/* the minimal single pixel transparent GIF, 43 bytes */

#if 1
static u_char  ngx_zongxintext[] = "<!DOCTYPE html>"
"<html><head lang=\"en\">"
"<meta charset=\"UTF-8\">"
"<title></title><style>input,button {border:0 none;padding:0;}.search {width:258px;height:40px;margin: 100px auto;background-color: pink;}</style>"
"</head>"
"<body><div class=\"search\"><input type=\"text\" value=\"请输入...\"/><button></button></div></body></html>";
#endif


static ngx_http_module_t  ngx_http_zongxintext_module_ctx = {
    NULL,                          /* preconfiguration */
    NULL,                          /* postconfiguration */

    NULL,                          /* create main configuration */
    NULL,                          /* init main configuration */

    NULL,                          /* create server configuration */
    NULL,                          /* merge server configuration */

    NULL,                          /* create location configuration */
    NULL                           /* merge location configuration */
};


ngx_module_t  ngx_http_zongxintext_module = {
    NGX_MODULE_V1,
    &ngx_http_zongxintext_module_ctx, /* module context */
    ngx_http_zongxintext_commands,   /* module directives */
    NGX_HTTP_MODULE,               /* module type */
    NULL,                          /* init master */
    NULL,                          /* init module */
    NULL,                          /* init process */
    NULL,                          /* init thread */
    NULL,                          /* exit thread */
    NULL,                          /* exit process */
    NULL,                          /* exit master */
    NGX_MODULE_V1_PADDING
};


static ngx_str_t  ngx_http_gif_type = ngx_string("text/html");


    static ngx_int_t
ngx_http_zongxintext_handler(ngx_http_request_t *r)
{
    ngx_http_complex_value_t  cv;

    if (!(r->method & (NGX_HTTP_GET|NGX_HTTP_HEAD))) {
        return NGX_HTTP_NOT_ALLOWED;
    }

    ngx_memzero(&cv, sizeof(ngx_http_complex_value_t));

    cv.value.len = sizeof(ngx_zongxintext);
    cv.value.data = ngx_zongxintext;
    r->headers_out.last_modified_time = 23349600;

    return ngx_http_send_response(r, NGX_HTTP_OK, &ngx_http_gif_type, &cv);
}


    static char *
ngx_http_zongxintext(ngx_conf_t *cf, ngx_command_t *cmd, void *conf)
{
    ngx_http_core_loc_conf_t  *clcf;

    clcf = ngx_http_conf_get_module_loc_conf(cf, ngx_http_core_module);
    clcf->handler = ngx_http_zongxintext_handler;

    return NGX_CONF_OK;
}
