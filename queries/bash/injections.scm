((comment) @injection.content
  (#set! injection.language "comment"))

((regex) @injection.content
  (#set! injection.language "regex"))

; Neovim-AIDE compatibility override:
; nvim-treesitter's legacy master branch uses #downcase! here, which crashes
; under Neovim 0.12.2. Current upstream removes that directive.
(heredoc_redirect
  (heredoc_body) @injection.content
  (heredoc_end) @injection.language)

; printf 'format'
((command
  name: (command_name) @_command
  .
  argument: [
    (string) @injection.content
    (concatenation
      (string) @injection.content)
    (raw_string) @injection.content
    (concatenation
      (raw_string) @injection.content)
  ])
  (#eq? @_command "printf")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.include-children)
  (#set! injection.language "printf"))

; printf -v var 'format'
((command
  name: (command_name) @_command
  argument: (word) @_arg
  .
  (_)
  .
  argument: [
    (string) @injection.content
    (concatenation
      (string) @injection.content)
    (raw_string) @injection.content
    (concatenation
      (raw_string) @injection.content)
  ])
  (#eq? @_command "printf")
  (#eq? @_arg "-v")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.include-children)
  (#set! injection.language "printf"))

; printf -- 'format'
((command
  name: (command_name) @_command
  argument: (word) @_arg
  .
  argument: [
    (string) @injection.content
    (concatenation
      (string) @injection.content)
    (raw_string) @injection.content
    (concatenation
      (raw_string) @injection.content)
  ])
  (#eq? @_command "printf")
  (#eq? @_arg "--")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.include-children)
  (#set! injection.language "printf"))

((command
  name: (command_name) @_command
  .
  argument: [
    (string)
    (raw_string)
  ] @injection.content)
  (#eq? @_command "bind")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.include-children)
  (#set! injection.language "readline"))
