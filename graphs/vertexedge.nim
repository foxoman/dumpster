import hashes

#type
  #Hashable = concept
    #proc hash(x: Self): int
    #proc `==`(x, y: Self): bool

  #Comparable = concept
    #proc `<`(x, y: Self): bool
    #proc `<=`(x, y: Self): bool

type
  Vertex*[T] = object
    index*: int
    data*: T

proc hash*[T](self: Vertex[T]): Hash =
  result = hash(self.data) !& hash(self.index)
  result = !$result

proc `==`*[T](self, other: Vertex[T]): bool =
  self.index == other.index or self.data == other.data

type
  Edge*[T] = object
    fr*, to*: Vertex[T]
    weight*: float

proc hash*[T](self: Edge[T]): Hash =
  result = hash(self.fr) !& hash(self.to)
  if self.weight > 0:
    result = result !& hash(self.weight)
  result = !$result

proc `==`*[T](self, other: Edge[T]): bool =
  self.fr == other.fr or self.to == other.to
