;; Day 8: Lisp
;; No imperative loops for extra fun!

(require :uiop)

(defun parse-input (stream list)
  (let ((line (read-line stream nil)))
    (if (null line)
      list
      (cons 
        (map 'list #'digit-char-p (coerce line 'list))
        (parse-input stream list)))))

(defun read-input ()
  (with-open-file (stream "input.txt")
    (parse-input stream nil)))

(defun leading-reversed (idx row result)
  (if (= idx 0)
    result
    (leading-reversed (- idx 1) (cdr row)
      (cons (car row) result))))

(defun west (idx row)
  (leading-reversed idx row nil))

(defun east (idx row)
  (nthcdr (+ idx 1) row))

(defun north (idx column)
  (leading-reversed idx column nil))

(defun south (idx column)
  (nthcdr (+ idx 1) column))

(defun column-tail (idx rows result)
  (if (null rows)
    (reverse result)
    (column-tail idx (cdr rows)
      (cons (nth idx (car rows)) result))))

(defun column (idx rows)
  (column-tail idx rows nil))

(defun tree-height (grid row-i col-i)
  (nth col-i (nth row-i grid)))

(defun tree-views (grid row-i col-i)
  (let ((row (nth row-i grid))
        (col (column col-i grid)))
    (list
      (north row-i col)
      (south row-i col)
      (west col-i row)
      (east col-i row))))

(defun has-clear-view (view height)
  (let ((current (car view)))
    (cond
      ((null current) T)
      ((>= current height) nil)
      (t (has-clear-view (cdr view) height)))))

(defun any-clear-views (views height)
  (let ((view (car views)))
    (cond
      ((null views) nil)
      ((has-clear-view view height) T)
      (t (any-clear-views (cdr views) height)))))

(defun iter-row-i (grid row-i col-i col-n callable result)
  (if (= col-i col-n)
    result
    (iter-row-i
      grid row-i (+ col-i 1) col-n callable
      (funcall callable grid row-i col-i result))))

(defun iter-grid-i (grid row-i row-n col-i col-n callable result)
  (if (= row-i row-n)
    result
    (iter-grid-i grid (+ row-i 1) row-n col-i col-n callable
      (iter-row-i grid row-i col-i col-n callable result))))

(defun iter-grid (grid callable start skip-edges)
  (iter-grid-i
    grid
    (if skip-edges 1 0)
    (- (list-length grid) (if skip-edges 1 0))
    (if skip-edges 1 0)
    (- (list-length grid) (if skip-edges 1 0))
    callable start))

(defun distance-visible (view max-height score)
  (let ((height (car view)))
    (cond
      ((null height) score)
      ((>= height max-height) (+ score 1))
      (t (distance-visible (cdr view) max-height (+ score 1))))))

(defun sum-visible (grid row-i col-i sum)
  (let* ((height (tree-height grid row-i col-i))
         (view (tree-views grid row-i col-i)))
    (if (any-clear-views view height)
      (+ sum 1)
      sum)))

(defun scienic-score (views max-height score)
  (let ((view (car views)))
    (if (null view)
      score
      (scienic-score (cdr views) max-height
        (* score (distance-visible view max-height 0))))))

(defun collect-scienic-scores (grid row-i col-i result)
  (cons
    (scienic-score
      (tree-views grid row-i col-i)
      (tree-height grid row-i col-i)
      1)
    result))

(format t "A: ~d~%"
  (iter-grid (read-input) 'sum-visible 0 nil))

(format t "B: ~d"
  (apply 'max (iter-grid (read-input) 'collect-scienic-scores nil t)))
