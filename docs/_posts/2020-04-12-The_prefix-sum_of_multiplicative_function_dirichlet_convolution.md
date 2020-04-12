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
## Method 1
In order to compute $sf(n)$, we write $F$ in the form of $G*H$, i.e. $F=G * H$ . A **raw** implementation is to compute the convolution of $G$ and $H$ directly. If $sg$ is easy to compute, we iterate each item of $H=\sum\frac{h(i)}{i^s}$, we have $sf(n) = \sum_{i=1}^{n} sg(\frac{n}{i}) h(i)$. Based on this formula we have a **prefix-sum** implementation. And we also have a **partitioned** implementation described by the c++ code:

```cpp
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

## Method 2
In order to compute $sg(n)$, we multiple $G$ by $H$ and get $F$, i.e. $G * H=F$. If we iterate each item of $H=\sum\frac{h(i)}{i^s}$, we have $sg(n) = sf(n) - \sum_{i=2}^{n} sf(\frac{n}{i}) h(i)$. In another view, we just reform the formula in Method 1: put $sg(n)$ on one side and put the rest on the other side. We can also define the **raw**, **prefix-sum** implementation and the **partitioned** implementation.


```cpp
int64 cal(int64 n) {
  int64 ret = sf(n);
  int64 last = 1; // h(1) = sh(1)
  for (int i = 2; i <= n;) {
    const int64 val = n / i, maxi = n / val;
    const int64 each = sf(val), curr = sh(maxi);
    ret -= each * (curr - last);
    last = curr;
    i = maxi + 1;
  }
  return ret;
}
```

## Definition
In these method descriptions we can define **target function**, i.e. the prefix-sum of which we are interested in. We call the other two functions **helper function**s.

## A unified and generalized description
We can use a unified way to describe these two methods: represent the target function $F$ by helper functions: $F = \frac{H1 * H2 * H3 * ...}{H4 * H5 * H6 * ...}$ and find a way to speed up the evaluation of $sf$ based on this representation. (There are more than two helper functions here).

# Use these methods
If the target prefix-sum can be computed in a reasonable complexity, we don't need these methods. We use these methods when the target is not easy to compute and we can **shift the complexity to helper functions**.

## Raw implementation
Since the formula is raw, we don't have enough information to optimize it. This also means we can use any idea to optimize it.

## Prefix-sum implementation
An observation is $sg$ in Method 1, $sf$ in Method 2 are expected to be computed in a reasonable complexity. While it still takes too much on iterate all the item of $h$. So optimization direction is to reduce the number of items in $H$. Consider $H = \prod_p(1 + \frac{h(p^s)}{p^s} + \frac{h_(p^{2s})}{p^{2s}}$+...). An example is: if $h(p)$ is $0$, we have the powerful number sieving method (see another article). Moreover, If $h(p^k) = 0$ for $k \ge 1$, we have other similar sieving methods.

So, the guides to this implementation are
* the prefix-sum of one helper function is easy to calculate.
* many coefficients of the other helper function is zero.
  * One way (not the only way) to achieve this goal is $h(p^k) = 0$ for $1 \le k \le c$.

## Partitioned implementation
This case is easy, and we have the following analysis.

We only need the value of $$sg(i), sh(i), sg(\frac{n}{i}), sh(\frac{n}{i}), i \le n^{1/2}$$. Let $$O(n^{\frac{a}{b}})=\max(O(sh), O(sg))$$ (usually, we have $$0\le a<b$$). So, based on $$\int _1^nx^{\frac{a}{b}}+(\frac{n}{x})^{\frac{a}{b}}dx$$, the complexity is $$O(n^{\frac{a+b}{2b}})$$. For example $$a=1,b=2$$, the complexity is $$O(n^{\frac{3}{4}})$$. When $$a=0$$, the lower bound is $$\Omega (n^{\frac{1}{2}})$$. This lower bound is consistent with our intuition, i.e. we need to iterate $$O(n^{\frac{1}{2}})$$ function values.

*Note: The analysis of these $3$ implementations are based o two helper functions, but we can extend them to more than two helpper functions.*

# References
1. baihacker, 2018.03.18, [**Thinking on the generalized mobius inversion**](https://blog.csdn.net/baihacker/article/details/79597472){:target="_blank"} (chinese content)
2. baihacker, 2020.04.07, [**The prefix-sum of multiplicative function: powerful number sieving**](http://baihacker.github.io/main/)
{% include mathjax.html %}