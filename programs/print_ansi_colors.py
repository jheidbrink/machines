#!/usr/bin/env python

ansi_color_names = ['black', 'red', 'green', 'yellow', 'blue', 'magenta', 'cyan', 'white']


def select_graphic_rendition_sequence(seq: str) -> str:
    """
    Returns an ANSI escape sequence (from the "Select Graphic Rendition" subset)

    """
    return f"\033[{seq}m"


def set_background(color_number: int) -> str:
    assert 0 <= color_number < 16
    return select_graphic_rendition_sequence(f"48;5;{color_number}")


def gen_reset_sequence() -> str:
    """
    Generates a control sequence that turns all font attributes off
    """
    return select_graphic_rendition_sequence(0)


def colored_bg(color_number: int, text: str) -> str:
    return set_background(color_number) + text + gen_reset_sequence()


def color_block(color_number: int) -> str:
    return colored_bg(color_number, "   ")


for i, color in enumerate(ansi_color_names):
    print(f"{i:02d}/{i+8:02d} {color:<9}" + color_block(i) + color_block(i + 8))
