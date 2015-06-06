
(ert-deftest test-slf-match1 ()
  "Test slf-match1"
  (should (myequal (slf-match1 "f:8:") (list "f" "8")))
  (should (myequal (slf-match1 "filename:89:") (list "filename" "89")))
  (should (myequal (slf-match1 "f:8") nil))
  (should (myequal (slf-match1 "filename:88:asdaf") (list "filename" "88"))))


(ert-deftest test-slf-match2 ()
  "Test slf-match2"
  (should (myequal (slf-match2 "File \"filename\" line 123") (list "filename" "123")))
  (should (myequal (slf-match2 "File \"f\" line 1") (list "f" "1")))
  (should (myequal (slf-match2 "asdf File \"filename\" line 123 asdfasdf") (list "filename" "123")))
  (should (myequal (slf-match2 "ile \"filename\" line 123") nil)))


(ert-deftest test-slf-match3 ()
  "Test slf-match3"
  (should (myequal (slf-match3 " in filename line 65") (list "filename" "65")))
  (should (myequal (slf-match3 " in f line 6") (list "f" "6")))
  (should (myequal (slf-match3 "in in filename line 65 asdf") (list "filename" "65"))))


(ert-deftest test-slf-match4 ()
  "Test slf-match4"
  (should (myequal (slf-match4 "3.4:mh42:gadgets.py(147): template file: tmpls/header") (list "gadgets.py" "147")))
  (should (myequal (slf-match4 ":g(7): ") (list "g" "7")))
  (should (myequal (slf-match4 ":gadgets.py(147): ") (list "gadgets.py" "147"))))


(ert-deftest test-slf-match4-path ()
  "Test slf-match4-path"
  (should (myequal (slf-match4-path ":slf.el(7): " "/home/steve/.emacs.d/")
                   (list "/home/steve/.emacs.d/slf.el" "7"))))

(ert-deftest test-slf-match4-path2 ()
  "Test slf-match4-path"
  (should (myequal (slf-match4-path ":notfound.el(7): " "/home/steve/.emacs.d/") nil)))


(ert-deftest test-slf-match4-path3 ()
  "Test slf-match4-path"
  (should (myequal (slf-match4-path ":test.txt(7): ")
                   (list "/home/steve/code/slf-open-file-under-cursor/test.txt" "7"))))


(ert-deftest test-slf-find-root-folder ()
  "Test slf-find-root-folder"
  (should (myequal (slf-find-root-folder) "/home/steve/code/slf-open-file-under-cursor/")))


(ert-deftest test-slf-file-under-cursor ()
  "Test slf-file-under-cursor"

  ;; Create a test buffer with some test lines in it.

  (with-temp-buffer

    (insert
"3.4:mh42:test.txt(14): template file: tmpls/header
./Macintosh/Mac_Terminal.txt:6:Created Friday 20 January 2012
filename:71:...
...File \"filename\"...line 123 ...
0.5:hd58: called from item_form_cgi in /inet/var_local/git-sandboxes/dev-sflennik1/python/printra/sossite/ItemFormCGI.py line 106
"
    )
    (setq slf-base-folder "/home/steve/code/slf-open-file-under-cursor/")
    (goto-line 1)
    (should (myequal (slf-file-under-cursor) (list "/home/steve/code/slf-open-file-under-cursor/test.txt" "14")))

    (goto-line 2)
    (should (myequal (slf-file-under-cursor) (list "./Macintosh/Mac_Terminal.txt" "6") "line 2"))

    (goto-line 3)
    (should (myequal (slf-file-under-cursor) (list "filename" "71")))

    (goto-line 4)
    (should (myequal (slf-file-under-cursor) (list "filename" "123")))

    (goto-line 5)
    (should (myequal (slf-file-under-cursor) (list "/inet/var_local/git-sandboxes/dev-sflennik1/python/printra/sossite/ItemFormCGI.py" "106")))))



(ert-deftest test-slf-find-basename ()
  "Test slf-find-basename"
  (should (myequal (slf-find-basename "/home/steve/.emacs.d/" "emacs") "/home/steve/.emacs.d/emacs")))

(ert-deftest test-slf-find-basename2 ()
  "Test slf-find-basename"
  (should (myequal (slf-find-basename "/home/steve/.emacs.d/" "notfound") nil)))

(ert-deftest test-slf-find-basename3 ()
  "Test slf-find-basename"
  (should (myequal (slf-find-basename "/home/steve/" "emacs") "/home/steve/.emacs.d/emacs")))



(defun myequal (result expected &optional name)
" Test that result equals expected. When it doesn't, print out the
values. Return t when equal nil otherwise.
"
  (let (ret)
    (setq ret t)
    (when (not (equal result expected))
      (when name
        (message "\n%s" name))
      (message "     got: '%s'" result)
      (message "expected: '%s'" expected)
      (setq ret nil))
    ret))
