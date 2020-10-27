let g:quickrun_config = {
\ '_': {
\   'runner': 'vimproc',
\   'runner/vimproc/sleep': 10,
\   'runner/vimproc/updatetime': 500,
\   'outputter/buffer/split': ':botright 8sp',
\   'outputter/buffer/close_on_empty': 1,
\   'hook/echo/enable' : 0,
\   'hook/echo/output_success': '> No Errors Found.',
\   'hook/back_window/enable' : 1,
\   'hook/back_window/enable_exit': 1,
\   'hock/close_buffer/enable_hock_loaded': 1,
\   'hock/close_buffer/enable_success': 1,
\   'hook/qfstatusline_update/enable_exit': 1,
\   'hook/qfstatusline_update/priority_exit': 4,
\ },
\}
