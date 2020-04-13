---
layout: default
title: "The prefix-sum of multiplicative function: the black algorithm"
mathjax: true
categories: [math]
---

<h1>{{ page.title }}</h1>
{: style="text-align: center;"}

[baihacker](https://github.com/baihacker){:target="_blank"}
{: style="text-align: center;"}

2020.04.12
{: style="text-align: center;"}

# Zhouge sieve [1]
Use $sf(n)=\sum_{x \le n \\ \text{max prime factor of x} \le n^{\frac{1}{2}}} f(x) \left (1 + \sum_{n^{\frac{1}{2}} < \text{prime p} \le \frac{n}{x}} g(p)\right)$ and it results in an algorithm of space complexity $O(n^{\frac{1}{2}})$ time complexity $O(n^{\frac{3}{4}})$ ($\log{n}$ is ignored)

# Min_25 sieve [3]
It introduces

$$
\begin{array}{lcl}
g_{n,m} &=& \sum_{2 \le x \le n \text{ every prime factor of x} > m} f(x) \\
h_n &=& \sum_{\text{prime p}} f(p) \\
\end{array}
$$


According to [1],[2], the definition of $g_{n,m}$ is similar to a part of Zhouge sieve.

The space and time complexity is the same as Zhouge sieve. But this method is easy to understand and implement, meanwhile the complexity constant is small. According to [4], an improved version reduces the time complexity to $O(n^{\frac{2}{3}})$

# The black algorithm
Another view of the Min_25 sieve are to divide the integers no more than $n$ into classes: $\text{class}_{t} = \\{ x = t * p \text { | } p \text{ is prime and } p \ge \text{max prime factor}(t) \\} $. So, just iterate all possible $t$ and compute the contribution of each class. (Mentioned by [2])

There is an article [TEES](https://www.spoj.com/problems/TEES/) in SPOJ, and it also described this algorithm. But the content is cleared due to unknown reason. And my following test is based on this version

[2] and [6] mentioned that this algorithm has an amazing performance. So I call it **black algorithm**.

## Complexity
[6] said, the number of $t$ is $O(n^{1-\epsilon})$. Here is the code to compute the number of $t$

```cpp
#include <pe.hpp>

// Unused code. Just demostrate how to implement this algorithm.
int64 dfs(int limit, int64 n, int64 val, int imp, int64 vmp, int emp) {
  int64 ret = 1;
  for (int i = 0; i < limit; ++i) {
    const int64 p = plist[i];
    const int nextimp = imp == -1 ? i : imp;
    const int64 nextvmp = imp == -1 ? p : vmp;
    const int64 valLimit = n / p / nextvmp;
    if (val > valLimit) break;
    int e = 1;
    for (int64 nextval = val * p;; ++e) {
      ret += dfs(i, n, nextval, nextimp, nextvmp, imp == -1 ? e : emp);
      if (nextval > valLimit) break;
      nextval *= p;
    }
  }
  return ret;
}

// 8 threads version.
struct Solver : public MValueBaseTP<Solver, int64, 8> {
  int64 batch(int64 /*n*/, int64 /*val*/, int /*imp*/, int64 /*vmp*/,
              int /*emp*/, int64 /*now*/) {
    return 1;
  }
  int64 each(int64 /*p*/, int /*e*/) { return 1; }
};

int main() {
  pe().maxPrime(100000000).init();
  for (int i = 5; i <= 16; ++i) {
    TimeRecorder tr;
    int64 cnt = Solver().solve(power(10LL, i));
    printf("1e%d\t%.2e\t%16I64d\t%s\n", i, 1. * cnt, cnt,
           tr.elapsed().format().c_str());
  }
  return 0;
}
```

The output is

```cpp
1e5     1.89e+03                    1894        0:00:00:00.008
1e6     9.11e+03                    9108        0:00:00:00.000
1e7     4.49e+04                   44948        0:00:00:00.000
1e8     2.28e+05                  228102        0:00:00:00.000
1e9     1.19e+06                 1185818        0:00:00:00.000
1e10    6.30e+06                 6298637        0:00:00:00.009
1e11    3.41e+07                34113193        0:00:00:00.059
1e12    1.88e+08               188014195        0:00:00:00.358
1e13    1.05e+09              1052806860        0:00:00:01.978
1e14    5.98e+09              5981038282        0:00:00:10.413
1e15    3.44e+10             34430179518        0:00:01:00.115
1e16    2.01e+11            200620098564        0:00:05:50.010
```


It means, if the complexity of $h$ is ignored, you can use this method to brute force an input of $10^{16}$ by multi-threads in several minuts.

## Build a code template and optimizate it
In [pe_algo](https://github.com/baihacker/pe/blob/master/pe_algo){:target="_blank"}
* **MValueBaseT** is an example to build a code template.
* **MValueBaseTP** is an example to parallelize this algorithm.

## Optimize $h$ part
Use $h(p^k) = 1$ for example, in [pe_algo](https://github.com/baihacker/pe/blob/master/pe_algo){:target="_blank"}
* **prime_s0** is the prime $\pi$ method, and the complexity is expected to be $O(n^{\frac{3}{4}})$
* **prime_s0_ex** uses binary indexed tree to optimize it, and I guess the complexity is $O(n^{\frac{2}{3}})$
* **prime_s0_parallel** uses multi-threads to optimize it, and we need to choose a proper thread number and find a strategy about when to parallize it.

# References
1. Zhizhou Ren, 2016, Some methods to compute the prefix-sum of multiplicative function
2. Zhengting Zhu, 2018, Some special arithmetic function summation problems
3. [**Min_25 sieve**](https://oi-wiki.org/math/min-25/){:target="_blank"} (chinese content)
4. Min_25, 2018.11.11 [**Sum of Multiplicative Function**](https://min-25.hatenablog.com/entry/2018/11/11/172216)
5. dengtesla, 2019, [**Detail explanning of the new Min_25 sieve $O(n^{\frac{2}{3}})$**](https://zhuanlan.zhihu.com/p/60378354){:target="_blank"} (chinese content)
6. Bohang Zhang, 2018, [**A proof for a general algorithm of summing multiplicative function**](https://zhuanlan.zhihu.com/p/33544708){:target="_blank"} (chinese content)
{% include mathjax.html %}