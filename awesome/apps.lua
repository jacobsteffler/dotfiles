local M = {}

M.terminal = "kitty --single-instance --wait-for-single-instance-window-close"
M.editor = os.getenv("EDITOR") or "vim"
M.editor_cmd = M.terminal .. " -e " .. M.editor

return M