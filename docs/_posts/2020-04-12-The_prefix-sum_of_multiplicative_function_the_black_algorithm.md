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

Last Modified: 2025.02.23
{: style="text-align: center;"}

# Zhouge sieve [1]
Based on

$$
sf(n)=\sum_{\begin{array}{c}x \le n \\ \text{max prime factor of x} \le n^{\frac{1}{2}}\end{array}} f(x) \left (1 + \sum_{n^{\frac{1}{2}} < \text{prime p} \le \frac{n}{x}} g(p)\right)
$$

an algorithm of space complexity $O(n^{\frac{1}{2}})$ time complexity $\tilde{\cal O}(n^{\frac{3}{4}})$ ($\log{n}$ is ignored) is developed.

# Min_25 sieve [3]
Similar to [1] 6.5.4, mentioned by [2] 2.2, [3], this method defines

$$
g_{p_k}(n) = \sum_{\begin{array}{c}2 \le x \le n \\ \text{ every prime factor of x} \ge p_k\end{array}} f(x)
$$

After simplification [3], we have the **formula D**,

$$
g_{p_k}(n) = h(n)-h(p_{k-1})+\sum_{\begin{array}{c}i \ge k \\ p_i^2 \le n\end{array}}\sum_{\begin{array}{c}c \ge 1 \\ p_i^{c+1} \le n\end{array}}f(p_i^c)g_{p_{i+1}}(\frac{n}{p_i^c})+f(p_i^{c+1})
$$

$p_k$ is the $k_{th}$ prime and $h$ is the prefix-sum of $f$ defined on prime numbers.

According to [4], an improved version reduces the time complexity to $\tilde{\cal O}(n^{\frac{2}{3}})$.

# The memorized implementation
If an implementation remembers all used $g_{p_k}(n)$, similar to [1] 6.5.4, we have **formula M**,

$$
g_{p_k}(n) = g_{p_{k+1}}(n) + h(n)-h(p_{k-1})+ \sum_{\begin{array}{c}c \ge 1 \\ p_k^{c+1} \le n\end{array}}f(p_k^c)g_{p_{k+1}}(\frac{n}{p_k^c})+f(p_k^{c+1})
$$

We can also call it dp-like implementation. The space and time complexity is the same as that of **Zhouge sieve**'s.

## Proof
The number of states is given by $\sum_{i\text{ is prime}}(\frac{n}{i})^{\frac{1}{2}}$. Based on integration, $O\left(\int_{1}^{n^{\frac{1}{2}}}(\frac{n}{x})^{\frac{1}{2}}dx\right) = O(n^{\frac{3}{4}})$.

The number of state transitions is given by $\sum_{i\text{ is prime}}(\frac{n}{i^j})^{\frac{1}{2}}$ and bounded by$\sum_{i\text{ is prime}}\log_i(\frac{n}{i})(\frac{n}{i})^{\frac{1}{2}}$. Based on integration, $O\left(\int_{1}^{n^{\frac{1}{2}}}\log(\frac{n}{x})(\frac{n}{x})^{\frac{1}{2}}dx\right) = \tilde{\cal O}(n^{\frac{3}{4}})$.

The space complexity is $O(n^{\frac{1}{2}})$, we can either use two-buffer trick or update inplace while taking care of the updating order.

For all the values of $h(\frac{n}{i})$, the complexity is up to $h$.

# The black algorithm
Just implement the **formula D** directly, we usualy use a dfs to achieve it.

An interpretation that helps us uderstand this algorithm: we can divide the integers no more than $n$ into classes as $$\text{class}_{t} = \{ x = t * p \ \vert \ p \text{ is prime and } p \ge \text{max prime factor}(t) \}$$. Then just iterate all possible $t$ and compute the contribution of each class. (Mentioned by [2]).

