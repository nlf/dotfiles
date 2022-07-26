from kittens.tui.handler import result_handler

def main(args):
    pass

@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    window = boss.window_id_map.get(target_window_id)
    if window is None:
        return

    direction = args[1]

    neighbors = boss.active_tab.current_layout.neighbors_for_window(window, boss.active_tab.windows)
    current_window_id = boss.active_tab.active_window

    left_neighbors = neighbors.get('left')
    right_neighbors = neighbors.get('right')
    top_neighbors = neighbors.get('top')
    bottom_neighbors = neighbors.get('bottom')

    if direction == 'left' and (left_neighbors and right_neighbors):
        boss.active_tab.resize_window('narrower', 1)
    elif direction == 'left' and left_neighbors:
        boss.active_tab.resize_window('wider', 1)
    elif direction == 'left' and right_neighbors:
        boss.active_tab.resize_window('narrower', 1)
    elif direction == 'right' and (left_neighbors and right_neighbors):
        boss.active_tab.resize_window('wider', 1)
    elif direction == 'right' and left_neighbors:
        boss.active_tab.resize_window('narrower', 1)
    elif direction == 'right' and right_neighbors:
        boss.active_tab.resize_window('wider', 1)
    elif direction == 'up' and (top_neighbors and bottom_neighbors):
        boss.active_tab.resize_window('shorter', 1)
    elif direction == 'up' and top_neighbors:
        boss.active_tab.resize_window('taller', 1)
    elif direction == 'up' and bottom_neighbors:
        boss.active_tab.resize_window('shorter', 1)
    elif direction == 'down' and (top_neighbors and bottom_neighbors):
        boss.active_tab.resize_window('taller', 1)
    elif direction == 'down' and top_neighbors:
        boss.active_tab.resize_window('shorter', 1)
    elif direction == 'down' and bottom_neighbors:
        boss.active_tab.resize_window('taller', 1)
