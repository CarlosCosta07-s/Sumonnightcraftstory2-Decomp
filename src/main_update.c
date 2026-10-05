/*
 * Behavior-level reconstruction of the per-frame dispatcher at ROM 0x080001D0.
 * Most subsystem callees retain address-based names pending further analysis.
 */
#include <stdint.h>

extern int32_t get_indexed_value_08026908(uint16_t index);
extern void set_indexed_value_080268B4(uint16_t index, uint32_t value);
extern void sub_0800266DC(uint16_t record_index, uint32_t pointer_value);
extern void sub_0800266F8(int32_t value);
extern void sub_080026728(uint32_t a, uint32_t b, uint32_t c);
extern void sub_08002660C(void);
extern void sub_0800726C4(void);
extern void sub_080069270(void);
extern void sub_0800011F8(void);
extern void sub_0800063FC(void);
extern void sub_08000D8A8(void);
extern void sub_080007D10(void);
extern void sub_0800139AC(void);
extern void sub_080001964(void);
extern void sub_0800126E8(void);
extern void sub_080013710(void);
extern void sub_08001053C(void);
extern void sub_08000D908(void);
extern void sub_0800069D8(void);
extern void sub_080005540(void);
extern void sub_08000A154(void);
extern void sub_080012058(void);
extern void sub_080009CDC(void);
extern void sub_0800548CC(void);
extern void sub_08007CB8C(void);
extern void sub_08008ACCC(void);

void frame_update_dispatcher_080001D0(void) {
    sub_0800011F8();
    sub_0800063FC();
    sub_08000D8A8();
    sub_080007D10();
    sub_0800139AC();
    sub_080001964();
    sub_0800126E8();
    sub_080013710();
    sub_08001053C();

    if (get_indexed_value_08026908(8) != 1) {
        sub_08002660C();
    }

    sub_08000D908();
    sub_0800069D8();
    sub_080005540();
    sub_08000A154();
    sub_080012058();
    sub_080009CDC();
    sub_0800548CC();

    if (get_indexed_value_08026908(8) != 1) {
        sub_0800726C4();
    }
    if (get_indexed_value_08026908(8) != 1) {
        sub_080069270();
    }

    sub_08007CB8C();
    sub_08008ACCC();
    sub_0800266DC(0, 0x02003200u);
    set_indexed_value_080268B4(0, 0x55555555u);
    set_indexed_value_080268B4(1, 0x55555555u);
    set_indexed_value_080268B4(2, 0x55555555u);
    set_indexed_value_080268B4(3, 0x55555555u);
    sub_0800266F8(get_indexed_value_08026908(4));
    sub_080026728(0, 0, 0);
}
