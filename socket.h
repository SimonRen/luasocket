#ifndef SOCK_H
#define SOCK_H
/*=========================================================================*\
* Socket compatibilization module
* LuaSocket toolkit
*
* BSD Sockets and WinSock are similar, but there are a few irritating
* differences. Also, not all *nix platforms behave the same. This module
* (and the associated usocket.h and wsocket.h) factor these differences and
* creates a interface compatible with the io.h module.
*
* RCS ID: $Id: socket.h,v 1.5 2003/06/26 18:47:47 diego Exp $
\*=========================================================================*/
#include "io.h"

/*=========================================================================*\
* Platform specific compatibilization
\*=========================================================================*/
#ifdef WIN32
#include "wsocket.h"
#else
#include "usocket.h"
#endif

/* we are lazy... */
typedef struct sockaddr SA;

/*=========================================================================*\
* Functions bellow implement a comfortable platform independent 
* interface to sockets
\*=========================================================================*/
int sock_open(void);
const char *sock_create(p_sock ps, int domain, int type, int protocol);
void sock_destroy(p_sock ps);
int sock_accept(p_sock ps, p_sock pa, SA *addr, socklen_t *addr_len, 
        int timeout);
const char *sock_connect(p_sock ps, SA *addr, socklen_t addr_len); 
const char *sock_bind(p_sock ps, SA *addr, socklen_t addr_len); 
void sock_listen(p_sock ps, int backlog);
int sock_send(p_sock ps, const char *data, size_t count, 
        size_t *sent, int timeout);
int sock_recv(p_sock ps, char *data, size_t count, 
        size_t *got, int timeout);
int sock_sendto(p_sock ps, const char *data, size_t count, 
        size_t *sent, SA *addr, socklen_t addr_len, int timeout);
int sock_recvfrom(p_sock ps, char *data, size_t count, 
        size_t *got, SA *addr, socklen_t *addr_len, int timeout);
void sock_setnonblocking(p_sock ps);
void sock_setblocking(p_sock ps);
const char *sock_hoststrerror(void);
const char *sock_createstrerror(void);
const char *sock_bindstrerror(void);
const char *sock_connectstrerror(void);

#endif /* SOCK_H */
