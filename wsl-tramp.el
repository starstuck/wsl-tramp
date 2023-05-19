;;; wsl-tramp.el --- TRAMP integration for WSL (Windows Susystem for Linux)

;; Copytright (C) 2023 Tom Starstuck <tom@starstuck.uk>

;; Author: Tom Starstuck <tom@starstuck.uk>
;; URL: https://github.com/starstuck/wsl-tramp
;; Keywords: wsl, tramp, convenience
;; Version: 0.1.0
;; Package-Requires: ((emacs "24"))

(defun wsl-tramp--list-distros (&optional ignored)
  ;; TODO : Fix wsl distors discovery lookup
  '(("debian") ("debian")))

;;;###autoload
(eval-after-load 'tramp
  '(progn
     (add-to-list 'tramp-methods
                  `("wsl"
                    (tramp-login-program "C:/Windows/System32/wsl.exe")
                    (tramp-login-args
                     ;; Host name/distro is always present. Can't be combined into single ("-d" "%h"), because then tramp.el
                     ;; will not detect it and will allow use only with local hostname
                     (("-d") ("%h")
                      ;; Username on the other hand is fully optional and only will be used when provided in tramp path
                      ("-u" "%u")
                      ;; The shell invocation is wrapped in another shell, just to redirect stderr to stdout. It is a
                      ;; workaround for an issue, that I have observed with wsl improperly mixing stdout and sterr stream.
                      ;;
                      ;; Sh by default is sending command output to stdout and new line prompt to stderr. Wsl is mixing these
                      ;; to single stream which emacs receive, but ocassionally that mixing will put prompt before command
                      ;; output. That will confuse and break interpreter in tramp-sh. It was observer won Win 10 v20H2
                      ;;
                      ;; It seems that mising those streams into one on the linux side resolves the problem and enforces
                      ;; right order
                      ("-e" "/bin/sh" "-c" "\"exec 2>&1" "%l" "\"")))
                    (tramp-remote-shell "/bin/sh")
                    (tramp-remote-shell-login ("-l"))
                    (tramp-remote-shell-args ("-c"))
                    (tramp-connection-timout 5)
                    ))
     (tramp-set-completion-function "wsl" '((wsl-tramp--list-distros "")))
