(let-tensor* (((D i) (+ (A i) (B i)))
              ((E i) (+ (D i) (C i))))
             E)

;; => (equal (shape A) (shape B) (shape C) (shape D) (shape E))
;; E[i] <- A[i] + B[i] + C[i]
;; D can be eliminated

(default-schedule E) ;; => scheduling object S

;; each unbound tensor is assign symbolic shape
;; which satisfy shape constraints
;; for (size_t i=0; i<n; ++i) {
;;     D[i] = A[i] + B[i]
;; }
;;
;; for (size_t i=0; i<n; ++i) {
;;     E[i] = D[i] + C[i]
;; }

(simplify S) ;; => scheduling object S1

;; for (size_t i=0; i<n; ++i) {
;;     D[i] = A[i] + B[i]
;;     E[i] = D[i] + C[i]
;; }
;; then
;; for (size_t i=0; i<n; ++i) {
;;     E[i] = A[i] + B[i] + C[i]
;; }


(split S1 0 64) ;; => scheduling object S2
                ;;    add constraint on n to be multiple of 64

;; for (size_t i0=0; i0<n/64; ++i0) {
;;     for (size_t i1=0; i1<64; ++i1) {
;;         E[i] = A[i] + B[i] + C[i]
;;     }
;; }

(generate S2 (A n :float32) (B n :float32) (C n :float32)) ;; => lambda taking A, B and C of same shape (n) and returning E

(generate add3 S2 (A 10 :float32) (B 10 :float32) (C 10 :float32)) ;; => lambda taking A, B and C of same shape (10) and returning E

;; (defun add3 (E A B C)
;;   (declare (type (simple-array single-float (10)) E A B C)
;;            (optimize (speed 3)
;;                      (compilation-speed 0)
;;                      (safety 0)
;;                      (debug 0)))
;;   (loop :for i :below 10 :do
;;        (setf (aref E i) (+ (aref A i) (aref B i) (aref C i)))))

;; (defun add3-wrapper (A B C)
;;   (declare (type (simple-array single-float (10)) A B C)
;;            (optimize (speed 3)
;;                      (compilation-speed 0)
;;                      (safety 0)
;;                      (debug 0)))
;;   (let ((E (make-array '(10) :element-type 'single-float)))
;;     (add3 E A B C)
;;     E))


;;;;-------------------------------------------------------------

(let-tensor* (((C i) (+ (* alpha (A i)) (B i))))
             C)

;;;;-------------------------------------------------------------
