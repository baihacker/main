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

This article is a continuation of **The prefix-sum of multiplicative function: powerful number sieve** [2]. And this article gives a higher level view of "powerful number sieve". And "powerful number sieve" can be treated as one of the optimiazation way of the methods described in this article. This article is also a generalized version of **Thinking on the generalized mobius inversion** [1].

# Notation
 * $f,g,h,...$ are used to denote arithmetic function and $sf,sg,sh,...$ are their prefix-sum function.
 * $g*h$ means the Dirichlet convolution.
 * $F,G,H,...$ are the corresponding Dirichlet generating function.
 * $G*H$ means normal multiplication.

# Method description
In order to compute $sf(n)$, we can write $f$ in the form of $\frac{h_1 * h_2 * h_3 * ...}{h_4 * h_5 * h_6 * ...}$ to help compute $sf(n)$.

Let's call $f$ or $sf$ **target function** and call $h_i$ **helper function**. The motivation of the method is straightforward: **shift the complexity to helper functions**.

This kind of approach is also known as **Lord Du sieve** [3], which focuses on two helper functions.

# Implementations
In the implementation section, we only consider two helper functions and try to solve the two problems:
* **case M.** find $sf(n)$ when $f=g*h$ ($g$, $h$ are known), or
* **case I.** find $sg(n)$ when $g=f/h$ ($f$, $h$ are known). We can rewrite it as $g*h=f$.

If there are more than two helper functions, apply these implementations more than one time.

## **Raw** implementations
For **case M.**, the **raw** implementation means to evaluate $G*H$ directly.

Since this is a raw expression, we don't have enough information to optimize it. This also means we can use any idea to optimize it.

## **Prefix-sum** implementation
For **case M.**, **case I.**, by iterating each coefficient of $H=\sum\frac{h(i)}{i^s}$, there are two formulas:

$$
\begin{array}{lcl}
sf(n) &=& \sum\limits_{i=1}^{n} sg(\frac{n}{i}) h(i)\\
h(1) sg(n) &=& sf(n) - \sum\limits_{i=2}^{n} sg(\frac{n}{i}) h(i)
\end{array}
$$

*Note: it is required that $h(1)$ is not $0$ in the second formula. In another word, the inverse of $h$ exists.*

### Optimize $h(i)$ part
Consider $h(i)$ in the two formulas, one optimization way is to reduce the number of visited $h(i)$.

For example, consider $H = \prod\limits_p(1 + \frac{h(p^s)}{p^s} + \frac{h_(p^{2s})}{p^{2s}}$+...). If $h(p)$ is $0$, we have the powerful number sieve method (see another article). Moreover, If $h(p^k) = 0$ for $k \ge 1$, we have other similar sieve methods.

### Requirement of the remaining parts

In the first formula
 * the values of $sg$ for all $\frac{n}{i}$ are expected to be calculated by a reasonable complexity.

In the second formula: 
 * the values of $sg$ for all $\frac{n}{i} (i > 1)$ are expected to be calculated by a reasonable complexity. Note $sg(n)$ itself is the target result.
 * the values of $sf$ for all $\frac{n}{i}$ are expected to be calculated by a reasonable complexity. Note $sg(n)$ depends on $\frac{n}{i} (i > 1)$ we not only calculate $sf(n)$

## **Partitioned** implementation
If the values of $sh$ for all $\frac{n}{i}$ can be calculated by a reasonable complexity, we have the following codes to calculate $sf$ and $sg$ respectively

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
  int64 last = h(1);
  for (int64 i = 2; i <= n;) {
    const int64 val = n / i, maxi = n / val;
    const int64 each = cal(val), curr = sh(maxi);
    ret -= each * (curr - last);
    last = curr;
    i = maxi + 1;
  }
  return ret / h(1);
}
```

### Complexity of helper functions
We need to compute the values of $sg(i), sh(i), sg(\frac{n}{i}), sh(\frac{n}{i}), i \le n^{\frac{1}{2}}$. Let $O(n^{\frac{a}{b}})=\max(O(sh), O(sg))$. Based on $\int _1^{n^{\frac{1}{2}}}x^{\frac{a}{b}}+(\frac{n}{x})^{\frac{a}{b}}dx$, the complexity is 

$$
\begin{cases}
n^{\frac{a+b}{2b}} & 0 \le a < b \\
n \log{n} & 0 < a = b \\
n^{\frac{a}{b}} & 0 < b < a \\
\end{cases}
$$

If $sg(i), sh(i)$ for $i \le n^{\frac{2}{3}}$ can be calculated in $O(n^{\frac{2}{3}})$ time, $\int _1^{n^{\frac{1}{2}}}x^{\frac{a}{b}}+(\frac{n}{x})^{\frac{a}{b}}dx$ becomes $n^{\frac{2}{3}} + \int _1^{n^{\frac{1}{3}}}(\frac{n}{x})^{\frac{a}{b}}dx$, the complexity is

$$
\begin{cases}
n^{\frac{2}{3}} + n^{\frac{2a+b}{3b}} & 0 \le a < b \\
n^{\frac{2}{3}} + n \log{n} & 0 < a = b \\
n^{\frac{a}{b}} & 0 < b < a \\
\end{cases}
$$

### Complexity of target function
For **case M.**, the complexity $O(n^{\frac{1}{2}})$.

For **case I.**, it is the $a=1,b=2$ case in the complexity of helper functions section, i.e. $O(n^{\frac{3}{4}})$ or $O(n^{\frac{2}{3}})$.

Note: values of $sf(\frac{n}{i}), i \ge 2$ are not computed in **case M.**, and that's why it has a better complexity than **case I.**

### Overall complexity
The larger complexity of target function part and helper function part.

# Comment
* It is not required that $f, g, h$ are multiplicative functions.
* The method which uses mobius inversion to compute the prefix-sum is just a special case where the helper functions are $\mu$ and $1$.

# References
1. baihacker, 2018.03.18, [**Thinking on the generalized mobius inversion**](https://blog.csdn.net/baihacker/article/details/79597472){:target="_blank"} (chinese content)
2. baihacker, 2020.04.07, [**The prefix-sum of multiplicative function: powerful number sieve**](http://baihacker.github.io/main/){:target="_blank"}
3. [**Lord Du sieve**](https://oi-wiki.org/math/du/){:target="_blank"} (chinese content)

{% include mathjax.html %}
