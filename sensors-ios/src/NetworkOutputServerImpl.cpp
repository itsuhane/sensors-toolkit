#include "NetworkOutputServerImpl.hpp"
#include <stdlib.h>
#include <unistd.h>
#include <sys/socket.h>
#include <stdio.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <errno.h>
#include <chrono>

using namespace std::chrono_literals;

static int guard(int n, const char *err) {
    if(n==-1) {
        puts(err);
        throw err;
    }
    return n;
}

static const int yes = 1;

ServerImpl::ServerImpl(const std::string &address, int port) {
    server_socket = guard(socket(PF_INET, SOCK_STREAM, IPPROTO_TCP), "unable to create server socket");
    guard(setsockopt(server_socket, SOL_SOCKET, SO_NOSIGPIPE, &yes, sizeof(yes)), "unable to set server socket options");
    
    int server_socket_flags = guard(fcntl(server_socket, F_GETFL), "unable to get server socket flag");
    guard(fcntl(server_socket, F_SETFL, server_socket_flags | O_NONBLOCK), "unable to set server socket flag");
    
    struct sockaddr_in addr;
    addr.sin_family = AF_INET;
    addr.sin_port = htons(port);
    addr.sin_addr.s_addr = htonl(INADDR_ANY);
    
    guard(setsockopt(server_socket, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(yes)), "could not set reuse");
    guard(bind(server_socket, (struct sockaddr *) &addr, sizeof(addr)), "could not bind server socket");
    guard(listen(server_socket, SOMAXCONN), "could not listen server socket");
    
    server_active = false;
    client_active = false;
    server_thread = std::thread(&ServerImpl::main, this);
}

ServerImpl::~ServerImpl() {
    server_active = false;
    if(server_thread.joinable()) {
        server_thread.join();
    }
    close(server_socket);
}

void ServerImpl::send(const void *data, size_t len) {
    if(client_active) {
        std::lock_guard<std::mutex> lock(pending_data_mtx);
        pending_data.insert(pending_data.end(), (const char*)data, ((const char*)data) + len);
    }
}

void ServerImpl::main() {
    server_active = true;
    while(server_active) {
        int client_socket = accept(server_socket, NULL, NULL);
        if (client_socket == -1) {
            if (errno == EWOULDBLOCK) {
                std::this_thread::sleep_for(1ms);
            } else {
                server_active = false;
            }
        } else {
            if(setsockopt(client_socket, SOL_SOCKET, SO_NOSIGPIPE, &yes, sizeof(yes)) != -1) {
                {
                    std::lock_guard<std::mutex> lock(pending_data_mtx);
                    sending_data.clear();
                    pending_data.clear();
                }
                serve(client_socket);
            }
            close(client_socket);
        }
    }
}

void ServerImpl::serve(int client_socket) {
    client_active = true;
    while (client_active) {
        {
            std::lock_guard<std::mutex> lock(pending_data_mtx);
            if(server_active) {
                if(pending_data.size() > 0) {
                    sending_data.swap(pending_data);
                } else {
                    std::this_thread::sleep_for(1ms);
                }
            } else {
                client_active = false;
            }
        }
        while(client_active && sending_data.size() > 0) {
            long sent = ::send(client_socket, sending_data.data(), sending_data.size(), 0);
            if(sent == -1) {
                if(errno != EAGAIN) {
                    client_active = false;
                }
            } else {
                sending_data.erase(sending_data.begin(), sending_data.begin() + sent);
            }
            if(!server_active) {
                client_active = false;
            }
        }
    }
}
