# Display info pane whenever possible akin to "verbose mode"; Helps to learn commands
set-option global autoinfo command|onkey|normal

# Indent with 2 spaces
set-option global indentwidth 2

# Tab characters should take up 2 spaces
set-option global tabstop 2

# Always keep 10 lines visible above/below cursor; 0 cols because softwrap enabled
set-option global scrolloff 10,0

# "Hack" by escaping to shell to use brace expansion.
# Do this to declare default grep options, otherwise kakoune forwards the literal string "--exclude-dir={foo,bar}"
eval %sh{
  exclude_dirs=`printf '%s ' --exclude-dir={node_modules,.git,build,dist,builds}`
  exclude_files=`printf '%s ' --exclude=\*.{svg,map,lock}`
  printf "declare-option str grep_ignore_patterns \"$exclude_dirs $exclude_files\""
}

# Custom grep (no access to aliases; also no newlines in string)
set-option global grepcmd "grep -RHn -C 3 %opt{grep_ignore_patterns}"

# Change grep highlight colors (90% copied from rc/grep.kak)
hook -group grep-highlight global WinSetOption filetype=grep %{
  remove-highlighter window/grep
  add-highlighter window/grep group
  face window Default bright-black,default
  add-highlighter window/grep/ regex "^((?:\w:)?[^:\n]+):(\d+):(\d+)?([^\n]+)" 1:bright-cyan 2:bright-yellow 3:bright-yellow
  add-highlighter window/grep/ regex "^((?:\w:)?[^:\n]+:\d+(\d+)?)([^\n]+)" 1:default,black 2:default,black 3:bright-white,black
  add-highlighter window/grep/ line %{%opt{grep_current_line}} bright-red+b
  hook -once -always window WinSetOption filetype=.* %{ remove-highlighter window/grep }
}

# Display the status bar on top, allow selections using mouse cursor
set -add global ui_options terminal_set_title=true
set -add global ui_options terminal_status_on_top=true
set -add global ui_options terminal_assistant=cat
set -add global ui_options terminal_enable_mouse=true
set -add global ui_options terminal_padding_fill=true
set -add global ui_options terminal_padding_char=▚
# Line number config
add-highlighter global/ number-lines -relative -hlcursor -separator '  ' -cursor-separator '->' -min-digits 3

# Highlight trailing whitespace
add-highlighter global/ regex \h+$ 0:Error

# Highlight search matches
add-highlighter global/ dynregex "%reg{/}" 0:+ub

# Softwrap long lines
add-highlighter global/ wrap -word -indent

###################
## BEGIN KEYMAPS ##
###################

# Repurpose visual mode for inner object selection
map global normal v "<a-i>"

# IDE-like create new cursor (up|down) at current column
# ...embarrasingly took a long time to figure this out
map global normal <a-j> "C"

# Quickly change buffers
map global normal <a-1> ": bp<ret>" -docstring "Previous buffer"
map global normal <a-2> ": bn<ret>" -docstring "Next buffer"

# Select word under cursor -> enter user mode (used to chain like many IDE's ctrl+d)
map global normal D "<a-i>w*<space>"

# Continue selection from search register -> re-enter user mode
# (fyi  %reg{} in the docstring doesnt interpolate properly)
map global user D "N<space>" -docstring "Select next matching reference %reg{slash}"

# Replace current selection(s) with yank register -> re-enter user mode
map global user R "R<space>" -docstring "Replace selections with yank register %reg{dquote}"

# Normally enter insert mode from user mode
map global user i "i" -docstring "Enter insert mode (start)"
map global user a "a" -docstring "Enter insert mode (end)"
map global user c "c" -docstring "Change selected text"

# OSX text deletion to beginning of word, keeping character under cursor
map global normal <a-backspace> "hb<a-d>"
map global insert <a-backspace> "<esc>hb<a-d>i"

# goto BOL and EOL... still can't kick this habit
map global normal <home> "gh"
map global normal <end> "gl"

# Flip semicolon and option-semicolon behavior (anchor flip, reduce cursor respectively)
map global normal <semicolon> "<a-;>"
map global normal <a-semicolon> ";"

# Select whole lines downward (nice to combine with line count: eg. 15X to select 15 full lines
map global normal X "Jx"

# OS clipboard
map global user y "<a-|> pbcopy<ret>" -docstring "yank selection into OS clipboard"
map global user p "d! pbpaste<ret>" -docstring "paste from OS clipboard"

# Open filetree at current project dir
map global user , ":filetree -consider-gitignore -dirs-first<ret>" -docstring "leave buffer to navigate filetree"

# Comment line
map global user / ":comment-line<ret>" -docstring "Comment lines w/ a selection"

# Grep find
map global normal F ":grep " -docstring "Find all"

# Enter tabs mode
map global normal t ": enter-user-mode tabs<ret>" -docstring 'tabs mode'

####################
## BEGIN COMMANDS ##
####################

# Debug command used during command development
define-command -hidden -docstring "duplicate A to B" _dup_current %{
  eval %sh{
    cp $kak_buffile $kak_text
    source_file=`basename $kak_buffile`
    printf "edit $kak_text"
    printf ';; echo "%s"' "Copied $source_file to $kak_text"
  }
}

