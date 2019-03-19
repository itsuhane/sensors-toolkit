#include <cstdio>
#include <array>
#include <libsensors.h>

class SensorsDecoder : public libsensors::Sensors {
  protected:
    void on_image(double t, int width, int height, const unsigned char *bytes) override {
        const std::uint8_t type = 0x00;
        fwrite(&type, sizeof(type), 1, stdout);
        fwrite(&t, sizeof(t), 1, stdout);
        const std::uint32_t w = width;
        const std::uint32_t h = height;
        fwrite(&w, sizeof(w), 1, stdout);
        fwrite(&h, sizeof(h), 1, stdout);
        fwrite(bytes, sizeof(std::uint8_t), width * height, stdout);
    }

    void on_gyroscope(double t, double x, double y, double z) override {
        const std::uint8_t type = 0x01;
        fwrite(&type, sizeof(type), 1, stdout);
        fwrite(&t, sizeof(t), 1, stdout);
        fwrite(&x, sizeof(x), 1, stdout);
        fwrite(&y, sizeof(x), 1, stdout);
        fwrite(&z, sizeof(x), 1, stdout);
    }

    void on_accelerometer(double t, double x, double y, double z) override {
        const std::uint8_t type = 0x02;
        fwrite(&type, sizeof(type), 1, stdout);
        fwrite(&t, sizeof(t), 1, stdout);
        fwrite(&x, sizeof(x), 1, stdout);
        fwrite(&y, sizeof(x), 1, stdout);
        fwrite(&z, sizeof(x), 1, stdout);
    }

    void on_magnetometer(double t, double x, double y, double z) override {
        const std::uint8_t type = 0x03;
        fwrite(&type, sizeof(type), 1, stdout);
        fwrite(&t, sizeof(t), 1, stdout);
        fwrite(&x, sizeof(x), 1, stdout);
        fwrite(&y, sizeof(x), 1, stdout);
        fwrite(&z, sizeof(x), 1, stdout);
    }

    void on_altimeter(double t, double pressure, double elevation) override {
        const std::uint8_t type = 0x04;
        fwrite(&type, sizeof(type), 1, stdout);
        fwrite(&t, sizeof(t), 1, stdout);
        fwrite(&pressure, sizeof(pressure), 1, stdout);
        fwrite(&elevation, sizeof(elevation), 1, stdout);
    }

    void on_gps(double t, double longitude, double latitude, double altitude, double horizontal_accuracy, double vertical_accuracy) override {
        const std::uint8_t type = 0x05;
        fwrite(&type, sizeof(type), 1, stdout);
        fwrite(&t, sizeof(t), 1, stdout);
        fwrite(&longitude, sizeof(longitude), 1, stdout);
        fwrite(&latitude, sizeof(latitude), 1, stdout);
        fwrite(&altitude, sizeof(altitude), 1, stdout);
        fwrite(&horizontal_accuracy, sizeof(horizontal_accuracy), 1, stdout);
        fwrite(&vertical_accuracy, sizeof(vertical_accuracy), 1, stdout);
    }
};

int main() {
    SensorsDecoder decoder;
    std::array<unsigned char, 8192> buffer;
    while (true) {
        size_t nread = fread(buffer.data(), 1, buffer.size(), stdin);
        if (nread > 0) {
            decoder.parse_data(buffer.data(), nread);
        } else {
            if (feof(stdin) || ferror(stdin)) {
                break;
            }
        }
    }
    return 0;
}
