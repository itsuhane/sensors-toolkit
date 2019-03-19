#include <cstdio>
#include <array>
#include <thread>
#include <atomic>
#include <mutex>
#include <chrono>
#include <opencv2/opencv.hpp>
#include <libsensors.h>

using namespace std::chrono_literals;

#define MAX_WIDTH (1600)
#define MAX_HEIGHT (900)

std::atomic<bool> preview_running;
cv::Mat preview_image;
std::mutex preview_mutex;

class SensorsPreview : public libsensors::Sensors {
  protected:
    void on_image(double t, int width, int height, const unsigned char *bytes) override {
        cv::Mat image(cv::Size(width, height), CV_8UC1, const_cast<unsigned char *>(bytes));
        cv::Mat preview;
        if (width > MAX_WIDTH || height > MAX_HEIGHT) {
            cv::Mat thumb;
            if (width * MAX_HEIGHT > height * MAX_WIDTH) { // image is wider
                cv::resize(image, thumb, cv::Size(MAX_WIDTH, height * MAX_WIDTH / width));
            } else { // image is taller
                cv::resize(image, thumb, cv::Size(width * MAX_HEIGHT / height, MAX_HEIGHT));
            }
            cv::cvtColor(thumb, preview, cv::COLOR_GRAY2BGR);
        } else {
            cv::cvtColor(image, preview, cv::COLOR_GRAY2BGR);
        }

        std::lock_guard lock(preview_mutex);
        preview_image = preview;
    }
};

void input() {
    SensorsPreview preview;
    std::array<unsigned char, 8192> buffer;
    while (true) {
        size_t nread = fread(buffer.data(), 1, buffer.size(), stdin);
        if (nread > 0) {
            preview.parse_data(buffer.data(), nread);
        } else {
            if (feof(stdin) || ferror(stdin)) {
                preview_running = false;
                break;
            }
        }
    }
}

int main(int argc, const char *argv[]) {
    preview_running = true;
    std::thread input_thread(&input);
    while (preview_running) {
        std::unique_lock lock(preview_mutex);
        if (!preview_image.empty()) {
            cv::imshow("sensors-preview", preview_image);
            lock.unlock();
            cv::waitKey(33);
        } else {
            lock.unlock();
            std::this_thread::sleep_for(33ms);
        }
    }
    input_thread.join();
    return 0;
}
