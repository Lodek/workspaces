
;ws- prefix to avoid namespace conflicts
(defvar ws-fullscreen nil
  "Flag for whether or not the current workspace is in fullscreen mode. Values: nil or true")
(defvar ws-startup-workspace ?a
  "Defines the workspace the package defaults to during init time")
(defvar ws-default-windowconf
  (save-window-excursion
    (delete-other-windows)
    (switch-to-buffer "*scratch*")
    (current-window-configuration))
"default window configuration (single window pointing to scratch buffer)")
(defvar ws-current-workspace ws-startup-workspace
  "Keeps track of the current workspace being used")
(defvar ws-workspaces nil
  "Property list (hashtable) of workspaces and its respective configurations")
(defvar ws-fullscreen-workspaces nil
  "Property list (hashtable) of fullscreen workspaces and its respective configurations")
(defvar ws-mode-line-string (format "[%c]" ws-startup-workspace)
  "Variable that contains the string that will be added to the mode line. Its format is:
[*] ([F])? -> where * is a single character representing the current workspace and [F] will be set if in fullscreen is t")

;; User functions
(defun ws-switch (workspace-symbol)
  "Switch to a different workspace defined by workspace-symbol. User is prompted for a single character to use as the symbol.
Function stores current window configuration then switches to the selected workspace"
  (interactive "cWorkspace character")
  (ws-save)
  (setq ws-current-workspace workspace-symbol)
  (set-window-configuration (ws-get-workspace))
  (ws-update-modeline-string))

(defun ws-toggle-fullscreen ()
  "If ws-fullscreen is nil: stores te window configuration, makes the selected window full screen (ie - delete other windows) and sets ws-fullscreen.
If ws-fullscreen is t, loads the stored workspace under ws-workspaces and sets ws-fullscreen to nil instead."
  (interactive)
  (if ws-fullscreen
      (progn (set-window-configuration (ws-get-from-workspaces ws-current-workspace))
             (setq ws-fullscreen nil)
             (ws-save))
    (ws-save)
    (setq ws-fullscreen t)
    (delete-other-windows)
    (ws-save))
  (ws-update-modeline-string))

;; Implementation functions
(defun ws-save ()
  "Utilizes the variables ws-fullscreen and ws-current-workspace to store the current workspace configuration
to the correct plist. Takes no arguments, instead modifies the global variables"
  (let (window-conf)
    (setq window-conf (current-window-configuration))
    (if ws-fullscreen
        (setq ws-fullscreen-workspaces (plist-put ws-fullscreen-workspaces ws-current-workspace window-conf))
      ;saves current window-conf to workspaces and sets nil on plist for fullscreen-workspaces
      (setq ws-fullscreen-workspaces (plist-put ws-fullscreen-workspaces ws-current-workspace nil))
      (setq ws-workspaces (plist-put ws-workspaces ws-current-workspace window-conf)))))

(defun ws-get-workspace ()
  "Utilizes the variables ws-fullscreen and ws-current-workspace to retrieve the correct workspace configuration
from the correct plist. If workspace doesn't exist, returns default
Takes no arguments, returns the window configuration to be used"
  (let ((window-conf (ws-get-from-fullscreen ws-current-workspace)))
    ;window-conf nil means workspace wasn't full screen
    (if window-conf (setq ws-fullscreen t)
      (setq window-conf (ws-get-from-workspaces ws-current-workspace))
      (setq ws-fullscreen nil))
    ;if window-conf still nil, workspace was never used before -> returns default window configuration
    (if window-conf window-conf
      ws-default-windowconf)))

(defun ws-get-from-fullscreen (workspace)
  "Helper function that returns window configuration saved under ws-fullscreen-workspaces for workspace"
  (plist-get ws-fullscreen-workspaces workspace))

(defun ws-get-from-workspaces (workspace)
  "Helper function that returns window configuration saved under ws-workspaces for workspace"
  (plist-get ws-workspaces workspace))

(defun ws-update-modeline-string ()
  "Function that updates ws-mode-line-string for the new workspace"
  (let (str)
    (setq str (format "[%c]" ws-current-workspace))
    (if ws-fullscreen
        (setq str (format "%s [F]" str)))
    (setq ws-mode-line-string str)))
  
