---
layout: default
title: "Algorithmic Optimization of a Constrained Enumeration"
mathjax: true
categories: [math]
---

<h1>{{ page.title }}</h1>
{: style="text-align: center;"}

[baihacker](https://github.com/baihacker){:target="_blank"}
[Gemini](https://gemini.google.com/app){:target="_blank"}
{: style="text-align: center;"}
This article elucidates the optimization of an algorithm designed for a constrained counting problem, integral to a Project Euler solution. *This article is refined by gemini.*

The core challenge involves calculating the sum of all possible values of  $$f(a, b)$$ under the following constraints:

$$
\begin{array}{l}
1 <= i <= n - t - 1 \\
1 <= j <= n - delta - t - 1 \\
1 <= k <= n - delta - t - 1 \\
coe1_0 * i + coe1_1 * j + coe1_2 * k + coe1_3 + a = 0 \\
coe2_0 * i + coe2_1 * j + coe2_2 * k + coe2_3 + b = 0 \\
\end{array}
$$

where  $$n, t, delta, coe1_{0..3}, coe2_{0..3}$$ are predetermined constants, $$\left \vert coe2_{0,1,2}\right \vert = 1$$, and $$coe1_i = 2\ coe2_i$$ for all possible $$a, b, i, j, k$$. Crucially, all variables represent integers.

The initial approach involves nested loops to iterate through all possible values of  `a`, `b`, `i`, `j`, and `k`. The optimization progressively eliminates these loops, significantly improving efficiency.

**1. Reducing enumerated `a` and eliminating the `b` Loop**
-

Given the relationship $$coe1_i = 2\ coe2_i$$ for $$i = 0,1,2$$, subtracting twice the second equation from the first yields:

$$
a - 2\ b = 2\ coe2_3 - coe1_3
$$

This reveals two key insights:

*   `a` and `coe1_3` must share the same parity.
*   Once `a` is determined, `b` can be directly calculated, thus eliminating the need for a loop over `b`.

**2. Eliminating the `k` Loop**
-

Focusing on the second constraint equation: $$coe2_0 * i + coe2_1 * j + coe2_2 * k + coe2_3 + b = 0$$. When the parameters `i` and `b` are defined, the equation indicated `j` and `k` has a linear relationship. Therefore the loop of `k` is unnecessary when `j` is determined.

**3. Eliminating the `j` Loop**
-

Let $$c = -b - coe2_3 - coe2_0 * i$$. The equation from step 2 can be rearranged to express `j` in terms of `k`:

$$
j = \frac{c - coe2_2 k}{coe2_1} = u + v k
$$

where $$u = \frac{c}{coe2_1}$$ and $$v = -\frac{coe2_2}{coe2_1}$$. The valid range for `k` is then determined by the following:

$$
\frac{1 - u}{v} <= k <= \frac{n - delta - t - 1 - u}{v}
$$

Combined with the original constraint $$1 <= k <= n - delta - t - 1$$, the possible values of `k` fall within a defined range, eliminating the need for a `j` loop.

**Current Optimized Code:**

```c++
  for (all possible a) {
    int tmp = a - (2 * coe2[3] - coe1[3]);
    if (IsOdd(tmp)) continue;
    int b = tmp / 2;
    if (!IsValid(b)) continue;
    if (!SameParity(coe1[3], a)) continue;
    for (int i = 1; i <= n - t - 1; ++i) {
      int c = -b - coe2[3] - coe2[0] * i;
      int u = c / coe2[1];
      int v = -coe2[2] / coe2[1]; // Note: |v| = 1.
      int64 L = (1 - u) / v;
      int64 R = (n - delta - t - 1 - u) / v;
      if (v < 0) {
        swap(L, R);
      }
      if (1 > L) L = 1;
      if (n - delta - t - 1 < R) R = n - delta - t - 1;
      if (L <= R) ans += (R - L + 1) * f(a, b);
    }
  }
```

**4. Eliminating the `i` Loop**
-

The final optimization involves removing the loop over `i`.  The range of `i` influences the bounds `L` and `R` through the variable `u`. Analyzing the impact of `i` on `u`:

```c++
    int v = -coe2[2] / coe2[1];
    int u1 = (-b - coe2[3] - coe2[0] * 1) / coe2[1];
    int u2 = (-b - coe2[3] - coe2[0] * (n - t - 1)) / coe2[1];
    int64 L1 = (1 - u1) / v;
    int64 L2 = (1 - u2) / v;
    int64 R1 = (n - delta - t - 1 - u1) / v;
    int64 R2 = (n - delta - t - 1 - u2) / v;
```

The code ensures that $$L1 <= R1$$, $$L2 <= R2$$, and $$L1 <= L2$$:

```c++
    if (v < 0) {
      swap(L1, R1);
      swap(L2, R2);
    }
    if (L1 > L2) {
      swap(L1, L2),
      swap(R1, R2);
    }
```

The problem now reduces to calculating:

$$
\sum_{L1 \le L \le L2} \left \vert [L, L+D] \cap [1, n - delta - t - 1] \right \vert
$$

where $$D = R1 - L1 = R2 - L2$$ is a constant.

Let $$g(L) = \left \vert [L, L+D] \cap [1, n - delta - t - 1] \right \vert$$.  Analyzing `g(L)` at key points:

$$
\begin{array}{lcl}
g(1-D) &=& 1\\
g(1) &=& D + 1\\
g(1+D) &=& 1\\
\end{array}
$$

We consider ranges $$[1-D, 1]$$ and $$[2, 1+D]$$ where g presents an arithmetic increment in the first one and decrement in the second one.

The summation can then be expressed as:

$$
\sum_{L1 \le L \le L2} [1-D \le L \le 1] g(L) + \sum_{L1 \le L \le L2} [2 \le L \le 1+D] g(L)
$$

**Final Optimized C++ Code:**

```c++
    for (all possible a) {
      int tmp = a - (2 * coe2[3] - coe1[3]);
      if (IsOdd(tmp)) continue;
      int b = tmp / 2;
      if (!IsValid(b)) continue;
      if (!SameParity(coe1[3], a)) continue;

      int v = -coe2[2] / coe2[1]; // Note: |v| = 1.
      int u1 = (-b - coe2[3] - coe2[0] * 1) / coe2[1];
      int u2 = (-b - coe2[3] - coe2[0] * (n - t - 1)) / coe2[1];
      int64 L1 = (1 - u1) / v;
      int64 L2 = (1 - u2) / v;
      int64 R1 = (n - delta - t - 1 - u1) / v;
      int64 R2 = (n - delta - t - 1 - u2) / v;

      if (v < 0) {
        swap(L1, R1);
        swap(L2, R2);
      }
      if (L1 > L2) {
        swap(L1, L2),
        swap(R1, R2);
      }

      if (L2 >= 1 - D && L1 <= 1) {
        int64 u = 1 + max(L1, 1 - D) - (1 - D);
        int64 v = 1 + min(L2, 1LL) - (1 - D);
        ans += ApSumMod(u, v, mod) * f(a, b);
      }
      if (L2 >= 2 && L1 <= 1 + D) {
        int64 u = D + 1 - (max(L1, 2LL) - 1);
        int64 v = D + 1 - (min(L2, 1 + D) - 1);
        ans += ApSumMod(v, u, mod) * f(a, b);
      }
    }
```

where `ApSumMod(x, y, m)` calculates $$\sum_{i=x}^{y}i\pmod{m}$$.

**Observations are required**
-
The constraints $$\left \vert coe2_{0,1,2}\right \vert = 1$$ and $$coe1_i = 2\ coe2_i$$ for $$i = 0,1,2$$ were derived through careful observation of experiments.


{% include mathjax.html %}
