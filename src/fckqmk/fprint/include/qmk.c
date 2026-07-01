#include <printf.h>
#include <stdarg.h>
#include <uart.h>

#include <stdint.h>

int qmk_uprintf(const char *__restrict format, ...) {
  va_list args;
  va_start(args, format);

  int ret = vprintf(format, args);

  va_end(args);

  return ret;
}

void qmk_uart_init(uint32_t baud) { uart_init(baud); }
void qmk_uart_receive(uint8_t *data, uint16_t length) {
  uart_receive(data, length);
}
void qmk_uart_transmit(const uint8_t *data, uint16_t length) {
  uart_transmit(data, length);
}
