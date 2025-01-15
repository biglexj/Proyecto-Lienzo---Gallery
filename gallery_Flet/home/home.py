import flet as ft

def HomeScreen(page):
    
    navigation = ft.Tabs(
        selected_index=0,
        tabs=[
            ft.Tab(text="Inicio"),
            ft.Tab(text="Fotos"),
            ft.Tab(text="Videos"),
            ft.Tab(text="Música"),
            ft.Tab(text="Archivos")
        ]
    )

    page.add(navigation)