There is an article [TEES](https://www.spoj.com/problems/TEES/){:target="_blank"} in SPOJ, and it also described this algorithm. But the content is cleared due to unknown reason. And my following test code is based on this version.

## Complexity
[2] 2.3 and [6] said that this black algorithm has an amazing performance. [6] said, the number of $t$ is $O(n^{1-\epsilon})$. Here is the code to compute the number of $t$:

```cpp
#include <pe.hpp>
using namespace pe;

int64 dfs(int limit, int64 n, int64 val, int imp, int64 vmp, int emp, int64 now,
          int64 now1) {
  int64 ret = 0;
  {
    // Deal with t = val
    // imp: index of the max prime factor of val. -1 if val = 1.
    // vmp: value of the max prime factor of val. 1 if val = 1.
    // emp: exponent of the max prime factor of val. 0 if val = 1.
    // now: f(val)
    // now1: f(val/vmp^emp)

    // we have remain >= vmp
    int64 remain = n / val;

    if (remain > vmp) {
      // handle val * q where q > vmp
    }
    if (val > 1) {
      // handle val * vmp
    } else {
      // handle f(1)
    }
    // Record the number of classes.
    ++ret;
  }
  for (int i = 0; i < limit; ++i) {
    const int64 p = plist[i];
    const int nextimp = imp == -1 ? i : imp;
    const int64 nextvmp = imp == -1 ? p : vmp;
    const int64 valLimit = n / p / nextvmp;
    if (val > valLimit) break;
    int e = 1;
    for (int64 nextval = val * p;; ++e) {
      int64 t = 1;  // F(p, e).
      ret += dfs(i, n, nextval, nextimp, nextvmp, imp == -1 ? e : emp, now * t,
                 imp == -1 ? 1 : now1 * t);
      if (nextval > valLimit) break;
      nextval *= p;
    }
  }
  return ret;
}

void TestWithDfs() {
  for (int i = 5; i <= 14; ++i) {
    TimeRecorder tr;
    int64 cnt = dfs(pcnt, Power(10LL, i), 1, -1, 1, 0, 1, 1);
    printf("1e%d\t%.2e\t%16I64d\t%s\n", i, 1. * cnt, cnt,
           tr.Elapsed().Format().c_str());
  }
}

// This implementation is based on baihacker's pe library.
using RT = int64;
struct Solver : public MValueBase<Solver, int64, /**thread_number=*/8> {
  RT Batch(int64 n, int64 val, int imp, int64 vmp, int emp, RT now, RT now1) {
    return 1;
  }
};

void TestWithPeLibrary() {
  for (int i = 5; i <= 16; ++i) {
    TimeRecorder tr;
    int64 cnt = Solver().Cal(Power(10LL, i));
    printf("1e%d\t%.2e\t%16I64d\t%s\n", i, 1. * cnt, cnt,
           tr.Elapsed().Format().c_str());
  }
}

int main() {
  PE_INIT(maxp = 100000000);
  TestWithDfs();
  TestWithPeLibrary();
  return 0;
}
```

The outputs are

```cpp
// 9900k
// Output for TestWithDfs
1e5     1.89e+03                    1894        0:00:00:00.000
1e6     9.11e+03                    9108        0:00:00:00.000
1e7     4.49e+04                   44948        0:00:00:00.000
1e8     2.28e+05                  228102        0:00:00:00.002
1e9     1.19e+06                 1185818        0:00:00:00.012
1e10    6.30e+06                 6298637        0:00:00:00.066
1e11    3.41e+07                34113193        0:00:00:00.357
1e12    1.88e+08               188014195        0:00:00:01.957
1e13    1.05e+09              1052806860        0:00:00:11.068
1e14    5.98e+09              5981038282        0:00:01:02.847
time usage: 0:00:01:16.834
// Output for TestWithPeLibrary
1e5     1.89e+03                    1894        0:00:00:00.001
1e6     9.11e+03                    9108        0:00:00:00.000
1e7     4.49e+04                   44948        0:00:00:00.000
1e8     2.28e+05                  228102        0:00:00:00.000
1e9     1.19e+06                 1185818        0:00:00:00.001
1e10    6.30e+06                 6298637        0:00:00:00.006
1e11    3.41e+07                34113193        0:00:00:00.032
1e12    1.88e+08               188014195        0:00:00:00.184
1e13    1.05e+09              1052806860        0:00:00:00.944
1e14    5.98e+09              5981038282        0:00:00:05.355
1e15    3.44e+10             34430179518        0:00:00:30.729
1e16    2.01e+11            200620098564        0:00:03:02.692
time usage: 0:00:03:40.477

// 14900k
// Output for TestWithDfs
1e5     1.89e+03                    1894        0:00:00:00.000
1e6     9.11e+03                    9108        0:00:00:00.000
1e7     4.49e+04                   44948        0:00:00:00.000
1e8     2.28e+05                  228102        0:00:00:00.000
1e9     1.19e+06                 1185818        0:00:00:00.003
1e10    6.30e+06                 6298637        0:00:00:00.019
1e11    3.41e+07                34113193        0:00:00:00.100
1e12    1.88e+08               188014195        0:00:00:00.546
1e13    1.05e+09              1052806860        0:00:00:03.022
1e14    5.98e+09              5981038282        0:00:00:17.187
time usage: 0:00:00:21.234
// Output for TestWithPeLibrary
1e5     1.89e+03                    1894        0:00:00:00.000
1e6     9.11e+03                    9108        0:00:00:00.000
1e7     4.49e+04                   44948        0:00:00:00.000
1e8     2.28e+05                  228102        0:00:00:00.000
1e9     1.19e+06                 1185818        0:00:00:00.001
1e10    6.30e+06                 6298637        0:00:00:00.005
1e11    3.41e+07                34113193        0:00:00:00.009
1e12    1.88e+08               188014195        0:00:00:00.046
1e13    1.05e+09              1052806860        0:00:00:00.245
1e14    5.98e+09              5981038282        0:00:00:01.373
1e15    3.44e+10             34430179518        0:00:00:07.997
1e16    2.01e+11            200620098564        0:00:00:46.394
time usage: 0:00:00:56.418
```


It means, if the complexity of $h$ is ignored, you can use this method to brute force an input of $10^{16}$ by multi-threads in several minutes.

## Build a code template and optimize it
In [pe_algo](https://github.com/baihacker/pe/blob/master/pe_algo){:target="_blank"}
* **MValueBase** is an example to parallelize this algorithm.

## Optimize $h$ part
Let $h(n)$ be the number of primes no more than $n$, in [pe_ntf](https://github.com/baihacker/pe/blob/master/pe_ntf){:target="_blank"}
* **PrimeS0** is the basic implementation, and the complexity is expected to be $\tilde{\cal O}(n^{\frac{3}{4}})$
* **PrimeS0Ex** uses binary indexed tree to optimize it, and I guess the complexity is $\tilde{\cal O}(n^{\frac{2}{3}})$
* **PrimeS0Parallel** uses multi-threads to optimize it, and we need to choose a proper thread number and find a strategy about when to parallelize it.

# Conclusion
Why do I call it **the black algorithm**?
* Amazing performance.
* Low complexity constant.
* Easy to understand.
* Easy to implement.
* General usability: $f$ has a looser constraints. It only requires
  * The prefix-sum of $f$ on primes can be computed efficiently.
  * It is possible to combine $f(t)$ and $h(\frac{n}{t})$ to obtain $\sum_{\text{prime p } \le \frac{n}{t}} f(t*p)$. Sometimes we need more than one $h$ function, like $h_1, h_2, ...$.

# A variant
The existing algorithm is able to compute $\sum_{i=1}^n f(i)$  assuming $\sum_{p \le \frac{n}{j}} f(p) [p \text{ is prime}]$ is known. A modified version is able to compute $\sum_{i \le \frac{n}{j}} f(i)$. The idea is, for each $$\text{class}_{t} = \{ x = t * p \ \vert \ p \text{ is prime and } p \ge \text{max prime factor}(t) \}$$, we divide the $p$ into different segments according to the values of $\frac{n}{t p}$.

```cpp
#include <pe.hpp>
using namespace pe;

struct Solver : public MValueBaseEx<Solver, int64, 8> {
  int64 Batch(int64 n, int64 val, int /*imp*/, int64 vmp, int /*emp*/,
              int64 /*now*/, int64 /*now1*/) {
    int64 t = 1;
    const int64 m = n / val;
    for (int64 i = vmp + 1; i <= m;) {
      int64 v = m / i;
      int64 maxi = m / v;
      ++t;
      // handle val * p where i <= p <= maxi
      i = maxi + 1;
    }
    // handle val * vmp * vmp if vmp > 1
    return t;
  }
  int64 F(int64 /*p*/, int /*e*/) { return 1; }
};

int main() {
  PE_INIT(maxp=100000000);
  for (int i = 5; i <= 12; ++i) {
    TimeRecorder tr;
    int64 cnt = Solver().Cal(Power(10LL, i));
    printf("1e%d\t%.2e\t%16I64d\t%s\n", i, 1. * cnt, cnt,
           tr.Elapsed().Format().c_str());
  }
  return 0;
}
```

the outputs are

```cpp
1e5     2.15e+04                   21454        0:00:00:00.000
1e6     1.25e+05                  125220        0:00:00:00.000
1e7     7.28e+05                  727870        0:00:00:00.001
1e8     4.25e+06                 4246101        0:00:00:00.010
1e9     2.49e+07                24926095        0:00:00:00.059
1e10    1.47e+08               147470529        0:00:00:00.354
1e11    8.80e+08               879838265        0:00:00:02.136
1e12    5.29e+09              5294311815        0:00:00:12.784
time usage: 0:00:00:15.813
```

# References
1. Zhizhou Ren, 2016, [Some methods to compute the prefix-sum of multiplicative function](https://github.com/enkerewpo/OI-Public-Library/blob/master/IOI%E4%B8%AD%E5%9B%BD%E5%9B%BD%E5%AE%B6%E5%80%99%E9%80%89%E9%98%9F%E8%AE%BA%E6%96%87/%E5%9B%BD%E5%AE%B6%E9%9B%86%E8%AE%AD%E9%98%9F2016%E8%AE%BA%E6%96%87%E9%9B%86.pdf){:target="_blank"} (chinese content), page 1 to page 16
2. Zhengting Zhu, 2018, [Some special arithmetic function summation problems](https://github.com/enkerewpo/OI-Public-Library/blob/master/IOI%E4%B8%AD%E5%9B%BD%E5%9B%BD%E5%AE%B6%E5%80%99%E9%80%89%E9%98%9F%E8%AE%BA%E6%96%87/%E5%9B%BD%E5%AE%B6%E9%9B%86%E8%AE%AD%E9%98%9F2018%E8%AE%BA%E6%96%87%E9%9B%86.pdf){:target="_blank"} (chinese content), page 92 to page 112
3. [**Min_25 sieve**](https://oi-wiki.org/math/min-25/){:target="_blank"} (chinese content)
4. Min_25, 2018.11.11 [**Sum of Multiplicative Function**](https://min-25.hatenablog.com/entry/2018/11/11/172216)
5. dengtesla, 2019, [**Detail explanning of the new Min_25 sieve $O(n^{\frac{2}{3}})$**](https://zhuanlan.zhihu.com/p/60378354){:target="_blank"} (chinese content)
6. Bohang Zhang, 2018, [**A proof for a general algorithm of summing multiplicative function**](https://zhuanlan.zhihu.com/p/33544708){:target="_blank"} (chinese content)

{% include mathjax.html %}
