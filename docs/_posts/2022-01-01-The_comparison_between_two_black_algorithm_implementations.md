---
layout: default
title: "The comparison between two black algorithm implementations"
mathjax: true
categories: [math]
---

<h1>{{ page.title }}</h1>
{: style="text-align: center;"}

[baihacker](https://github.com/baihacker){:target="_blank"}
{: style="text-align: center;"}

2022.01.01
{: style="text-align: center;"}

*[prerequisites] The prefix-sum of multiplicative function: the black algorithm"*

In order to enumerate $\text{class}_t$ where $t=\prod p_i^{r_i}$, we can build $t$ by iterating primes. There are two typical ways
* **Ascending** Iterate the primes by the ascending order.
* **Descending** Iterate the primes by the descending order.

The intuition is that these two implementation should have similar performance since both visit the same set of $\text{t}$. However, that's not true.

The following code compares their performances. dfs0 is **Descending** and dfs1 is **Ascending**.

```cpp
#include <cstdio>
#include <ctime>
#include <cstdint>
#include <cinttypes>
#include <iostream>
using namespace std;
using int64 = int64_t;
using uint64 = uint64_t;

const int maxp = 2000000;
int pcnt;
int pmask[maxp + 1];
int plist[maxp / 10];

static inline void InitPrimes() {
  pcnt = 0;
  for (int i = 1; i <= maxp; ++i) pmask[i] = i;
  for (int i = 2; i <= maxp; ++i) {
    if (pmask[i] == i) {
      plist[pcnt++] = i;
    }
    for (int j = 0; j < pcnt; ++j) {
      const int64 t = static_cast<int64>(plist[j]) * i;
      if (t > maxp) break;
      pmask[t] = plist[j];
      if (i % plist[j] == 0) {
        break;
      }
    }
  }
}
int64 counter1, counter2;
int64 dfs0(int limit, int64 n, int64 val, int imp, int64 vmp, int emp) {
  int64 ret = 1;
  for (int i = 0; i < limit; ++i) {
    const int64 p = plist[i];
    const int nextimp = imp == -1 ? i : imp;
    const int64 nextvmp = imp == -1 ? p : vmp;
    const int64 valLimit = n / p / nextvmp;
    if (val > valLimit) break;
    ++counter1;
    int e = 1;
    for (int64 nextval = val * p;; ++e) {
      if (e >= 2) ++counter2;
      ret += dfs0(i, n, nextval, nextimp, nextvmp, imp == -1 ? e : emp);
      if (nextval > valLimit) break;
      nextval *= p;
    }
  }
  return ret;
}

int64 dfs1(int start, int limit, int64 n, int64 val, int imp, int64 vmp,
           int emp) {
  int64 ret = 1;
  for (int i = start; i < limit; ++i) {
    const int64 p = plist[i];
    const int64 valLimit = n / p / p;
    if (val > valLimit) break;
    ++counter1;
    int e = 1;
    for (int64 nextval = val * p;; ++e) {
      if (e >= 2) ++counter2;
      ret += dfs1(i + 1, limit, n, nextval, i, p, e);
      if (nextval > valLimit) break;
      nextval *= p;
    }
  }
  return ret;
}

int main() {
  InitPrimes();
  const int64 n = 1000000000000;
  {
    counter1 = counter2 = 0;
    auto now = clock();
    int64 ans = dfs0(pcnt, n, 1, -1, 1, 0);
    auto usage = clock() - now;
    printf("%10" PRId64 "\t%10" PRId64 "\t%10" PRId64 "\t%10" PRId64 "\t%.6f\n",
           ans, counter1, counter2, counter1 + counter2,
           1. * usage / CLOCKS_PER_SEC);
  }
  {
    counter1 = counter2 = 0;
    auto now = clock();
    int64 ans = dfs1(0, pcnt, n, 1, -1, 1, 0);
    auto usage = clock() - now;
    printf("%10" PRId64 "\t%10" PRId64 "\t%10" PRId64 "\t%10" PRId64 "\t%.6f\n",
           ans, counter1, counter2, counter1 + counter2,
           1. * usage / CLOCKS_PER_SEC);
  }
  return 0;
}
```

The outputs are
```cpp
 188014195        98646232        89367962       188014194      2.045000
 188014195       184400681         3613513       188014194      4.833000
```
*The outputs of one-time execution. All the following outputs are the same.*

The running time of **Ascending** implementation is $137.81\%$ slower than that of **Descending** implementation. The outer for-loop of **Ascending** implementation is simpler than that of **Descending** because it doesn't need to find nextimp (the index if the largest prime) and nextvmp (the value of the largest prime). However, it is slower.

In order to find the root cause, $\text{counter1}$ and $\text{counter2}$ are added. The $\text{counter1}+\text{counter2}$ of the two implementations are the same: $\text{counter1}+\text{counter2}=\text{(result of dfs0 or dfs1)}-1$ because $\text{val}=1$ is not counted.

It means **Ascending** implementation spends more time on the outer for-loop and the **Descending** implementation spends more time on the inner for-loop.

# Is it caused by the number of parameters ?
The parameter number of **Ascending** implementation is one more than that of **Descending** implementation. Is this the root cause?

```cpp
int limit;
int64 dfs1(int start, int64 n, int64 val, int imp, int64 vmp, int emp) {
  int64 ret = 1;
  for (int i = start; i < limit; ++i) {
    const int64 p = plist[i];
    const int64 valLimit = n / p / p;
    if (val > valLimit) break;
    ++counter1;
    int e = 1;
    for (int64 nextval = val * p;; ++e) {
      if (e >= 2) ++counter2;
      ret += dfs1(i + 1, n, nextval, i, p, e);
      if (nextval > valLimit) break;
      nextval *= p;
    }
  }
  return ret;
}
```

The new outputs are
```cpp
 188014195        98646232        89367962       188014194      2.058000
 188014195       184400681         3613513       188014194      4.861000
```
The result is almost the same as the the previous outputs.

# Is the 'divide' operation expensive ?
The outer for-loop is simply and the only possible expensive operation in outer for-loop is "n / p / p". Let's just reduce the number of 'divide' operations by changing it to "n / (p * p)"

The new outputs are
```cpp
 188014195        98646232        89367962       188014194      2.050000
 188014195       184400681         3613513       188014194      2.537000
```

It means the 'divide' operation dominate the outer for-loop. It's known the 'divide' operation on unsigned integer is faster than that on the signed integer, let's change it to "uint64(n) / (uint64(p) * uint64(p))".

The outputs are
```cpp
 188014195        98646232        89367962       188014194      2.051000
 188014195       184400681         3613513       188014194      2.199000
```

# Apply all the findings
In the previous section we just optimize the **Ascending** implementation but the **Descending** implementation is unchanged. Let's apply all the findings to both implementations.
* Reduce the number of 'divide' operations.
* Use 'divide' operation on unsigned integer.

```cpp
#include <cstdio>
#include <ctime>
#include <cstdint>
#include <cinttypes>
#include <iostream>
using namespace std;
using int64 = int64_t;
using uint64 = uint64_t;

const int maxp = 2000000;
int pcnt;
int pmask[maxp + 1];
int plist[maxp / 10];

static inline void InitPrimes() {
  pcnt = 0;
  for (int i = 1; i <= maxp; ++i) pmask[i] = i;
  for (int i = 2; i <= maxp; ++i) {
    if (pmask[i] == i) {
      plist[pcnt++] = i;
    }
    for (int j = 0; j < pcnt; ++j) {
      const int64 t = static_cast<int64>(plist[j]) * i;
      if (t > maxp) break;
      pmask[t] = plist[j];
      if (i % plist[j] == 0) {
        break;
      }
    }
  }
}
int64 counter1, counter2;
uint64 dfs0(int limit, uint64 n, uint64 val, int imp, uint64 vmp, int emp) {
  uint64 ret = 1;
  for (int i = 0; i < limit; ++i) {
    const uint64 p = plist[i];
    const int nextimp = imp == -1 ? i : imp;
    const uint64 nextvmp = imp == -1 ? p : vmp;
    const uint64 valLimit = n / (p * nextvmp);
    if (val > valLimit) break;
    ++counter1;
    int e = 1;
    for (uint64 nextval = val * p;; ++e) {
      if (e >= 2) ++counter2;
      ret += dfs0(i, n, nextval, nextimp, nextvmp, imp == -1 ? e : emp);
      if (nextval > valLimit) break;
      nextval *= p;
    }
  }
  return ret;
}

uint64 dfs1(int start, int limit, uint64 n, uint64 val, int imp, uint64 vmp,
            int emp) {
  uint64 ret = 1;
  for (int i = start; i < limit; ++i) {
    const uint64 p = plist[i];
    const uint64 valLimit = n / (p * p);
    if (val > valLimit) break;
    ++counter1;
    int e = 1;
    for (uint64 nextval = val * p;; ++e) {
      if (e >= 2) ++counter2;
      ret += dfs1(i + 1, limit, n, nextval, i, p, e);
      if (nextval > valLimit) break;
      nextval *= p;
    }
  }
  return ret;
}

int main() {
  InitPrimes();
  const int64 n = 1000000000000;
  {
    counter1 = counter2 = 0;
    auto now = clock();
    int64 ans = dfs0(pcnt, n, 1, -1, 1, 0);
    auto usage = clock() - now;
    printf("%10" PRId64 "\t%10" PRId64 "\t%10" PRId64 "\t%10" PRId64 "\t%.6f\n",
           ans, counter1, counter2, counter1 + counter2,
           1. * usage / CLOCKS_PER_SEC);
  }
  {
    counter1 = counter2 = 0;
    auto now = clock();
    int64 ans = dfs1(0, pcnt, n, 1, -1, 1, 0);
    auto usage = clock() - now;
    printf("%10" PRId64 "\t%10" PRId64 "\t%10" PRId64 "\t%10" PRId64 "\t%.6f\n",
           ans, counter1, counter2, counter1 + counter2,
           1. * usage / CLOCKS_PER_SEC);
  }
  return 0;
}
```

The outputs are
```cpp
 188014195        98646232        89367962       188014194      1.145000
 188014195       184400681         3613513       188014194      2.208000
```

OK, the **Ascending** implementation is still slow because of the number of 'divide' operations
* $\frac{184400681}{98646232}\approx1.869313$
* $\frac{2.208000}{1.145000}\approx1.928384$

# Risk of optimization
It matters to reduce the number of 'divide' operation here. But the caveat is the $p^2$ has potential overflow risk. In this example, let's say $n=p^2$ where $p=4294967291=2^{32}-5$ is the largest prime no more than $2^{32}$. Because $\frac{n}{p^2}=1$, when it checks the next prime $4294967311=2^{32}+15$, $p^2$ will result in overflow. Fortunately, the original version "n / p / p" which execute 'divide' operation twice doesn't have this issue.

# Consider parallelization
The [pe](https://github.com/baihacker/pe) has parallelization implementations. [This](https://github.com/baihacker/pe/blob/master/example/multiplicative_function_prefix_sum_mavlue_base_ex_perf.c) compares the performance of parallelization implementations. Here are a portion of the outputs.

Use "n / p / next_vmp" and "n / p / p"
```cpp
n = 1000000000000
0:00:00:00.606
0:00:00:03.974
```

Use "n / (p * next_vmp)" and "n / (p * p)"
```cpp
n = 1000000000000
0:00:00:00.488
0:00:00:02.439
```

The time corresponds to the parallelized **Descending** and the second time corresponds the parallelized **Ascending**. The time ratio is about 5 to 6. It means, the **Ascending** implemenation is not friendly to parallelization.

{% include mathjax.html %}
