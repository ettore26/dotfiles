; Fold each HTTP request section (### separator blocks).
; Only sections that start with a separator: the parser also wraps the
; variables/comments preamble into separator-less sections split at odd
; points, which would swallow the blank lines between groups.
; #trim! drops trailing blank lines so the gap between sections stays visible.
((section (request_separator)) @fold
  (#trim! @fold))

; Fold pre-request (< {% %}) and response-handler (> {% %}) script blocks
((script) @fold
  (#trim! @fold))
