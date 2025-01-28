# Monokai with 18 termcolors (default macos seems to support 16 + 4... BG+TEXT+BOLD+SELECTION)
# - Values designated with `...` are kept as the system default
# - Text in parens describes the face's usage in kak
#
# Color map setup as follows:
# - background:     #3ff403a (default background)
# - text:           #f8f8f2  (default foreground)
# - bold text:      ...
# - selection:      ...
#
# - black           #000000 (insert mode selections, normal cursor text)
# - bright-black    #74705d (comment)
# - red             #f92472 (keyword, meta)
# - bright-red      #f83535 (diagnostic errors, EOL)
# - green:          #a6e22c (attribute)
# - bright-green    ...
# - yellow          #e7db74 (string)
# - bright-yellow   #fd9621 (parameters)
# - blue            ...     (normal primary selection)
# - blue-bright     ...
# - magenta         #ac80ff (value, variable)
# - bright-magenta  ...
# - cyan            #67d8ef (functions, stdlib modules)
# - bright-cyan     ...
# - white           ...     (normal secondary cursor bg)
# - bright-white    ...     (normal primary cursor bg, normal secondary selection text)

# LSP settings can later override these

# For Code
face global value magenta
face global type green
face global type_definition cyan+i
face global variable default
face global module cyan
face global function cyan
face global string yellow
face global parameter bright-yellow
face global keyword red
face global operator bright-red+b
face global attribute green
face global comment bright-black
face global documentation comment
face global meta red
face global builtin green # shell builtin

# For markup (currently unmodified)
face global title blue
face global header cyan
face global mono green
face global block magenta
face global link cyan
face global bullet cyan
face global list yellow

# For UI
face global Default default,default

# Normal mode
face global PrimaryCursor      black,bright-white+F
face global SecondaryCursor    black,white+F

face global PrimarySelection   default,blue+F
face global SecondarySelection bright-white,bright-black

face global PrimaryCursorEol   black,cyan+F
face global SecondaryCursorEol PrimaryCursorEol

# Insert mode
hook global ModeChange .*:.*:insert %{
  # Theme: insert cursors turn bg black
  set-face window LineNumberCursor   default,black
  set-face window PrimaryCursor      default,black+r
  set-face window PrimarySelection   default,black
  set-face window SecondarySelection default,black
  set-face window PrimaryCursorEol   black,yellow
}

# Revert colors when leaving insert -> normal mode
hook global ModeChange .*:insert:.* %{
  try %{
    unset-face window LineNumberCursor
    unset-face window PrimaryCursor
    unset-face window PrimarySelection
    unset-face window SecondarySelection
    unset-face window PrimaryCursorEol
  }
}

face global LineNumbers default,default+d
face global LineNumberCursor default,default+r
face global LineNumberCursorWrapped default,default+di
face global MenuForeground white,blue
face global MenuBackground blue,white
face global MenuInfo cyan
face global Information black,yellow
face global Error black,red
# face global DiagnosticError red
# face global DiagnosticWarning yellow
face global StatusLine cyan,default
face global StatusLineMode yellow,default
face global StatusLineInfo magenta,default
face global StatusLineValue green,default
face global StatusCursor black,cyan
face global Prompt yellow,default
face global MatchingChar default,default+b
face global Whitespace default,default+fd
face global BufferPadding black,default

# For LSP infobox (unmodified)
# face global InfoDefault               Information
# face global InfoBlock                 Information
# face global InfoBlockQuote            Information
# face global InfoBullet                Information
# face global InfoHeader                Information
# face global InfoLink                  Information
# face global InfoLinkMono              Information
# face global InfoMono                  Information
# face global InfoRule                  Information
# face global InfoDiagnosticError       Information
# face global InfoDiagnosticHint        Information
# face global InfoDiagnosticInformation Information
# face global InfoDiagnosticWarning     Information

# For LSP matching reference
face global Reference                 default,default+bu

# For LSP line hints
face global LineFlagError             bright-red,default+rd
# face global LineFlagHint              Information
# face global LineFlagInfo              Information
# face global LineFlagWarning           Information

# For LSP inlay hints (unmodified)
# face global InlayHint                 Information

# For LSP inline diagnostics
face global DiagnosticError           bright-red
# face global DiagnosticHint            Information
# face global DiagnosticInfo            Information
face global DiagnosticWarning         Information

# For LSP code lenses (unmodified)
# face global InlayCodeLens             bright-red+b
