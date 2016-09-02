//
//  ListLibrary.swift
//  LispKit
//
//  Created by Matthias Zenger on 22/01/2016.
//  Copyright © 2016 ObjectHub. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

///
/// List library: based on R7RS spec, but with one big difference: cons cells are not
/// mutable in LispKit. Thus, functionality for mutating and copying lists is missing.
/// Mutable cons cells created via `mcons` can be used as a replacement for mutable lists.
/// `mcons` is based on Racket (see BoxLibrary.swift).
///
public final class ListLibrary: NativeLibrary {
  
  public override func export() {
    define(Procedure("pair?", isPair, compileIsPair))
    define(Procedure("list?", isList))
    define(Procedure("null?", isNull, compileIsNull))
    define(Procedure("make-list", makeList))
    define(Procedure("list", list, compileList))
    define(Procedure("cons", cons, compileCons))
    define(Procedure("car", car, compileCar))
    define(Procedure("cdr", cdr, compileCdr))
    define(Procedure("caar", caar))
    define(Procedure("cadr", cadr))
    define(Procedure("cdar", cdar))
    define(Procedure("cddr", cddr))
    define("caaar", compile: "(lambda (x) (car (caar x)))")
    define("caadr", compile: "(lambda (x) (car (cadr x)))")
    define("cadar", compile: "(lambda (x) (car (cdar x)))")
    define("caddr", compile: "(lambda (x) (car (cddr x)))")
    define("cdaar", compile: "(lambda (x) (cdr (caar x)))")
    define("cdadr", compile: "(lambda (x) (cdr (cadr x)))")
    define("cddar", compile: "(lambda (x) (cdr (cdar x)))")
    define("cdddr", compile: "(lambda (x) (cdr (cddr x)))")
    define("caaaar", compile: "(lambda (x) (caar (caar x)))")
    define("caaadr", compile: "(lambda (x) (caar (cadr x)))")
    define("caadar", compile: "(lambda (x) (caar (cdar x)))")
    define("caaddr", compile: "(lambda (x) (caar (cddr x)))")
    define("cadaar", compile: "(lambda (x) (cadr (caar x)))")
    define("cadadr", compile: "(lambda (x) (cadr (cadr x)))")
    define("caddar", compile: "(lambda (x) (cadr (cdar x)))")
    define("cadddr", compile: "(lambda (x) (cadr (cddr x)))")
    define("cdaaar", compile: "(lambda (x) (cdar (caar x)))")
    define("cdaadr", compile: "(lambda (x) (cdar (cadr x)))")
    define("cdadar", compile: "(lambda (x) (cdar (cdar x)))")
    define("cdaddr", compile: "(lambda (x) (cdar (cddr x)))")
    define("cddaar", compile: "(lambda (x) (cddr (caar x)))")
    define("cddadr", compile: "(lambda (x) (cddr (cadr x)))")
    define("cdddar", compile: "(lambda (x) (cddr (cdar x)))")
    define("cddddr", compile: "(lambda (x) (cddr (cddr x)))")
    define(Procedure("length", length))
    define(Procedure("append", append))
    define(Procedure("reverse", reverse))
    define(Procedure("list-tail", listTail))
    define("list-ref", compile: "(lambda (x k) (car (list-tail x k)))")
    define(Procedure("key", key))
    define(Procedure("value", value))
    define(Procedure("memq", memq))
    define(Procedure("memv", memv))
    define("member", compile:
      "(define (member x list . comp)" +
      "  (let ((eq (if (pair? comp) (car comp) equal?)))" +
      "    (let lp ((ls list))" +
      "      (and (pair? ls) (if (eq x (car ls)) ls (lp (cdr ls)))))))")
    define(Procedure("assq", assq))
    define(Procedure("assv", assv))
    define("assoc", compile:
      "(lambda (x list . comp) " +
      "  (let ((eq (if (pair? comp) (car comp) equal?)))" +
      "    (let assoc ((ls list))" +
      "      (cond ((null? ls) #f)" +
      "            ((eq x (caar ls)) (car ls))" +
      "            (else (assoc (cdr ls)))))))")
    define(Procedure("decons", decons))
    define("map", compile:
      "(lambda (f list1 . lists)" +
      "  (let ((res '()))" +
      "       (do ((pair (decons (cons list1 lists)) (decons (cdr pair))))" +
      "           ((null? pair) (reverse res))" +
      "           (set! res (cons (apply f (car pair)) res)))))")
    define("for-each", compile:
      "(lambda (f list1 . lists)" +
      "  (do ((pair (decons (cons list1 lists)) (decons (cdr pair))))" +
      "      ((null? pair))" +
      "        (apply f (car pair))))")
  }
  
