#ifndef NetworkOutputServerImpl_hpp
#define NetworkOutputServerImpl_hpp

#include <deque>
#include <vector>
#include <thread>
#include <mutex>
#include <condition_variable>
#include <atomic>

class ServerImpl {
public:
    ServerImpl(const std::string &address, int port);
    ~ServerImpl();
    void send(const void *data, size_t len);
    
private:
    void main();
    void serve(int client_socket);
    
    int server_socket;
    std::atomic<bool> server_active;
    std::thread server_thread;
    
    std::atomic<bool> client_active;
    std::vector<char> pending_data;
    std::vector<char> sending_data;
    std::mutex pending_data_mtx;
};

#endif /* NetworkOutputServerImpl_hpp */
