from kittens.tui.handler import result_handler

def main(args):
    pass

def get_real_direction(request, neighbors):
    if request in ('left', 'right'):
        left_neighbors = neighbors.get('left')
        right_neighbors = neighbors.get('right')
        if request == 'left':
            return 'narrower' if ((left_neighbors and right_neighbors) or right_neighbors) else 'wider'
        elif request == 'right':
            return 'wider' if ((left_neighbors and right_neighbors) or right_neighbors) else 'narrower'
    elif request in ('up', 'down'):
        top_neighbors = neighbors.get('top')
        bottom_neighbors = neighbors.get('bottom')
        if request == 'up':
            return 'shorter' if ((top_neighbors and bottom_neighbors) or bottom_neighbors) else 'taller'
        elif request == 'down':
            return 'taller' if ((top_neighbors and bottom_neighbors) or bottom_neighbors) else 'shorter'


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    window = boss.window_id_map.get(target_window_id)
    if window is None:
        return

    request = args[1]
    neighbors = boss.active_tab.current_layout.neighbors_for_window(window, boss.active_tab.windows)
    direction = get_real_direction(request, neighbors)
    boss.active_tab.resize_window(direction, 1)
