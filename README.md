# slf-open-file-under-cursor 
`slf-open-file-under-cursor' is an emacs command which opens the file
under the cursor and goes to the specified line number.

The command parses the current line to extract the filename and
line number. Then it opens the file and goes to the line.

The command supports four common file/line formats generated by grep,
a couple stack traces and logging.

Line formats:

1.  filename:10:...
2.  ... in filename line 20...
3.  ...File \"filename\" line 30...
4.  ...:basename(40):...

Filename is either a full path or a filename relative to the
current directory.

The fourth verion, \":basename(40)\", supports filenames without
path information. The basename is searched in the base folder and
its subfolders to find the file. It uses the system find command
to search the folder.

You can add support for other formats by adding a regular expression and
a few lines of code.

Install
=======

To install, copy the `slf-open-file-under-cursor.el' file to your emacs load path
and assign a key to slf-open-file-under-cursor.

    (load-file "~/.emacs.d/slf-open-file-under-cursor.el")
    (global-set-key "\M-o" 'slf-open-file-under-cursor)