# Duplicate current file
define-command -docstring "duplicate current buffer" duplicate %{
  prompt -init "%val{buffile}" "Duplicate to: " _dup_current
}

# Minimal fuzzy find
define-command find -params 1 -shell-script-candidates %{ find . -type f } %{ edit %arg{1} }

# Alias fuzzy find to p (IDE thing, don't ask)
alias global p find

# Shortcut to quickly exit the editor
define-command -docstring "save and close buffer" x "write-all; delete-buffer"

# define-command -params .. -docstring %{
#   tail [<arguments>]: tail utility wrapper
#   All arguments are forwarded to the tail utility
# } tail %{ evaluate-commands %sh{
#   output=$(mktemp -d "${TMPDIR:-/tmp}"/kak-tail.XXXXXXXX)/fifo
#   mkfifo ${output}
#   # run command detached from the shell
#   { tail -f "$@" > ${output} } > /dev/null 2>&1 < /dev/null &
#   # Open the file in Kakoune and add a hook to remove the fifo
#   echo "edit! -fifo ${output} *tail*
#      hook buffer BufClose .* %{ nop %sh{ rm -r $(dirname ${output})} }"
# }}

# Tab completion ^______^ (mawww/kakoune#1327)
hook global InsertCompletionShow .* %{
  try %{
    # this command temporarily removes cursors preceded by whitespace;
    # if there are no cursors left, it raises an error, does not
    # continue to execute the mapping commands, and the error is eaten
    # by the `try` command so no warning appears.
    execute-keys -draft 'h<a-K>\h<ret>'
    map window insert <tab> <c-n>
    map window insert <s-tab> <c-p>
    hook -once -always window InsertCompletionHide .* %{
      map window insert <tab> <tab>
      map window insert <s-tab> <s-tab>
    }
  }
}

# Init plug.kak
source "%val{config}/plugins/plug.kak/rc/plug.kak"
plug "andreyorst/plug.kak" noload

# Filetree
plug "occivink/kakoune-filetree" config %{
  set-option global filetree_indentation_level 1
  face global FileTreeDirColor cyan,default+b
  face global FileTreeFileName default,default+F
  face global FileTreeOpenFiles black,green+F

  # TODO: Add custom highlighters regexps for specific file types
}

# Tabs vs spaces
plug "andreyorst/smarttab.kak" config %{
  hook global WinSetOption filetype=(ruby|javascript|typescript|kak|sh|markdown|html|svelte) expandtab
}

# LSP
eval %sh{ kak-lsp --kakoune -s $kak_session }
hook global WinSetOption filetype=(ruby|typescript|javascript|svelte) %{
  lsp-enable-window

  # Suggested default maps
  map global user l %{:enter-user-mode lsp<ret>} -docstring "LSP mode"
  map global insert <tab> '<a-;>:try lsp-snippets-select-next-placeholders catch %{ execute-keys -with-hooks <lt>tab> }<ret>' -docstring 'Select next snippet placeholder'
  map global object a '<a-semicolon>lsp-object<ret>' -docstring 'LSP any symbol'
  map global object <a-a> '<a-semicolon>lsp-object<ret>' -docstring 'LSP any symbol'
  map global object e '<a-semicolon>lsp-object Function Method<ret>' -docstring 'LSP function or method'
  map global object k '<a-semicolon>lsp-object Class Interface Struct<ret>' -docstring 'LSP class interface or struct'
  map global object d '<a-semicolon>lsp-diagnostic-object --include-warnings<ret>' -docstring 'LSP errors and warnings'
  map global object D '<a-semicolon>lsp-diagnostic-object<ret>' -docstring 'LSP errors'

  # Enable semantic tokens for highlighting
  hook window -group semantic-tokens BufReload .* lsp-semantic-tokens
  hook window -group semantic-tokens NormalIdle .* lsp-semantic-tokens
  hook window -group semantic-tokens InsertIdle .* lsp-semantic-tokens
  hook -once -always window WinSetOption filetype=.* %{
    remove-hooks window semantic-tokens
  }

  # Auto-show definitions on hover
  lsp-auto-hover-enable
  # Definition toolbox anchored to cursor (as opposed to kakoune menu bar)
  set-option global lsp_hover_anchor true
  set-option global lsp_hover_max_lines 30

  # Show diagnostics per line
  lsp-inlay-diagnostics-enable global

  # Flag lines with diagnostics
  lsp-diagnostic-lines-enable global
  set-option global lsp_diagnostic_line_error_sign '▓'
  set-option global lsp_diagnostic_line_hint_sign '?'
  set-option global lsp_diagnostic_line_info_sign 'i'
  set-option global lsp_diagnostic_line_warning_sign '▒'

  # Show/suggest code actions
  set-option global lsp_auto_show_code_actions true

  # Enable inlay hints (LSP 3.17 proposal)
  # lsp-inlay-hints-enable global

  # Show references to token under cursor when pausing (normal mode only)
  set-option global lsp_auto_highlight_references true
}

# Tabs
plug "enricozb/tabs.kak" config %{
  set-option global tabs_modelinefmt '%val{cursor_line}:%val{cursor_char_column} {{mode_info}} '
  set-option global tabs_options --minified
}

# Apply theme at the end to take priority over previously-defined faces
colorscheme monokai
