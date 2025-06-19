---
layout: default
title: "Tuple Enumeration"
mathjax: true
categories: [math]
---

<h1>{{ page.title }}</h1>
{: style="text-align: center;"}

[baihacker](https://github.com/baihacker){:target="_blank"}
[Gemini](https://gemini.google.com/app){:target="_blank"}
{: style="text-align: center;"}
This article refines methods for calculating the sum of a function over a set of k-tuples. The function's value is constant under permutations of a tuple's elements.

The key challenge is the enormous number of possible tuples ($n^k$). This is addressed by focusing only on unique combinations with repetition, drastically reducing the search space. The article presents an evolution of solutions:
1.  A basic recursive implementation to enumerate unique tuples.
2.  A parallelized version using batch processing to improve performance through better load balancing.
3.  An advanced approach using memoization with a perfect hash function to efficiently handle cases where function evaluations have inter-dependencies.

Finally, it discusses strategies for managing concurrent cache access in a parallel memoized solution.

# Problem
This article addresses the problem of calculating $\sum f(t)$, where `t` is a k-tuple of integers from the range $[0, n)$. A key property of the function `f` is that its value is invariant under permutation of the tuple's elements, meaning $f(t_1) = f(t_2)$ if $t_1$ is a permutation of $t_2$.

# Analysis
A naive approach would be to iterate through all $n^k$ possible tuples. Since the function's value depends only on the multiset of elements in the tuple, not their order, we can significantly reduce the computation by considering only unique combinations with repetition. The number of such unique tuples is given by the [formula for combinations with repetition](https://en.wikipedia.org/wiki/Combination#Number_of_combinations_with_repetition){:target="_blank"}: $\binom{n+k-1}{k}$.

The table below contrasts the two counts for various values of `n` and `k`.

$$
\begin{array}{|c|c|c|}
n, k    & n^k      & \binom{n+k-1}{k} \\
\hline
50, 5   & 3.125 * 10^{8}  & 3.163 * 10^{6} \\
50, 7   & 7.813 * 10^{11} & 2.319 * 10^{8} \\
100, 5  & 1.000 * 10^{10} & 9.196 * 10^{7} \\
100, 7  & 1.000 * 10^{14} & 2.437 * 10^{10} \\
150, 5  & 7.594 * 10^{10} & 6.760 * 10^{8} \\
150, 7  & 1.709 * 10^{15} & 3.892 * 10^{11} \\
\end{array}
$$

# Implementation
The C++ code below implements a recursive depth-first search (DFS) to enumerate all unique, sorted tuples.
```c++

#include <bits/stdc++.h>
using namespace std;

using int64 = long long;

int64 comb[200][200];
int64 C(int n, int m) {
  if (m < 0 || m > n) return 0;
  return comb[n][m];
}

pair<int64, int64> dfs(int index, int max_value, int* history,
                       int consecutive_value_count, int64 coefficient) {
  if (index == -1) {
    return {1LL, coefficient};
  }

  pair<int64, int64> ret = {0, 0};

  for (int value = 0; value <= max_value; ++value) {
    history[index] = value;
    const int new_consecutive_value_count =
        value == history[index + 1] ? consecutive_value_count + 1 : 1;
    pair<int64, int64> t =
        dfs(index - 1, value, history, new_consecutive_value_count,
            coefficient / new_consecutive_value_count);
    ret.first += t.first;
    ret.second += t.second;
  }

  return ret;
}

void Test(int n, int k) {
  int history[256];
  history[k] = -1;
  int64 coefficient = 1;
  for (int i = 2; i <= k; ++i) coefficient *= i;
  pair<int64, int64> result = dfs(k - 1, n - 1, history, -1, coefficient);
  cerr << result.first << " " << result.second << endl;
}

int main() {
  for (int i = 0; i < 200; ++i)
    for (int j = 0; j <= i; ++j)
      comb[i][j] = j == 0 || j == i ? 1 : comb[i - 1][j] + comb[i - 1][j - 1];

  Test(50, 5);
  return 0;
}
```

The recursion's base case (`index == -1`) is reached when a complete tuple has been formed. At this point, the `coefficient` variable correctly holds the number of distinct permutations for that specific tuple. By iterating values in increasing order, this approach guarantees that the generated tuples (stored in `history`) are sorted, ensuring each unique combination is visited only once.

# Parallelization
A simple parallelization strategy is to partition the problem based on the value of one of the tuple's elements.
```c++
void Test(int n, int k) {
  int64 sum = 0;
  for (int value = 0; value <= n - 1; ++value) {
    int64 count = C(value + 1 + k - 2, k - 1);
    cerr << count << endl;
    sum += count;
  }
  cerr << endl;
  cerr << sum << endl;
}
```
However, this can lead to imbalanced workloads, as some partitions may be significantly larger than others, hindering parallel efficiency.

A more effective approach leverages the fact that we can calculate the number of tuples in any subproblem using the combination formula: $\binom{\text{max_value} + \text{index} + 1}{\text{index} + 1}$. We can set a threshold; when the number of tuples in a subproblem falls below this threshold, we create a "batch task" for it. This ensures that no single task is excessively large, leading to better load balancing among parallel threads. The implementation below generates these batch tasks and processes them in parallel using OpenMP.

```c++

#include <bits/stdc++.h>
#include <omp.h>
using namespace std;

using int64 = long long;

int64 comb[200][200];
int64 C(int n, int m) {
  if (m < 0 || m > n) return 0;
  return comb[n][m];
}

struct Batch {
  int index;
  int max_value;
  vector<int> history;
  int consecutive_value_count;
  int64 coefficient;
};

int64 threshold = 1000000;
vector<Batch> batches;

void dfs_gen_batch(int index, int max_value, int* history, int k,
                   int consecutive_value_count, int64 coefficient) {
  int64 will_process = C(max_value + 1 + index, index + 1);
  if (will_process <= threshold) {
    batches.push_back(Batch{
        .index = index,
        .max_value = max_value,
        .history = vector<int>(history, history + k),
        .consecutive_value_count = consecutive_value_count,
        .coefficient = coefficient,
    });
    return;
  }

  for (int value = 0; value <= max_value; ++value) {
    history[index] = value;
    const int new_consecutive_value_count =
        value == history[index + 1] ? consecutive_value_count + 1 : 1;
    dfs_gen_batch(index - 1, value, history, k, new_consecutive_value_count,
                  coefficient / new_consecutive_value_count);
  }
}

pair<int64, int64> dfs(int index, int max_value, int* history,
                       int consecutive_value_count, int64 coefficient) {
  if (index == -1) {
    return {1LL, coefficient};
  }

  pair<int64, int64> ret = {0, 0};

  for (int value = 0; value <= max_value; ++value) {
    history[index] = value;
    const int new_consecutive_value_count =
        value == history[index + 1] ? consecutive_value_count + 1 : 1;
    pair<int64, int64> t =
        dfs(index - 1, value, history, new_consecutive_value_count,
            coefficient / new_consecutive_value_count);
    ret.first += t.first;
    ret.second += t.second;
  }

  return ret;
}

void Test(int n, int k) {
  int history[256];
  history[k] = -1;
  int64 coefficient = 1;
  for (int i = 2; i <= k; ++i) coefficient *= i;

  dfs_gen_batch(k - 1, n - 1, history, k, -1, coefficient);

  pair<int64, int64> result = {0, 0};

  omp_lock_t locker;
  omp_init_lock(&locker);
#pragma omp parallel for schedule(dynamic, 1) num_threads(8)
  for (int i = 0; i < batches.size(); ++i) {
    Batch task = batches[i];
    pair<int64, int64> t = dfs(task.index, task.max_value, task.history.data(),
                               task.consecutive_value_count, task.coefficient);
    omp_set_lock(&locker);
    result.first += t.first;
    result.second += t.second;
    omp_unset_lock(&locker);
  }
  omp_destroy_lock(&locker);
  cerr << result.first << " " << result.second << endl;
}

int main() {
  for (int i = 0; i < 200; ++i)
    for (int j = 0; j <= i; ++j)
      comb[i][j] = j == 0 || j == i ? 1 : comb[i - 1][j] + comb[i - 1][j - 1];

  Test(100, 7);
  return 0;
}
```

# Memoization
Let's consider scenarios where the evaluation of $f(t_1)$ depends on the result of $f(t_2)$. Using standard library containers like `std::map` or `std::unordered_map` for memoization can introduce performance overhead and high memory consumption.

A more efficient solution is to use a perfect hash function, which uniquely maps each tuple to an integer in the range $[0, M)$, where $M$ is the total count of unique tuples. We can define the hash of a tuple `t` as its lexicographical rank among all unique sorted tuples. This hash can be calculated in two ways:
1.  A direct calculation that counts all lexicographically smaller tuples, with a complexity of $O(k)$ per tuple.
2.  An efficient recursive approach where the hash (or `offset`) is passed down and updated during the DFS traversal, incurring no extra cost per tuple.

```c++
#include <bits/stdc++.h>
using namespace std;

using int64 = long long;

int64 comb[200][200];
int64 C(int n, int m) {
  if (m < 0 || m > n) return 0;
  return comb[n][m];
}

int64 get_hash(int* history, int k) {
  int64 ret = 0;
  int remain = k;
  for (int i = k - 1; i >= 0;) {
    int j = i;
    while (j >= 0 && history[j] == history[i]) --j;
    for (int d = 0; d < i - j; ++d)
      ret += C(history[i] + (remain - d) - 1, remain - d);
    remain -= i - j;
    i = j;
  }
  return ret;
}

int64 dfs(int index, int max_value, int* history, int k, int64 offset) {
  if (index == -1) {
    assert(get_hash(history, k) == offset);
    return 1;
  }

  int64 processed = 0;

  for (int value = 0; value <= max_value; ++value) {
    history[index] = value;
    processed += dfs(index - 1, value, history, k, offset + processed);
  }

  return processed;
}

void Test(int n, int k) {
  int history[256];
  history[k] = -1;
  int64 count = dfs(k - 1, n - 1, history, k, 0);
  cerr << count << endl;
}

int main() {
  for (int i = 0; i < 200; ++i)
    for (int j = 0; j <= i; ++j)
      comb[i][j] = j == 0 || j == i ? 1 : comb[i - 1][j] + comb[i - 1][j - 1];

  Test(100, 5);
  return 0;
}
```

Memoization introduces challenges for parallelization due to potential data dependencies. If dependencies only exist on lexicographically smaller tuples ($t_2 < t_1$), we can process batches sequentially while parallelizing the computations *within* each batch. To avoid data races, each thread can maintain a local cache. Results from dependent computations are first checked in a shared, read-only cache of prior batches, and then in the thread's local cache. The local caches are then merged into the shared cache after the batch is complete.

For more complex dependency patterns, threads can share a global cache. To manage concurrent writes, we can use an array of locks. When updating the value for $f(t_2)$, a thread acquires a lock based on its hash, for instance, $\text{hash}(t_2) \pmod P$, where $P$ is the number of locks and it is prime. It's assumed that the reading operation doesn't return partially update results.

{% include mathjax.html %}
