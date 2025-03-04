import flet as ft
from home.home import HomeScreen

def main(page: ft.Page):
    page.title = "Galería"
    page.window_width = 500
    page.window_height = 800
    HomeScreen(page)

ft.app(target=main)