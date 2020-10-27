let g:increment_activator_filetype_candidates = {
\ '_': [
\   ['info', 'warning', 'notice', 'error', 'success'],
\   ['mini', 'small', 'medium', 'large', 'xlarge', 'xxlarge'],
\   ['static', 'absolute', 'relative', 'fixed', 'sticky'],
\   ['height', 'width'],
\   ['left', 'right', 'top', 'bottom'],
\   ['enable', 'disable'],
\   ['enabled', 'disabled'],
\   ['should', 'should_not'],
\   ['be_file', 'be_directory'],
\   ['div', 'span'],
\   ['column', 'row'],
\   ['start', 'end'],
\   ['head', 'tail'],
\   ['get', 'post'],
\   ['margin', 'padding'],
\   ['primary', 'secondary', 'tertiary'],
\   ['development', 'staging', 'production'],
\ ],
\ 'ruby': [
\   ['if', 'unless'],
\   ['nil', 'empty', 'blank'],
\   ['string', 'text', 'integer', 'float', 'datetime', 'timestamp', 'timestamp'],
\ ],
\ 'javascript': [
\   ['const', 'let'],
\   ['props', 'state'],
\ ],
\ 'git-rebase-todo': [
\   ['pick', 'reword', 'edit', 'squash', 'fixup', 'exec'],
\ ],
\}
