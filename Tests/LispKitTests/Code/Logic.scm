;;; Logic.scm
;;; Regression test data
;;;
;;; This test suite is based on the miniKanren test suite from William Byrd.
;;;
;;; Author: Matthias Zenger
;;; Copyright © 2018 ObjectHub. All rights reserved.
;;;
;;; Licensed under the Apache License, Version 2.0 (the "License");
;;; you may not use this file except in compliance with the License.
;;; You may obtain a copy of the License at
;;;
;;;      http://www.apache.org/licenses/LICENSE-2.0
;;;
;;; Unless required by applicable law or agreed to in writing, software
;;; distributed under the License is distributed on an "AS IS" BASIS,
;;; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;;; See the License for the specific language governing permissions and
;;; limitations under the License.

(
  "Logic =="
  ()
  (import (lispkit logic))
  (define failures '())
  (define-syntax test
    (syntax-rules ()
      ((_ name expression value)
         (let ((result expression))
           (if (not (equal? value result))
               (set! failures (cons (list name (quote expression) result) failures)))))))
  (test "== 1" (run 1 (q) (== 5 q)) '(5))
  (test "== 2" (run* (q) (conde ((== 5 q)) ((== 6 q)))) '(5 6))
  (test "== 3" (run* (q) (fresh (a d) (conde ((== 5 a)) ((== 6 d))) (== `(,a . ,d) q)))
            '((5 . _.0) (_.0 . 6)))
  (define appendo
    (lambda (l s out)
      (conde ((== '() l) (== s out))
             ((fresh (a d res)
                (== `(,a . ,d) l)
                (== `(,a . ,res) out)
                (appendo d s res))))))
  (test "== 4" (run* (q) (appendo '(a b c) '(d e) q)) '((a b c d e)))
  (test "== 5" (run* (q) (appendo q '(d e) '(a b c d e))) '((a b c)))
  (test "== 6" (run* (q) (appendo '(a b c) q '(a b c d e))) '((d e)))
  (test "== 7" (run 5 (q) (fresh (l s out) (appendo l s out) (== `(,l ,s ,out) q)))
               '((() _.0 _.0)
                 ((_.0) _.1 (_.0 . _.1))
                 ((_.0 _.1) _.2 (_.0 _.1 . _.2))
                 ((_.0 _.1 _.2) _.3 (_.0 _.1 _.2 . _.3))
                 ((_.0 _.1 _.2 _.3) _.4 (_.0 _.1 _.2 _.3 . _.4))))
  failures
)

(
  "Logic symbolo"
  ()
  (set! failures '())
  (test "symbolo-1" (run* (q) (symbolo q)) '((_.0 (sym _.0))))
  (test "symbolo-2" (run* (q) (symbolo q) (== 'x q)) '(x))
  (test "symbolo-3" (run* (q) (== 'x q) (symbolo q)) '(x))
  (test "symbolo-4" (run* (q) (== 5 q) (symbolo q)) '())
  (test "symbolo-5" (run* (q) (symbolo q) (== 5 q)) '())
  (test "symbolo-6" (run* (q) (symbolo q) (== `(1 . 2) q)) '())
  (test "symbolo-7" (run* (q) (== `(1 . 2) q) (symbolo q)) '())
  (test "symbolo-8" (run* (q) (fresh (x) (symbolo x))) '(_.0))
  (test "symbolo-9" (run* (q) (fresh (x) (symbolo x))) '(_.0))
  (test "symbolo-10" (run* (q) (fresh (x) (symbolo x) (== x q))) '((_.0 (sym _.0))))
  (test "symbolo-11" (run* (q) (fresh (x) (symbolo q) (== x q) (symbolo x)))
                   '((_.0 (sym _.0))))
  (test "symbolo-12" (run* (q) (fresh (x) (symbolo q) (symbolo x) (== x q)))
                     '((_.0 (sym _.0))))
  (test "symbolo-13" (run* (q) (fresh (x) (== x q) (symbolo q) (symbolo x)))
                     '((_.0 (sym _.0))))
  (test "symbolo-14-a" (run* (q) (fresh (x) (symbolo q) (== 'y x)))
                       '((_.0 (sym _.0))))
  (test "symbolo-14-b" (run* (q) (fresh (x) (symbolo q) (== 'y x) (== x q)))
                       '(y))
  (test "symbolo-15" (run* (q) (fresh (x) (== q x) (symbolo q) (== 5 x)))
                     '())
  (test "symbolo-16-a" (run* (q) (symbolo q) (=/= 5 q))
                     '((_.0 (sym _.0))))
  (test "symbolo-16-b" (run* (q) (=/= 5 q) (symbolo q))
                     '((_.0 (sym _.0))))
  (test "symbolo-17" (run* (q) (symbolo q) (=/= `(1 . 2) q))
                     '((_.0 (sym _.0))))
  (test "symbolo-18" (run* (q) (symbolo q) (=/= 'y q))
                     '((_.0 (=/= ((_.0 y))) (sym _.0))))
  (test "symbolo-19" (run* (q) (fresh (x y) (symbolo x) (symbolo y) (== `(,x ,y) q)))
                   '(((_.0 _.1) (sym _.0 _.1))))
  (test "symbolo-20" (run* (q) (fresh (x y) (== `(,x ,y) q) (symbolo x) (symbolo y)))
                     '(((_.0 _.1) (sym _.0 _.1))))
  (test "symbolo-21" (run* (q) (fresh (x y) (== `(,x ,y) q) (symbolo x) (symbolo x)))
                     '(((_.0 _.1) (sym _.0))))
  (test "symbolo-22" (run* (q) (fresh (x y) (symbolo x) (symbolo x) (== `(,x ,y) q)))
                     '(((_.0 _.1) (sym _.0))))
  (test "symbolo-23" (run* (q) (fresh (x y) (symbolo x) (== `(,x ,y) q) (symbolo x)))
                     '(((_.0 _.1) (sym _.0))))
  (test "symbolo-24-a" (run* (q) (fresh (w x y z) (=/= `(,w . ,x) `(,y . ,z))
                                   (symbolo w) (symbolo z)))
                       '(_.0))
  (test "symbolo-24-b" (run* (q) (fresh (w x y z) (=/= `(,w . ,x) `(,y . ,z))
                                   (symbolo w) (symbolo z) (== `(,w ,x ,y ,z) q)))
                       '(((_.0 _.1 _.2 _.3) (=/= ((_.0 _.2) (_.1 _.3))) (sym _.0 _.3))))
  (test "symbolo-24-c" (run* (q) (fresh (w x y z) (=/= `(,w . ,x) `(,y . ,z))
                                   (symbolo w) (symbolo y) (== `(,w ,x ,y ,z) q)))
                       '(((_.0 _.1 _.2 _.3) (=/= ((_.0 _.2) (_.1 _.3))) (sym _.0 _.2))))
  (test "symbolo-24-d" (run* (q) (fresh (w x y z) (=/= `(,w . ,x) `(,y . ,z))
                                   (symbolo w) (symbolo y) (== w y) (== `(,w ,x ,y ,z) q)))
                       '(((_.0 _.1 _.0 _.2) (=/= ((_.1 _.2))) (sym _.0))))
  (test "symbolo-25" (run* (q) (fresh (w x) (=/= `(,w . ,x) `(5 . 6)) (== `(,w ,x) q)))
                     '(((_.0 _.1) (=/= ((_.0 5) (_.1 6))))))
  (test "symbolo-26" (run* (q) (fresh (w x) (=/= `(,w . ,x) `(5 . 6))
                                 (symbolo w) (== `(,w ,x) q)))
                     '(((_.0 _.1) (sym _.0))))
  (test "symbolo-27" (run* (q) (fresh (w x) (symbolo w) (=/= `(,w . ,x) `(5 . 6))
                                 (== `(,w ,x) q)))
                     '(((_.0 _.1) (sym _.0))))
  (test "symbolo-28" (run* (q) (fresh (w x) (symbolo w) (=/= `(5 . 6) `(,w . ,x))
                                 (== `(,w ,x) q)))
                     '(((_.0 _.1) (sym _.0))))
  (test "symbolo-29" (run* (q) (fresh (w x) (symbolo w) (=/= `(5 . ,x) `(,w . 6))
                                 (== `(,w ,x) q)))
                     '(((_.0 _.1) (sym _.0))))
  (test "symbolo-30" (run* (q) (fresh (w x) (symbolo w) (=/= `(z . ,x) `(,w . 6))
                                 (== `(,w ,x) q)))
                     '(((_.0 _.1) (=/= ((_.0 z) (_.1 6))) (sym _.0))))
  (test "symbolo-31-a" (run* (q) (fresh (w x y z) (== x 5) (=/= `(,w ,y) `(,x ,z))
                                   (== w 5) (== `(,w ,x ,y ,z) q)))
                     '(((5 5 _.0 _.1) (=/= ((_.0 _.1))))))
  (test "symbolo-31-b" (run* (q) (fresh (w x y z) (=/= `(,w ,y) `(,x ,z))
                                   (== w 5) (== x 5) (== `(,w ,x ,y ,z) q)))
                     '(((5 5 _.0 _.1) (=/= ((_.0 _.1))))))
  (test "symbolo-31-c" (run* (q) (fresh (w x y z) (== w 5) (=/= `(,w ,y) `(,x ,z))
                                   (== `(,w ,x ,y ,z) q) (== x 5)))
                     '(((5 5 _.0 _.1) (=/= ((_.0 _.1))))))
  (test "symbolo-31-d" (run* (q) (fresh (w x y z) (== w 5) (== x 5)
                                   (=/= `(,w ,y) `(,x ,z)) (== `(,w ,x ,y ,z) q)))
                     '(((5 5 _.0 _.1) (=/= ((_.0 _.1))))))
  (test "symbolo-32-a" (run* (q) (fresh (w x y z) (== x 'a) (=/= `(,w ,y) `(,x ,z))
                                   (== w 'a) (== `(,w ,x ,y ,z) q)))
                     '(((a a _.0 _.1) (=/= ((_.0 _.1))))))
  (test "symbolo-32-b" (run* (q) (fresh (w x y z) (=/= `(,w ,y) `(,x ,z))
                                   (== w 'a) (== x 'a) (== `(,w ,x ,y ,z) q)))
                     '(((a a _.0 _.1) (=/= ((_.0 _.1))))))
  (test "symbolo-32-c" (run* (q) (fresh (w x y z) (== w 'a) (=/= `(,w ,y) `(,x ,z))
                                   (== `(,w ,x ,y ,z) q) (== x 'a)))
                     '(((a a _.0 _.1) (=/= ((_.0 _.1))))))
  (test "symbolo-32-d" (run* (q) (fresh (w x y z) (== w 'a) (== x 'a)
                                   (=/= `(,w ,y) `(,x ,z)) (== `(,w ,x ,y ,z) q)))
                     '(((a a _.0 _.1) (=/= ((_.0 _.1))))))
  failures
)

(
  "Logic numbero"
  ()
  (set! failures '())
  (test "numbero-1" (run* (q) (numbero q)) '((_.0 (num _.0))))
  (test "numbero-2" (run* (q) (numbero q) (== 5 q)) '(5))
  (test "numbero-3" (run* (q) (== 5 q) (numbero q)) '(5))
  (test "numbero-4" (run* (q) (== 'x q) (numbero q)) '())
  (test "numbero-5" (run* (q) (numbero q) (== 'x q)) '())
  (test "numbero-6" (run* (q) (numbero q) (== `(1 . 2) q)) '())
  (test "numbero-7" (run* (q) (== `(1 . 2) q) (numbero q)) '())
  (test "numbero-8" (run* (q) (fresh (x) (numbero x))) '(_.0))
  (test "numbero-9" (run* (q) (fresh (x) (numbero x))) '(_.0))
  (test "numbero-10" (run* (q) (fresh (x) (numbero x) (== x q))) '((_.0 (num _.0))))
  (test "numbero-11" (run* (q) (fresh (x) (numbero q) (== x q) (numbero x)))
                     '((_.0 (num _.0))))
  (test "numbero-12" (run* (q) (fresh (x) (numbero q) (numbero x) (== x q)))
                     '((_.0 (num _.0))))
  (test "numbero-13" (run* (q) (fresh (x) (== x q) (numbero q) (numbero x)))
                     '((_.0 (num _.0))))
  (test "numbero-14-a" (run* (q) (fresh (x) (numbero q) (== 5 x)))
                     '((_.0 (num _.0))))
  (test "numbero-14-b" (run* (q) (fresh (x) (numbero q) (== 5 x) (== x q))) '(5))
  (test "numbero-15" (run* (q) (fresh (x) (== q x) (numbero q) (== 'y x))) '())
  (test "numbero-16-a" (run* (q) (numbero q) (=/= 'y q)) '((_.0 (num _.0))))
  (test "numbero-16-b" (run* (q) (=/= 'y q) (numbero q)) '((_.0 (num _.0))))
  (test "numbero-17" (run* (q) (numbero q) (=/= `(1 . 2) q)) '((_.0 (num _.0))))
  (test "numbero-18" (run* (q) (numbero q) (=/= 5 q))
                     '((_.0 (=/= ((_.0 5))) (num _.0))))
  (test "numbero-19" (run* (q) (fresh (x y) (numbero x) (numbero y) (== `(,x ,y) q)))
                     '(((_.0 _.1) (num _.0 _.1))))
  (test "numbero-20" (run* (q) (fresh (x y) (== `(,x ,y) q) (numbero x) (numbero y)))
                     '(((_.0 _.1) (num _.0 _.1))))
  (test "numbero-21" (run* (q) (fresh (x y) (== `(,x ,y) q) (numbero x) (numbero x)))
                     '(((_.0 _.1) (num _.0))))
  (test "numbero-22" (run* (q) (fresh (x y) (numbero x) (numbero x) (== `(,x ,y) q)))
                     '(((_.0 _.1) (num _.0))))
  (test "numbero-23" (run* (q) (fresh (x y) (numbero x) (== `(,x ,y) q) (numbero x)))
                     '(((_.0 _.1) (num _.0))))
  (test "numbero-24-a" (run* (q) (fresh (w x y z) (=/= `(,w . ,x) `(,y . ,z))
                                   (numbero w) (numbero z)))
                     '(_.0))
  (test "numbero-24-b" (run* (q) (fresh (w x y z) (=/= `(,w . ,x) `(,y . ,z))
                                   (numbero w) (numbero z) (== `(,w ,x ,y ,z) q)))
                     '(((_.0 _.1 _.2 _.3) (=/= ((_.0 _.2) (_.1 _.3))) (num _.0 _.3))))
  (test "numbero-24-c" (run* (q) (fresh (w x y z) (=/= `(,w . ,x) `(,y . ,z))
                                   (numbero w) (numbero y) (== `(,w ,x ,y ,z) q)))
                     '(((_.0 _.1 _.2 _.3) (=/= ((_.0 _.2) (_.1 _.3))) (num _.0 _.2))))
  (test "numbero-24-d" (run* (q) (fresh (w x y z) (=/= `(,w . ,x) `(,y . ,z))
                               (numbero w) (numbero y) (== w y) (== `(,w ,x ,y ,z) q)))
                     '(((_.0 _.1 _.0 _.2) (=/= ((_.1 _.2))) (num _.0))))
  (test "numbero-25" (run* (q) (fresh (w x) (=/= `(,w . ,x) `(a . b)) (== `(,w ,x) q)))
                     '(((_.0 _.1) (=/= ((_.0 a) (_.1 b))))))
  (test "numbero-26" (run* (q) (fresh (w x) (=/= `(,w . ,x) `(a . b)) (numbero w)
                                 (== `(,w ,x) q)))
                     '(((_.0 _.1) (num _.0))))
  (test "numbero-27" (run* (q) (fresh (w x) (numbero w) (=/= `(,w . ,x) `(a . b))
                                 (== `(,w ,x) q)))
                     '(((_.0 _.1) (num _.0))))
  (test "numbero-28" (run* (q) (fresh (w x) (numbero w) (=/= `(a . b) `(,w . ,x))
                                 (== `(,w ,x) q)))
                     '(((_.0 _.1) (num _.0))))
  (test "numbero-29" (run* (q) (fresh (w x) (numbero w) (=/= `(a . ,x) `(,w . b))
                                 (== `(,w ,x) q)))
                     '(((_.0 _.1) (num _.0))))
  (test "numbero-30" (run* (q) (fresh (w x) (numbero w) (=/= `(5 . ,x) `(,w . b))
                                 (== `(,w ,x) q)))
                     '(((_.0 _.1) (=/= ((_.0 5) (_.1 b))) (num _.0))))
  (test "numbero-31" (run* (q) (fresh (x y z a b) (numbero x) (numbero y)
                                 (numbero z) (numbero a) (numbero b)
                                 (== `(,y ,z ,x ,b) `(,z ,x ,y ,a))
                                 (== q `(,x ,y ,z ,a ,b))))
                     '(((_.0 _.0 _.0 _.1 _.1) (num _.0 _.1))))
  (test "numbero-32" (run* (q) (fresh (x y z a b) (== q `(,x ,y ,z ,a ,b))
                                 (== `(,y ,z ,x ,b) `(,z ,x ,y ,a)) (numbero x)
                                 (numbero a)))
                     '(((_.0 _.0 _.0 _.1 _.1) (num _.0 _.1))))
  failures
)
