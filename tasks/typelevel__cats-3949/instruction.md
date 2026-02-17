`cats.free.Free` currently lacks a structural `Eq` instance, which prevents using standard Cats equality/law checking on values like `Free[Option, Int]` or `Free[ExprF, String]` even when `Eq` is available for the base functor and the result type.

Implement an `Eq` instance for `Free[S, A]` that performs structural equality: two `Free` values should be equal when they have the same shape and corresponding leaves/branches are equal. Concretely, when comparing two `Free[S, A]` values, you should compare their `resume` results:

- If both values `resume` to `Right(a1)` and `Right(a2)`, equality is determined by `Eq[A]` on `a1` and `a2`.
- If both values `resume` to `Left(sf1)` and `Left(sf2)`, equality is determined by `Eq[S[Free[S, A]]]` on `sf1` and `sf2`.
- If one side is `Right(_)` and the other is `Left(_)`, they are not equal.

The instance must be usable by Cats law checking for `Eq` and `PartialOrder` on `Free` values in typical cases (e.g., `Free[Option, Int]` and a `Free` built over a small expression functor `ExprF` with a lawful `Traverse` and `Eq`). The resulting behavior should allow `Eq[Free[S, A]]` to be derived implicitly whenever the necessary `Eq` instances for `A` and `S[Free[S, A]]` (and any required typeclass constraints on `S`, if applicable) are in implicit scope, and it must satisfy Cats kernel `Eq` laws (reflexive, symmetric, transitive).