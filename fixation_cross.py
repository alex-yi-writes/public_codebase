import pygame
import tkinter as tk
from tkinter import simpledialog
import sys

def main():
    # a tkinter dialogue box for user input
    root = tk.Tk()
    root.withdraw() 

    # select position dialogue
    position = simpledialog.askstring(
        "fixation cross position",
        "enter position (centre/bottom):",
        initialvalue="centre"
    )

    # select colour scheme dialogue
    colour_scheme = simpledialog.askstring(
        "colour scheme",
        "enter colour scheme (options [ScreenColour_FixXcolour]: black_white, black_grey, white_black, white_grey):",
        initialvalue="black_white"
    )

    # colours
    colour_map = {
        "black_white": ((0, 0, 0), (255, 255, 255)),
        "black_grey": ((0, 0, 0), (128, 128, 128)),
        "white_black": ((255, 255, 255), (0, 0, 0)),
        "white_grey": ((255, 255, 255), (128, 128, 128)),
    }
    if colour_scheme not in colour_map:
        colour_scheme = "black_grey"  # default

    bg_colour, cross_colour = colour_map[colour_scheme]

    # initialise pygame
    pygame.init()

    # full screen
    screen = pygame.display.set_mode((0, 0), pygame.FULLSCREEN)
    screen_width, screen_height = screen.get_size()

    # cross dimensions
    cross_width = 10
    cross_length = 50

    # cross position
    if position == "bottom":
        y_centre = int(screen_height * 0.75)
    else:
        y_centre = screen_height // 2

    def draw_cross():
        # vertical line
        pygame.draw.rect(
            screen,
            cross_colour,
            (
                screen_width // 2 - cross_width // 2,
                y_centre - cross_length // 2,
                cross_width,
                cross_length
            )
        )
        # horizontal line
        pygame.draw.rect(
            screen,
            cross_colour,
            (
                screen_width // 2 - cross_length // 2,
                y_centre - cross_width // 2,
                cross_length,
                cross_width
            )
        )

    # main loop
    running = True
    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT or (event.type == pygame.KEYDOWN and event.key == pygame.K_ESCAPE):
                running = False

        # fill screen with background colour
        screen.fill(bg_colour)
        # draw fixation cross
        draw_cross()
        # update the display
        pygame.display.flip()

    pygame.quit()
    sys.exit()

if __name__ == "__main__":
    main()
