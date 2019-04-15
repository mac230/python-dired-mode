(defvar python-dired-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "n")   'next-line)
    (define-key map (kbd "p")   'previous-line)
    (define-key map (kbd "RET") 'python-dired-inspect-object)
    (define-key map (kbd "k")   (lambda ()
                                  (interactive)
                                  (if (string= (buffer-name) "*Python-Objects*")
                                      (kill-buffer-and-window) (kill-buffer))))
       map)
   "Keymap for python-dired-mode.")


(define-minor-mode python-dired-mode
  "Minor mode for viewing objects/functions/etc... defined for the current python session."
  :init-value nil
  :lighter " python-dired "
  :keymap python-dired-mode-map
  :global nil)


(defun python-dired ()
  "Create an rdired-like buffer that displays information on the current python session.
The information displayed in the buffer is the result of the command '%whos' in the 
inferior python process."
  (interactive)
(let ((output-buffer (get-buffer-create "*Python-Objects*"))
      (output (python-shell-send-string-no-output "%whos" (python-shell-get-process))))
  (pop-to-buffer output-buffer)
  (mark-whole-buffer)
  (delete-region (point) (mark))
  (deactivate-mark)
  (python-dired-mode)
  (princ output (current-buffer))
  (beginning-of-buffer)
  (forward-line 2)
  (message "")))


(defun python-dired-inspect-object ()
  "Create a buffer to view objects displayed in the python-dired buffer.
This command prints the output of evaluating an object/function name in
the inferior python process to a separate buffer."
  (interactive)
  (let* ((object (format "%s" (symbol-at-point)))
         (object-info (python-shell-send-string-no-output object (python-shell-get-process)))
         (output-buffer (get-buffer-create object)))
    (switch-to-buffer output-buffer)
    (python-dired-mode)
    (princ object-info (current-buffer))
    (message "")))
