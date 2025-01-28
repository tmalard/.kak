# Display info pane whenever possible akin to "verbose mode"; Helps to learn commands
set-option global autoinfo command|onkey|normal

# Indent with 2 spaces
set-option global indentwidth 2

# Tab characters should take up 2 spaces
set-option global tabstop 2

# Always keep 10 lines visible above/below cursor; 0 cols because softwrap enabled
set-option global scrolloff 10,0

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

# Apply theme at the end to take priority over previously-defined faces
colorscheme monokai
