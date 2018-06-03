;; file to run tests on, ignore it
(setq ws-current-workspace ?a)
(print ws-current-workspace)
(ws-save)
(set-window-configuration (plist-get ws-workspaces '?a))
(set-window-configuration (ws-get-workspace))
(setq ws-fullscreen nil)

(global-set-key (kbd "M-<SPC>") 'ws-switch)
(global-set-key (kbd "M-F") 'ws-toggle-fullscreen)
