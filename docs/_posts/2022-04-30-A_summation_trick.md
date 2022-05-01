---
layout: default
title: "A summation trick"
mathjax: true
categories: [math]
---

<h1>{{ page.title }}</h1>
{: style="text-align: center;"}

[baihacker](https://github.com/baihacker){:target="_blank"}
{: style="text-align: center;"}

2022.04.30
{: style="text-align: center;"}

The trick
==

Let's consider the following problem **Formula 0**

$$
\sum\limits_{1\le i,j \le n}[\gcd(i,j)=1][m\mid\operatorname{lcm}(i,j)]f(i,j)
$$

According to [PIE](https://en.wikipedia.org/wiki/Inclusion%E2%80%93exclusion_principle){:target="_blank"}, we have **Formula 1**

$$
\begin{array}{lll}
S
&=&
\sum\limits_{1\le i,j \le n}\sum\limits_{d\mid i, d\mid j}\mu(d)[m\mid\operatorname{lcm}(i,j)]f(i,j)\\
&=&
\sum\limits_{1\le d \le n}\mu(d)\sum\limits_{1\le i,j \le n,d\mid i, d\mid j}[m\mid\operatorname{lcm}(i,j)]f(i,j)
\end{array}
$$

This is not easy to solve because of $$[m\mid\operatorname{lcm}(i,j)]$$. The root cause is that the PIE is applied to an expression which can be further simplified. Let's transform the formula before applying PIE to it, then **Formula 2** is derived.

$$
\begin{array}{lll}
S
&=&
\sum\limits_{1\le i,j \le n}[\gcd(i,j)=1][m\mid i\cdot j]f(i,j)\\
&=&
\sum\limits_{1\le d \le n}\mu(d)\sum\limits_{1\le i,j \le n,d\mid i, d\mid j}[m\mid i\cdot j]f(i,j)
\end{array}
$$

The latest formula is still not easy to evaluate efficiently. Consider more transformation, **Formula 3** is derived

$$
\begin{array}{lll}
S
&=&
\sum\limits_{1\le i,j \le n}[\gcd(i,j)=1][m\mid i\cdot j]f(i,j)\\
&=&
\sum\limits_{1\le i,j \le n}[\gcd(i,j)=1][\gcd(i,m)=x][\gcd(j,m)=y][m\mid xy]f(i,j)\\
&=&
\sum\limits_{1\le i,j \le n}[\gcd(i,j)=1][\gcd(i,m)=x][\gcd(j,m)=y][m=xy]f(i,j)\\
&=&
\sum\limits_{1\le i,j \le n,m=xy}[\gcd(i,j)=1][\gcd(i,m)=x][\gcd(j,m)=y]f(i,j)\\
&=&
\sum\limits_{1\le i,j \le n,m=xy}[\gcd(i,j)=1][\gcd(\frac{i}{x},y)=1][\gcd(\frac{j}{y},x)=1]f(i,j)\\
\end{array}
$$

Note 1: $$m=xy$$ because $$x\mid m, y\mid m, \gcd(x,y)=1, m\mid xy$$.

Note 2: The number of $$(x,y)$$ pairs can be reduced by applying the constraints $$\gcd(x,y)=1$$.

Then, apply PIE 3 times to the above formula to find a possible solution but the complexity is still not reasonable.

Another observation is $$\gcd(\frac{i}{x},y)=1$$ and $$\gcd(\frac{j}{y},x)=1$$ must be true if $$\gcd(i,j)=1$$, so we have **Formula 4**

$$
\sum\limits_{1\le i,j \le n,m=xy}[\gcd(i,j)=1][x\mid i][y\mid j]f(i,j)
$$

The illusion
==
Consider **Formula 1** and **Formula 2**,
$$
\begin{array}{lll}
\sum\limits_{1\le d \le n}\mu(d)\sum\limits_{1\le i,j \le n,d\mid i, d\mid j}[m\mid\operatorname{lcm}(i,j)]f(i,j)
&=&
\sum\limits_{1\le d \le n}\mu(d)\sum\limits_{1\le i,j \le n,d\mid i, d\mid j}[m\mid i\cdot j]f(i,j)
\end{array}
$$

It looks as if we rewrite $$[m\mid\operatorname{lcm}(i,j)]$$ as $$[m\mid i\cdot j]$$ so they are equivalent. This is wrong: let $$m=20, i=2, j=10$$, then $$m \not\mid \operatorname{lcm}(i,j)=10$$ but $$m \mid i\cdot j=20$$.

Verification
==
Let's choose $$f(i,j)=i^2j$$.

```cpp
#include <pe.hpp>
using namespace pe;
using namespace std;

const int m = 24;

int64 Formula0(int n) {
  int64 ret = 0;
  for (int i = 1; i <= n; ++i)
    for (int j = 1; j <= n; ++j)
      if (Lcm(i, j) % m == 0 && Gcd(i, j) == 1) {
        ret += i * i * j;
      }
  return ret;
}

int64 Formula1(int n) {
  int64 ret = 0;
  for (int d = 1; d <= n; ++d) {
    int c = CalMu(d);
    if (c == 0) continue;
    int64 tmp = 0;
    for (int i = d; i <= n; i += d)
      for (int j = d; j <= n; j += d) {
        if (Lcm(i, j) % m == 0) {
          tmp += i * i * j;
        }
      }
    ret += c * tmp;
  }
  return ret;
}

int64 Formula2(int n) {
  int64 ret = 0;
  for (int d = 1; d <= n; ++d) {
    int c = CalMu(d);
    if (c == 0) continue;
    int64 tmp = 0;
    for (int i = d; i <= n; i += d)
      for (int j = d; j <= n; j += d) {
        if (i * j % m == 0) {
          tmp += i * i * j;
        }
      }
    ret += c * tmp;
  }
  return ret;
}

int64 Formula3(int n) {
  int64 ret = 0;
  for (int d = 1; d <= n; ++d) {
    int c = CalMu(d);
    if (c == 0) continue;
    for (int x : GetFactors(m)) {
      int y = m / x;
      // The same result if the following check is enabled.
      // if (Gcd(x, y) != 1) continue;
      // Note: the complexity can be reduced from O((n/d)^2) to O(n/d).
      for (int i = d; i <= n; i += d)
        for (int j = d; j <= n; j += d) {
          if (i % x == 0 && Gcd(i, y) == 1 && j % y == 0 && Gcd(j, x) == 1) {
            ret += c * i * i * j;
          }
        }
    }
  }
  return ret;
}

int64 Formula4(int n) {
  int64 ret = 0;
  for (int d = 1; d <= n; ++d) {
    int c = CalMu(d);
    if (c == 0) continue;
    int64 tmp = 0;
    for (int x : GetFactors(m)) {
      int y = m / x;
      // The same result if the following check is enabled.
      // if (Gcd(x, y) != 1) continue;
      // Note: the complexity can be reduced from O((n/d)^2) to O(n/d).
      for (int i = d; i <= n; i += d)
        for (int j = d; j <= n; j += d) {
          if (i % x == 0 && j % y == 0) {
            tmp += i * i * j;
          }
        }
    }
    ret += c * tmp;
  }
  return ret;
}

int main() {
  PE_INIT(maxp = 100000, cal_mu = 1);
  const int n = 300;
  cout << Formula0(n) << endl;
  cout << Formula1(n) << endl;
  cout << Formula2(n) << endl;
  cout << Formula3(n) << endl;
  cout << Formula4(n) << endl;
  return 0;
}
```

Outputs
```cpp
20666222352
20666222352
20666222352
20666222352
20666222352
```
{% include mathjax.html %}