  //---------MARK: - List predicates
  
  func isPair(expr: Expr) -> Expr {
    if case .Pair(_, _) = expr {
      return .True
    }
    return .False
  }
  
  func compileIsPair(compiler: Compiler, expr: Expr, env: Env, tail: Bool) throws -> Bool {
    return try self.invoke(.IsPair, with: expr, in: env, for: compiler)
  }
  
  func isList(expr: Expr) -> Expr {
    var expr = expr
    while case .Pair(_, let cdr) = expr {
      expr = cdr
    }
    return Expr.Boolean(expr.isNull)
  }
  
  func isNull(expr: Expr) -> Expr {
    return Expr.Boolean(expr.isNull)
  }
  
  func compileIsNull(compiler: Compiler, expr: Expr, env: Env, tail: Bool) throws -> Bool {
    return try self.invoke(.IsNull, with: expr, in: env, for: compiler)
  }
  
  //-------- MARK: - Construction and deconstruction
  
  func makeList(k: Expr, expr: Expr?) throws -> Expr {
    let def = expr ?? .Null
    var res: Expr = .Null
    var n = try k.asInt(below: Int.max)
    while n > 0 {
      res = .Pair(def, res)
      n -= 1
    }
    return res
  }
  
  func list(exprs: Arguments) -> Expr {
    var res = Expr.Null
    for expr in exprs.reverse() {
      res = .Pair(expr, res)
    }
    return res
  }
  
  func compileList(compiler: Compiler, expr: Expr, env: Env, tail: Bool) throws -> Bool {
    guard case .Pair(_, let cdr) = expr else {
      preconditionFailure()
    }
    switch try compiler.compileExprs(cdr, in: env) {
      case 0:
        compiler.emit(.PushNull)
      case 1:
        compiler.emit(.PushNull)
        compiler.emit(.Cons)
      case let n:
        compiler.emit(.List(n))
    }
    return false
  }
  
  func cons(car: Expr, _ cdr: Expr) -> Expr {
    return .Pair(car, cdr)
  }
  
  func compileCons(compiler: Compiler, expr: Expr, env: Env, tail: Bool) throws -> Bool {
    guard case .Pair(_, .Pair(let head, .Pair(let tail, .Null))) = expr else {
      throw EvalError.ArgumentCountError(formals: 2, args: expr)
    }
    try compiler.compile(head, in: env, inTailPos: false)
    try compiler.compile(tail, in: env, inTailPos: false)
    compiler.emit(.Cons)
    return false
  }
  
  func car(expr: Expr) throws -> Expr {
    guard case .Pair(let car, _) = expr else {
      throw EvalError.TypeError(expr, [.PairType])
    }
    return car
  }
  
  func compileCar(compiler: Compiler, expr: Expr, env: Env, tail: Bool) throws -> Bool {
    return try self.invoke(.Car, with: expr, in: env, for: compiler)
  }
  
  func cdr(expr: Expr) throws -> Expr {
    guard case .Pair(_, let cdr) = expr else {
      throw EvalError.TypeError(expr, [.PairType])
    }
    return cdr
  }
  
  func compileCdr(compiler: Compiler, expr: Expr, env: Env, tail: Bool) throws -> Bool {
    return try self.invoke(.Cdr, with: expr, in: env, for: compiler)
  }
  
  func caar(expr: Expr) throws -> Expr {
    guard case .Pair(let car, _) = expr else {
      throw EvalError.TypeError(expr, [.PairType])
    }
    guard case .Pair(let caar, _) = car else {
      throw EvalError.TypeError(car, [.PairType])
    }
    return caar
  }
  
  func cadr(expr: Expr) throws -> Expr {
    guard case .Pair(_, let cdr) = expr else {
      throw EvalError.TypeError(expr, [.PairType])
    }
    guard case .Pair(let cadr, _) = cdr else {
      throw EvalError.TypeError(cdr, [.PairType])
    }
    return cadr
  }

  func cdar(expr: Expr) throws -> Expr {
    guard case .Pair(let car, _) = expr else {
      throw EvalError.TypeError(expr, [.PairType])
    }
    guard case .Pair(_, let cdar) = car else {
      throw EvalError.TypeError(car, [.PairType])
    }
    return cdar
  }
  
