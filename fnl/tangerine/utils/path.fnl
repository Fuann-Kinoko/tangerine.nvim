; ABOUT:
;   Provides path manipulation and indexing functions
;
; DEPENDS:
; ALL() utils[env]
(local env (require :tangerine.utils.env))
(local p {})

;; -------------------- ;;
;;        UTILS         ;;
;; -------------------- ;;
(local win32? (= _G.jit.os "Windows"))
(macro path-unify! [sub-sym]
  `(if win32?
    (: ,sub-sym :gsub "\\" "/")
    ,sub-sym))

(lambda p.match [path pattern]
  "matches 'path' against 'pattern' with support for windows."
  (: (path-unify! path) :match pattern))

(lambda p.gsub [path pattern repl]
  "substitutes 'pattern' in 'path' for 'repl' with support for windows."
  (: (path-unify! path) :gsub pattern repl))

(lambda p.shortname [path]
  "shortens absolute 'path' for better readability."
  (or (p.match path ".+/fnl/(.+)")
      (p.match path ".+/lua/(.+)")
      (p.match path ".+/(.+/.+)")))

(lambda p.resolve [path]
  "resolves 'path' to POSIX complaint path."
  (vim.fn.resolve (vim.fn.expand path)))


;; ------------------------- ;;
;;     PATH TRANSFORMERS     ;;
;; ------------------------- ;;
(local vimrc-out (-> (env.get :target) (.. "tangerine_vimrc.lua")))

(lambda esc-regex [str]
  "escapes magic characters from 'str'."
  (str:gsub "[%%%^%$%(%)%[%]%{%}%.%*%+%-%?]" "%%%1"))

(lambda p.transform-path [path [key1 ext1] [key2 ext2]]
  "changes path's parent dir and extension."
  (let [from (path-unify! (.. "^" (esc-regex (env.get key1))))
        to   (path-unify! (esc-regex (env.get key2)))
        path (path-unify! (path:gsub (.. "%." ext1 "$") (.. "." ext2)))]
       (if (path:find from)
           (path:gsub from to)
           (p.gsub path (.. "/" ext1 "/") (.. "/" ext2 "/")))))

(lambda p.target [path]
  "converts fnl:'path' to valid target path."
  (let [vimrc (env.get :vimrc)]
    (if (= path vimrc)
        vimrc-out
        (p.transform-path path [:source "fnl"] [:target "lua"]))))

(lambda p.source [path]
  "converts lua:'path' to valid source path."
  (let [vimrc (env.get :vimrc)]
    (if (= path vimrc-out)
        vimrc
        (p.transform-path path [:target "lua"] [:source "fnl"]))))


;; -------------------- ;;
;;         VIM          ;;
;; -------------------- ;;
(lambda p.goto-output []
  "open lua:target of current fennel buffer."
  (let [source (vim.fn.expand :%:p)
        target (p.target source)]
    (if (and (= 1 (vim.fn.filereadable target))
             (not= source target))
        (vim.cmd (.. "edit" target))
        :else
        (print "[tangerine]: error in goto-output, target not readable."))))


;; -------------------- ;;
;;       INDEXERS       ;;
;; -------------------- ;;
(lambda p.wildcard [dir pat]
  "expands wildcard 'pat' inside of 'dir' and return array of paths."
  (vim.fn.glob (.. dir pat) 0 1))


:return p
