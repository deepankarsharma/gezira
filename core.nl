Color <: (a, r, g, b : Real)
Point <: (x, y : Real)
Vector <: (x, y : Real)
Matrix <: (a, b, c, d, e, f : Real)
Bezier <: (a, b, c : Point)
EdgeContribution <: (x, y, w, h : Real)

Sampler :: Point >> Color
Compositor :: (Color, Color) >> Color
Canvas :: (start : Point) : (Color, Real) >>|

| (a : Real) | : Real
    { -a if a < 0, a }

(a : Real) ⋖ (b : Real) : Real
    {a if a < b, b}

(a : Real) ⋗ (b : Real) : Real
    {a if a > b, b}

(a : Real) ? (b : Real) : Real
    {a if a ≠ 0, b}

(a : Real) ~ (b : Real) : Real
    (a + b) / 2

(A : Point) = (B : Point) : Real
    A.x = B.x ∧ A.y = B.y

(u : Vector) = (v : Vector) : Real
    u.x = v.x ∧ u.y = v.y

(u : Vector) ?? (v : Vector) : Vector
    {u if u ≠ 0, v}

(u : Vector) ∙ (v : Vector) : Real
    u.x × v.x + u.y × v.y

‖ (u : Vector) ‖ : Real
    √(u ∙ u) 

^(u : Vector) : Vector
    {u / ‖ u ‖ if ‖ u ‖ ≠ 0, 0}

(A : Point) ⟂ (B : Point) : Vector
    ^(A.y - B.y, B.x - A.x)

(A : Point) ⇀ (B : Point) : Vector
    ^(B.x - A.x, B.y - A.y)

(M : Matrix) ⊗ (A : Point) : Point
    (M.a × A.x + M.c × A.y + M.e, M.b × A.x + M.d × A.y + M.f)

CompositeSamplers (s1 : Sampler, s2 : Sampler, c : Compositor) : Sampler
    ⇒ Interleave (s1, s2) → c

UniformColor (c : Color) : Sampler
    ∀ P
        >> (c.a, c.a × c.r, c.a × c.g, c.a × c.b)

CompositeOver : Compositor
    ∀ (a, b)
        >> a + b × (1 - a.a)

FillBetweenEdges (x0 : Real) : EdgeContribution >> Real
    x     = x0
    local = 0
    run   = 0
    ∀ (x', y, w, h)
        n = x' - x
        run' = run + h
        if n = 0
            local' = local + w × h
        else
            local' = run + w × h
            >>        | local | ⋖ 1
            >(n - 1)> | run   | ⋖ 1
    if local ≠ 0
        >> | local | ⋖ 1

CreateSamplePoints (start : Point) : Real >> Point
    x = start.x
    y = start.y
    ∀ c
        x' = x + 1
        >> (x, y)

Render' (s : Sampler, c : Canvas) : EdgeContribution >>|
    & (x, y, w, h)
        start = (x, y) + 0.5
        ⇒ FillBetweenEdges (x) →
          Interleave (CreateSamplePoints (start) → s, (→)) →
          c (start)

Render (s : Sampler, c : Canvas) : EdgeContribution >>|
    ⇒ GroupBy (@y) → SortBy (@x) → Render' (s, c)