  func cddr(expr: Expr) throws -> Expr {
    guard case .Pair(_, let cdr) = expr else {
      throw EvalError.TypeError(expr, [.PairType])
    }
    guard case .Pair(_, let cddr) = cdr else {
      throw EvalError.TypeError(cdr, [.PairType])
    }
    return cddr
  }

  
  //-------- MARK: - Basic list functions
  
  func length(expr: Expr) throws -> Expr {
    var expr = expr
    var len: Int64 = 0
    while case .Pair(_, let cdr) = expr {
      len += 1
      expr = cdr
    }
    guard expr.isNull else {
      throw EvalError.TypeError(expr, [.ProperListType])
    }
    return .Fixnum(len)
  }
  
  func appendList(fst: Expr, _ tail: Expr) throws -> Expr {
    guard case (let exprs, .Null) = fst.toExprs() else {
      throw EvalError.TypeError(fst, [.ProperListType])
    }
    return Expr.List(exprs, append: tail)
  }
  
  func append(exprs: Arguments) throws -> Expr {
    var res: Expr? = nil
    for expr in exprs.reverse() {
      res = (res == nil) ? expr : try appendList(expr, res!)
    }
    return res ?? .Null
  }
  
  func reverse(expr: Expr) throws -> Expr {
    var res = Expr.Null
    var list = expr
    while case .Pair(let car, let cdr) = list {
      res = .Pair(car, res)
      list = cdr
    }
    guard list.isNull else {
      throw EvalError.TypeError(expr, [.ProperListType])
    }
    return res
  }
  
  func listTail(expr: Expr, _ count: Expr) throws -> Expr {
    var k = try count.asInteger()
    guard k >= 0 else {
      throw EvalError.IndexOutOfBounds(k, -1, expr)
    }
    if k == 0 {
      return expr
    } else {
      var list = expr
      var len: Int64 = 0
      while case .Pair(_, let cdr) = list {
        k -= 1
        if k == 0 {
          return cdr
        }
        len += 1
        list = cdr
      }
      throw EvalError.IndexOutOfBounds(try count.asInteger(), len, expr)
    }
  }
  
  func key(expr: Expr, def: Expr?) throws -> Expr {
    guard case .Pair(let car, _) = expr else {
      return def ?? .False
    }
    return car
  }
  
  func value(expr: Expr, def: Expr?) throws -> Expr {
    guard case .Pair(_, let cdr) = expr else {
      return def ?? .False
    }
    return cdr
  }
  
  func memq(obj: Expr, expr: Expr) throws -> Expr {
    var list = expr
    while case .Pair(let car, let cdr) = list {
      if eqExpr(obj, car) {
        return list
      }
      list = cdr
    }
    guard list.isNull else {
      throw EvalError.TypeError(expr, [.ProperListType])
    }
    return .False
  }
  
  func memv(obj: Expr, expr: Expr) throws -> Expr {
    var list = expr
    while case .Pair(let car, let cdr) = list {
      if eqvExpr(obj, car) {
        return list
      }
      list = cdr
    }
    guard list.isNull else {
      throw EvalError.TypeError(expr, [.ProperListType])
    }
    return .False
  }
  
  func assq(obj: Expr, expr: Expr) throws -> Expr {
    var list = expr
    while case .Pair(.Pair(let key, let value), let cdr) = list {
      if eqExpr(obj, key) {
        return .Pair(key, value)
      }
      list = cdr
    }
    guard list.isNull else {
      throw EvalError.TypeError(expr, [.AssocListType])
    }
    return .False
  }
  
  func assv(obj: Expr, expr: Expr) throws -> Expr {
    var list = expr
    while case .Pair(.Pair(let key, let value), let cdr) = list {
      if eqvExpr(obj, key) {
        return .Pair(key, value)
      }
      list = cdr
    }
    guard list.isNull else {
      throw EvalError.TypeError(expr, [.AssocListType])
    }
    return .False
  }
  
  func decons(expr: Expr) throws -> Expr {
    guard case (let lists, .Null) = expr.toExprs() else {
      throw EvalError.TypeError(expr, [.ProperListType])
    }
    guard lists.count > 0 else {
      return .Null
    }
    var cars: Expr = .Null
    var cdrs: Expr = .Null
    for i in lists.indices.reverse() {
      switch lists[i] {
        case .Null:
          return .Null
        case .Pair(let car, let cdr):
          cars = .Pair(car, cars)
          cdrs = .Pair(cdr, cdrs)
        default:
          throw EvalError.TypeError(lists[i], [.ProperListType])
      }
    }
    return .Pair(cars, cdrs)
  }
}
