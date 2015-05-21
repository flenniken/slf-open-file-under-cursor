
(defun slf-open-file-under-cursor()
"Open the file under the cursor and go to the specified line number. 

The current line is parsed to find the file and line
number. Currently 4 file and line formats are supported:

  filename:10:...
  ... in filename line 20...
  ...File \"filename\" line 30...
  ...:basename(40):...

Filename is either a full path or a filename relative to the
current directory.

The fourth verion, \":basename(40)\" supports filenames without
path information. The basename is searched in the base folder and
its subfolders to find the file. It uses the system find command
to search the folder.
"
  (interactive)
  (let (filename line result)

    ;; Get the filename and line under the cursor.
    (setq result (slf-file-under-cursor))

    (when (not result)
      (error "No filename found under the cursor."))
    (setq filename (car result))
    (setq line (nth 1 result))

    (when (not (file-exists-p filename))
      (error "File not found: %s(%s)" filename line))

    ; Open the file and go to the line.
    (message "%s(%s)" filename line)
    (find-file filename)
    (when line
      (goto-char (point-min))
      (forward-line (1- (string-to-number line))))))


(defun slf-file-under-cursor()
" Return the file and line number under the cursor.

Return a list with the filename and line, or nil when not found.
"
  ;; If there is a selection, use that as the filename (no line).
  (let (result string)
    (if mark-active
      (setq result (list (buffer-substring-no-properties (mark) (point)) nil))
      (save-excursion
        ;; Get the current line as a string.
        (let (end)
          (end-of-line)
          (setq end (point))
          (beginning-of-line)
          (setq string (buffer-substring-no-properties (point) end)))
        ;; (message "string = %s" string)

        ;; Loop though the line patterns. Stop when the first one
        ;; returns a filename.
        (let (functions fun)
          (setq functions (list 'slf-match1 'slf-match2 'slf-match3 'slf-match4-path))
          (setq result nil)
          (while (and (not result) functions)
              (setq fun (car functions))
              (setq result (funcall fun string))
              (setq functions (cdr functions))))))
    result))


(defun slf-matcher(pattern string)
"Parse the given string and return a list containing a filename and line number.
"
  (if (string-match pattern string)
    (list (match-string 1 string) (match-string 2 string))
    nil))


(defun slf-match1(string)
"
./Macintosh/Mac_Terminal.txt:6:Created Friday 20 January 2012
filename:71:...
"
  (slf-matcher "^\\(.*\\):\\([0-9]*\\):" string))


(defun slf-match2(string)
"
...File \"filename\"...line 123 ...
"
  (slf-matcher "File \"\\(.*\\)\".*line \\([0-9]*\\)" string))


(defun slf-match3(string)
"
0.5:hd58: called from item_form_cgi in /inet/var_local/git-sandboxes/dev-sflennik1/python/printra/sossite/ItemFormCGI.py line 106
"
  (slf-matcher " in \\(.*\\) line \\([0-9]*\\)" string))
 
(defun slf-match4(string)
  (slf-matcher ":\\([^:]*\\)(\\([0-9]*\\)):" string))

(defun slf-match4-path(string &optional folder)
"This match method finds a basename in the given string then it
looks for the basename in the given folder. It returns a list
with the full path to the file and the line number, or nil when
not found.

When the root folder is not specified it uses
slf-find-root-folder.

Examples:
...:basename(linenum):...
3.4:mh42:gadgets.py(147): template file: tmpls/header
asafd:emacs(22): test line
"
  (interactive "sstring: \nDfolder: ")
  (let (result ret)
    (setq result (slf-match4 string))
    (message "result = %s" result)
    (setq ret nil)
    (when result
      ;; When the folder is not specified, look or prompt for it.
      (when (or (not folder) (equal folder ""))
        (when (fboundp 'slf-find-root-folder)
          (setq folder (slf-find-root-folder)))
        ;; (message "root folder = %s" folder)
      )
      (when folder
        ;; Make sure the specifed folder exists.
        (when (or (not (file-exists-p folder)) (equal folder ""))
          (error (format "'%s' folder does not exist." folder)))
        ;; Look for the basename in the root folder.
        (setq path (slf-find-basename folder (car result)))
        (if path
          (setq ret (list path (nth 1 result)))
          (setq ret nil))))
    (when (version<= "24" emacs-version)
      (when (called-interactively-p 'interactive)
        (message "ret=%s" ret)))
    ret))

(defun slf-find-basename(folder basename)
"Find the given basename in the given folder and return the
location of the file if found, or nil when not found.
"
  (interactive "Dfolder: \nsbasename: ")
  (let (command result path)
    ;; Run the find command and get the first file found.
    (setq command (concat "find -L " folder " -name " basename))
    (setq result (shell-command-to-string command))
    (setq path (nth 0 (split-string result "\n" t)))
    (when (version<= "24" emacs-version)
      (when (called-interactively-p 'interactive)
        (message "path='%s'" path)))
    path))
