#ifndef INET_H 
#define INET_H 
/*=========================================================================*\
* Internet domain functions
* LuaSocket toolkit
*
* This module implements the creation and connection of internet domain
* sockets, on top of the socket.h interface, and the interface of with the
* resolver. 
*
* The function inet_aton is provided for the platforms where it is not
* available. The module also implements the interface of the internet
* getpeername and getsockname functions as seen by Lua programs.
*
* The Lua functions toip and tohostname are also implemented here.
*
* RCS ID: $Id: inet.h,v 1.7 2003/06/26 18:47:45 diego Exp $
\*=========================================================================*/
#include <lua.h>
#include "socket.h"

void inet_open(lua_State *L);
const char *inet_tryconnect(p_sock ps, const char *address, 
        unsigned short port);
const char *inet_trybind(p_sock ps, const char *address, 
        unsigned short port, int backlog);
const char *inet_trycreate(p_sock ps, int type);
int inet_meth_getpeername(lua_State *L, p_sock ps);
int inet_meth_getsockname(lua_State *L, p_sock ps);

#ifdef INET_ATON
int inet_aton(const char *cp, struct in_addr *inp);
#endif

#endif /* INET_H */
