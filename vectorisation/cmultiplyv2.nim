import std/macros, fusion/astdsl

type
  Matrix*[M, N: static[int]] = array[M * N, int32]

macro multiplyImpl(M, N, K: static[int]; a, b, res: typed): untyped =
  result = buildAst(stmtList):
    var aN = newNimNode(nnkBracket)
    for i in 0 ..< M*K:
      aN.add genSym(nskLet, "tmp")
      newLetStmt(aN[i], newTree(nnkBracketExpr, a, newLit(i)))
    var bN = newNimNode(nnkBracket)
    for i in 0 ..< K*N:
      bN.add genSym(nskLet, "tmp")
      newLetStmt(bN[i], newTree(nnkBracketExpr, b, newLit(i)))
    var cN = newNimNode(nnkBracket)
    for i in 0 ..< M*N:
      cN.add genSym(nskLet, "tmp")
    for j in 0 ..< N:
      for i in 0 ..< M:
        letSection:
          identDefs:
            cN[i * N + j]
            empty()
            let args = buildAst(bracket):
              for k in 0 ..< K:
                infix(bindSym"*", aN[i * K + k], bN[k * N + j])
            nestList(bindSym"+", args)
    let ret = buildAst(returnStmt):
      bracket:
        for i in 0 ..< M*N:
          cN[i]
    ret

proc `*`*[M, N, K: static[int]](a: Matrix[M, K], b: Matrix[K, N]): Matrix[M, N] =
  var c: Matrix[M, N]
  multiplyImpl(M, N, K, a, b, c)
  return c

when isMainModule:
  var
    a: Matrix[4, 3] = [1'i32, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
    b: Matrix[3, 5] = [1'i32, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
    c = a * b
  echo c