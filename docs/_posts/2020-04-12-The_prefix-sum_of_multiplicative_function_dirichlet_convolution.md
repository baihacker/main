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

## **Raw** implementations
For **case M.**, a **raw** implementation is to compute the convolution of $G$ and $H$ directly.

Since the formula is raw, we don't have enough information to optimize it. This also means we can use any idea to optimize it.

## **Prefix-sum** implementation
For **case M.**, **case I.**, by iterating each item of $H=\sum\frac{h(i)}{i^s}$, there are two formulats:

$$
\begin{array}{lcl}
sf(n) &=& \sum_{i=1}^{n} sg(\frac{n}{i}) h(i)\\
sg(n) &=& sf(n) - \sum_{i=2}^{n} sg(\frac{n}{i}) h(i)
\end{array}
$$

This implementation requires iterating all the item of $h$. So the optimization direction is to reduce the number of visited items in $H$. 

For example, consider $H = \prod_p(1 + \frac{h(p^s)}{p^s} + \frac{h_(p^{2s})}{p^{2s}}$+...). If $h(p)$ is $0$, we have the powerful number sieving method (see another article). Moreover, If $h(p^k) = 0$ for $k \ge 1$, we have other similar sieving methods.

So, the guides of this implementation are
* the prefix-sum of one helper function is easy to calculate.
* many coefficients of the other helper function are zero.
  * One way (not the only way) to achieve this goal is $h(p^k) = 0$ for $1 \le k \le c$.

## **Partitioned** implementation
Use these two codes to calculate $sf$ and $sg$ respectively

```cpp
// Returns sf(n)
int64 cal(int64 n) {
  int64 ret = 0;
  int64 last = 0;
  for (int64 i = 1; i <= n;) {
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
// Returns sg(n). Need to memorize the result.
int64 cal(int64 n) {
  int64 ret = sf(n);
  int64 last = 1; // h(1) = sh(1) = 1
  for (int64 i = 2; i <= n;) {
    const int64 val = n / i, maxi = n / val;
    const int64 each = cal(val), curr = sh(maxi);
    ret -= each * (curr - last);
    last = curr;
    i = maxi + 1;
  }
  return ret;
}
```

### Complexity of helper functions
We need to compute the values of $$sg(i), sh(i), sg(\frac{n}{i}), sh(\frac{n}{i}), i \le n^{1/2}$$. Let $$O(n^{\frac{a}{b}})=\max(O(sh), O(sg))$$. Based on $$\int _1^{n^{\frac{1}{2}}}x^{\frac{a}{b}}+(\frac{n}{x})^{\frac{a}{b}}dx$$, the complexity is 

$$
\begin{cases}
n^{\frac{a+b}{2b}} & 0 \le a < b \\
n \log{n} & 0 < a = b \\
n^{\frac{a}{b}} & 0 < b < a \\
\end{cases}
$$

### Complexity of target function
For **case M.**, the complexity $O(n^{\frac{1}{2}})$.

For **case I.**, it is the $a=1,b=2$ case in the complexity of helper functions section, i.e. $O(n^{\frac{3}{4}})$.

Note: values of $sf(\frac{n}{i}), i \ge 2$ are not computed in **case M.**, and that's why it has a better complexity than **case I.**

The overall complexity is $\max(\text{Complexity of helper functions}, \text{Complexity of target functions})$.

# References
1. baihacker, 2018.03.18, [**Thinking on the generalized mobius inversion**](https://blog.csdn.net/baihacker/article/details/79597472){:target="_blank"} (chinese content)
2. baihacker, 2020.04.07, [**The prefix-sum of multiplicative function: powerful number sieving**](http://baihacker.github.io/main/)
{% include mathjax.html %}