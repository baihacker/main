---
layout: default
title: "The prefix-sum of multiplicative function: Dirichlet convolution"
mathjax: true
categories: [math]
---

<h1>{{ page.title }}</h1>
{: style="text-align: center;"}

[baihacker](https://github.com/baihacker){:target="_blank"}
{: style="text-align: center;"}

2020.04.12
{: style="text-align: center;"}

This article is a continuation of **The prefix-sum of multiplicative function: powerful number sieving**. And this article views "powerful number sieving" at a higher level. And "powerful number sieving" can be treated as one of the optimiazation way of the methods described in this article. This article is also a generalized version of **Thinking on the generalized mobius inversion** [1].

# Notation
Use $f,g,h,...$ to denote multiplicative function and $sf,sg,sh,...$ are their prefix-sum function. $F,G,H,...$ are their Dirichlet generating function. $G*H$ means the Dirichlet convolution of two Dirichlet generating functions.

# Method description
In order to compute $sf(n)$, we can write $F$ in the format of $\frac{H1 * H2 * H3 * ...}{H4 * H5 * H6 * ...}$ and evaluate the right side efficiently. We call $f$ or $sf$ **target function** and call $h_i$ and $H_i$ **helper function**. In another word, **shift the complexity to helper functions**.

# Implementations
In the implementation section, we only consider two helper functions:
* **case M.** find $sf(n)$ when $F=G*H$ ($G$, $H$ are known), or
* **case I.** find $sg(n)$ when $G=F/H$ ($H$, $F$ are known). We can rewrite it as $G*H=F$.

The orignal version (more than two helper functions) can be solved by applying these implementations more than one times.

# **Raw** implementations
For **case M.**, a **raw** implementation is to compute the convolution of $G$ and $H$ directly.

Since the formula is raw, we don't have enough information to optimize it. This also means we can use any idea to optimize it.

# **Prefix-sum** implementation
For **case M.**, **case I.**, by iterating each item of $H=\sum\frac{h(i)}{i^s}$, there are two formulats:

$$
\begin{array}{lcl}
sf(n) &=& \sum_{i=1}^{n} sg(\frac{n}{i}) h(i)\\
sg(n) &=& sf(n) - \sum_{i=2}^{n} sg(\frac{n}{i}) h(i)
\end{array}
$$

This implementation requires to iterate all the item of $h$. So the optimization direction is to reduce the number of items in $H$. 

For example, consider $H = \prod_p(1 + \frac{h(p^s)}{p^s} + \frac{h_(p^{2s})}{p^{2s}}$+...). If $h(p)$ is $0$, we have the powerful number sieving method (see another article). Moreover, If $h(p^k) = 0$ for $k \ge 1$, we have other similar sieving methods.

So, the guides to this implementation are
* the prefix-sum of one helper function is easy to calculate.
* many coefficients of the other helper function is zero.
  * One way (not the only way) to achieve this goal is $h(p^k) = 0$ for $1 \le k \le c$.

# **Partitioned** implementation
Use these two codes to calculate $sf$ and $sg$ respectively

```cpp
// Returns sf
int64 cal(int64 n) {
  int64 ret = 0;
  int64 last = 0;
  for (int i = 1; i <= n;) {
    const int64 val = n / i, maxi = n / val;
    const int64 each = sg(val), curr = sh(maxi);
    ret += each * (curr - last);
    last = curr;
    i = maxi + 1;
  }
  return ret;
}
```

```cpp
// Returns sg. Need to memorize the result.
int64 cal(int64 n) {
  int64 ret = sf(n);
  int64 last = 1; // h(1) = sh(1) = 1
  for (int i = 2; i <= n;) {
    const int64 val = n / i, maxi = n / val;
    const int64 each = cal(val), curr = sh(maxi);
    ret -= each * (curr - last);
    last = curr;
    i = maxi + 1;
  }
  return ret;
}
```

For **case M.** We only need the value of $$sg(i), sh(i), sg(\frac{n}{i}), sh(\frac{n}{i}), i \le n^{1/2}$$. Let $$O(n^{\frac{a}{b}})=\max(O(sh), O(sg))$$ (usually, we have $$0\le a<b$$). So, based on $$\int _1^nx^{\frac{a}{b}}+(\frac{n}{x})^{\frac{a}{b}}dx$$, the complexity is $$O(n^{\frac{a+b}{2b}})$$. For example $$a=1,b=2$$, the complexity is $$O(n^{\frac{3}{4}})$$. When $$a=0$$, the lower bound is $$\Omega (n^{\frac{1}{2}})$$. This lower bound is consistent with our intuition, i.e. we need to iterate $$O(n^{\frac{1}{2}})$$ function values.

# References
1. baihacker, 2018.03.18, [**Thinking on the generalized mobius inversion**](https://blog.csdn.net/baihacker/article/details/79597472){:target="_blank"} (chinese content)
2. baihacker, 2020.04.07, [**The prefix-sum of multiplicative function: powerful number sieving**](http://baihacker.github.io/main/)
{% include mathjax.html %}