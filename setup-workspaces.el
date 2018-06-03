(global-set-key (kbd "M-j") 'ws-switch)
(global-set-key (kbd "M-J") 'ws-toggle-fullscreen)
(setq-default mode-line-format (list '(:eval ws-mode-line-string) mode-line-format))
