; extends

; Strings passed to execute_query_pg_async(...) — positional
((call
   function: (identifier) @_func
   arguments: (argument_list . (string (string_content) @injection.content)))
 (#eq? @_func "execute_query_pg_async")
 (#set! injection.language "sql"))

; Strings passed to execute_query_pg_async(query=...) — keyword
((call
   function: (identifier) @_func
   arguments: (argument_list
     (keyword_argument
       name: (identifier) @_kwarg
       value: (string (string_content) @injection.content))))
 (#eq? @_func "execute_query_pg_async")
 (#eq? @_kwarg "query")
 (#set! injection.language "sql"))

; Strings preceded by a `# language=SQL` marker (PyCharm-style)
((comment) @_marker
 .
 (expression_statement
   (assignment right: (string (string_content) @injection.content)))
 (#match? @_marker "language=(SQL|sql)")
 (#set! injection.language "sql"))
