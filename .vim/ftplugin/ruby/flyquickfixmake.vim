" .vim/ftplugin/ruby/flyquickfixmake.vim
compiler ruby
autocmd BufWritePost * silent make % 
