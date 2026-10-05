/*
 * Behavior-level reconstruction of the per-frame dispatcher at ROM 0x080001D0.
 * Most subsystem callees retain address-based names pending further analysis.
 */
#include <stdint.h>

extern int32_t get_indexed_value_08026908(uint16_t index);
extern void set_indexed_value_080268B4(uint16_t index, uint32_t value);
extern void sub_080266DC(uint16_t record_index, uint32_t pointer_value);
extern void sub_080266F8(int32_t value);
extern void sub_08026728(uint32_t a, uint32_t b, uint32_t c);
extern void initialize_indexed_storage_0802660C(void);
extern void initialize_runtime_pointer_roots_080726C4(void);
extern void initialize_secondary_runtime_block_08069270(void);
extern void sub_080011F8(void);
extern void sub_080063FC(void);
extern void sub_0800D8A8(void);
extern void sub_08007D10(void);
extern void sub_080139AC(void);
extern void sub_08001964(void);
extern void sub_080126E8(void);
extern void sub_08013710(void);
extern void sub_0801053C(void);
extern void sub_0800D908(void);
extern void sub_080069D8(void);
extern void sub_08005540(void);
extern void sub_0800A154(void);
extern void sub_08012058(void);
extern void sub_08009CDC(void);
extern void sub_080548CC(void);
extern void sub_0807CB8C(void);
extern void sub_0808ACCC(void);

void frame_update_dispatcher_080001D0(void) {
    sub_080011F8();
    sub_080063FC();
    sub_0800D8A8();
    sub_08007D10();
    sub_080139AC();
    sub_08001964();
    sub_080126E8();
    sub_08013710();
    sub_0801053C();

    if (get_indexed_value_08026908(8) != 1) {
        initialize_indexed_storage_0802660C();
    }

    sub_0800D908();
    sub_080069D8();
    sub_08005540();
    sub_0800A154();
    sub_08012058();
    sub_08009CDC();
    sub_080548CC();

    if (get_indexed_value_08026908(8) != 1) {
        initialize_runtime_pointer_roots_080726C4();
    }
    if (get_indexed_value_08026908(8) != 1) {
        initialize_secondary_runtime_block_08069270();
    }

    sub_0807CB8C();
    sub_0808ACCC();
    sub_080266DC(0, 0x02003200u);
    set_indexed_value_080268B4(0, 0x55555555u);
    set_indexed_value_080268B4(1, 0x55555555u);
    set_indexed_value_080268B4(2, 0x55555555u);
    set_indexed_value_080268B4(3, 0x55555555u);
    sub_080266F8(get_indexed_value_08026908(4));
    sub_08026728(0, 0, 0);
}
