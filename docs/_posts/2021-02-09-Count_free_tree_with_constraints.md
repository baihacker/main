---
layout: default
title: "Count free tree with constraints"
mathjax: true
categories: [math]
---

<h1>{{ page.title }}</h1>
{: style="text-align: center;"}

[baihacker](https://github.com/baihacker){:target="_blank"}
{: style="text-align: center;"}

2021.02.09
{: style="text-align: center;"}

# 相关题目
 * [PE 677 Coloured Graphs](https://projecteuler.net/problem=677){:target="_blank"} 红色顶点最大度为4，蓝色顶点和黄色顶点最大度为3，黄色顶点和黄色顶点不相连，问多少不同构的具有10000个顶点的树。
 * Rosecode 554 Distinct trees I 有多少个具有1000个顶点，每个顶点的度不超过15的自由树。
 * Rosecode 564 Distinct trees II 有多少个具有1000个顶点，任意两个顶点间的距离不超过15的自由树。

# 1. 自由树和有根树的关系
*这里有根树是指有根无序树，其中无序指子结点没有顺序关系。也就是说，如果可以重排子结点使两个树相同，那么两个树被视为同构。以下有根树均指有根无序树。*

 * $2k+1$个顶点的不同构的自由树的数目=#{具有$2k+1$个顶点的不同构的每个子树大小小于$k+1$的有根树}。
 * $2k$个顶点的不同构的自由树的数目=#{具有$2k$个顶点的不同构的每个子树大小小于$k$的有根树数的数目}+#{顶点数为$k$的两个有根树顶点相连构成的自由树}。

于是问题转换为计算不同构的有根树的数目

# 2. 计算不同构的有根树的数目
令$v[i]$为大小为$i$时的不同构有根树的数目，那么$v[1] = 1$。通过已知的$i < \text{node_count}$时的$v[i]$，求$v[\text{node_count}]$。

**思路1** 适用于允许的子树个数不多的情况，可以枚举子树个数$\text{child_count}$，最后把每种情况的答案加起来，得到$v[\text{node_count}]$。给定子树的个数$\text{child_count}$，有两种算法解决该问题。

为表述方便，这里先定义一些记号

**有标记的元素的划分** 给定一个集合$S=\\{x_1,x_2,x_3...\\}$，我们称$p=\\{\text{part}_1,\text{part}_2,\text{part}_3,...\\}$是$S$的一个划分当且仅当：$\text{part}_i$是$S$的非空子集，$\text{part}_i$两两不相交，$\text{part}_i$的并是$S$。定义$Q_p(c) = \| \\{ \text{part}_i \text{ where } \|\text{part}_i\| =c \\} \|$。对划分的计数参考[http://oeis.org/A000110](http://oeis.org/A000110){:target="_blank"}。

**无标记的元素的划分** 给定$n$个相同的元素，如果有$\sum \text{part}_i = n$且$\text{part}_i > 0$，我们称$p=\\{\text{part}_1,\text{part}_2,\text{part}_3,...\\}$是对无标记的$n$个元素的划分。定义$Q_p(c) = \| \\{ \text{part}_i \text{ where } \text{part}_i =c \\} \|$。对划分的计数参考[http://oeis.org/A000041](http://oeis.org/A000041){:target="_blank"}。

注意，在无标记的元素划分中$\text{part}_i$是一个数，我们只关心某个部分的大小。而在有标记的元素划分中，$\text{part}_i$是一个子集，我们关心把哪些元素放在一起。

**算法1.1** 对于固定的$\text{child_count}$，考虑利用无标记的元素的划分，把有根树分为若干类：不同类之间的有根树不同构，而某个类内的有根树的数目可以有效算出。

定义有根树到无标记的元素的划分的映射$\text{TP}$：对于一个有根树，把所有的相同的子树拿出来，放在一起，计算数量，作为划分的一个元素。重复这个过程直到把所有的子树拿完，这样我们得到一个划分。划分的原像集就是一类有根树。现在的问题是，给定划分$P$，求原像的个数，也就是$\|\text{TP}^{-1}(P)\|$。

更形式化地描述这个问题，用

$$ \sum \text{part}_i\text{ }x_i = \text{tree}_{\text{node_count}} $$

表示$x_i$这棵子树出现了$\text{part}_i$次，加上一个根，最终形成了具有$\text{node_count}$个顶点的有根树。考虑移掉根，再简化符号

$$\sum \text{part}_i\text{ }x_i = \text{node_count} - 1$$

意思是$x_i$这棵树出现了$\text{part}_i$次，构成了有$\text{node_count}-1$个顶点的森林。

对于本题，我们加上两条限制：
* $x_i$各不相同。
* $\|x_i\|>0$，即子树$x_i$非空。

如果满足这个等式以及这两条限制的$x_i$的取法数为s，那么

$$ \frac{s}{\prod_t Q_p(t)!} $$

就是该划分下的答案。除以分母的原因是：在求上述方程的解数时，有重复计数。比如 $\text{part}_i=\text{part}_j=\text{part}_k$ ，任意交换$x_i,x_j,x_k$后的解仍然被计数，但我们的目标是只计数一次。

**问题Q** 方程$\sum a_i x_i = n, x_i \ne x_j \text{ if } i \ne j$的解数。
 * 该方程可以是$a_i, x_i, n$都是整数，$a_i x_i$表示普通的整数乘法，一般还要加上$x_i\ge 0$的限制。
 * 该方程也可以是对应于上面提到的子树构成森林的方法数，同时有$\|x_i\|>0$的限制。

问题Q可以用**集合划分mobius函数（容斥原理）**的方法解决。直观上对方法的理解是：如果去掉$x_i$各不相同的限制，问题容易求解。但是里面会有重复计数，比如$x_i$和$x_j$相同的也被计算进去了，所以要减去一些，然后减多了，又要加上一些，如此往复。

**步骤1** 枚举集合$\\{x_1,x_2,x_3,...\\}$所有的划分，每个划分对应于一个原问题的松驰问题
* 同一部分内的$x_i$相同
* 不同部分的$x_i$没有限制

**步骤2** 对于指定的划分，重写方程

以$2x_1+x_2+x_3=8$为例，考虑有标号划分$\\{\\{x_1,x_3\\},\\{x_2\\}\\}$，由于要求$x_1=x_3$，新方程是$3x_1+x_2=8$。

**步骤3** 求重写后的方程的解数

重写后的方程去掉了限制，可以用dp求解，而dp的过程实际上就是做多项式乘法。对于重写后的方程$\sum a_i x_i = n$，令$f(x)=\sum_{i=0}^{n} v[i] x^i$，则答案是$\prod f(x_i^{a_i}) $中$x^n$的系数。
 * 对于$x_i$是普通数的情况，$v[i]=1$。
 * 对于$x_i$是子树的情况，$v[i]$是子树大小为$i$时的方法数，其中$v[0]=1$。

**步骤4** 对于每个有标号划分的限制下方程的解数，乘以对应的mobius函数值最后求和即是原问题的解

而对应的mobius函数定义如下
 * 符号=$(-1)^{被划分的集合的元素个数+划分成的部分数}$。
 * 绝对值=$\prod_{\text{part in partition}} (\|\text{part}\|-1)!$。

**参考**
* 2014年12月 pe495，grechnik给的代码本质上就是用mobius函数。
* 2014年12月 pe495，我使用了另一个式子，本质上讲，mobius可以用来优化该式。
* 2018年9月 pe636中，jschnei显示地指出这里是Mobius function for set partition。

**我在pe495中的做法** 引入如下记号和定义
 * $E(\text{partition})$表示$\text{partition}$的每个$\text{part}$内$x_i$值相同，而不同$\text{part}$间$x_i$值不同的解数。
 * $F(\text{partition})$表示$\text{partition}$的每个$\text{part}$内$x_i$值相同，而不同$\text{part}$间$x_i$无限制的解数。
 * $\text{PI}$表示划分$\\{\\{x_1\\},\\{x_2\\},\\{x_3\\},...\\}$。
 * 集合划分偏序关系：$\le$。如果划分$a$，可以通过合并几个部分，得到$b$，那么$b \le a$。另一个等价的说法是，如果$b$上可以进一步细分，得到$a$，那么$b \le a$。

那么有

$$F(\text{PI})=\sum_{\text{partition} \le \text{PI}} E(\text{partition})$$

我的做法是将该式写为

$$E(\text{PI})=F(\text{PI})-\sum_{\text{partition} \le \text{PI} \text{ and } \text{partition} \ne \text{PI}}E(\text{partition})$$

直接应用本算法比较慢，为了高效计算右边，我避免了重写后相同的方程的重复计算。

问题Q的解法直接给出

$$E(\text{PI})=\sum_{\text{partition} \le \text{PI}} \text{mobius}(\text{partition}, \text{PI}) F(\text{partition})$$

写成泛函的形式就是如果$F=1*E$，那么$E=1^{-1}F$。$1^{-1}$正好是定义在集合划分偏序关系上的$\text{mobius}$函数。


**复杂度** 假设一共$n$个划分，用T表示计算单个$E$的复杂度，那么我的做法的复杂度是$O(n T + n^2)$，而假定单个$\text{mobius}$函数的计算的复杂度是$O(K)$的情况下，用$\text{mobius}$函数的复杂度是$O(n K + n T)$。
* 通常$K=1$，这样的话用$\text{mobius}$函数的复杂度较低。
  * 对于本题的情况，我的做法的复杂度高于利用mobius函数的做法。
  * 考虑定义在整除关系上的$F=1*E$，$n$表示目标数的因子个数（更严格地说是square free的因子个数），也可以认为$K=1$。
* 如果$K=n$，则复杂度没有明显提升。

**算法1.2** 使用Burnside引理

原问题可以重新表述为：考虑$\text{child_count}$个子树构成的森林，给每个子树带上标号，如果在某个置换下后两个森林同构，那么只计数一次，有多少方法。

根据Burnside引理，枚举$\text{child_count}!$个置换，计算在每个置换下不变的方法数，加起来后除以举$\text{child_count}!$。

对于每个置换，只需要循环指标（cyclic index）就可以求该置换下不变的方法数。而不同的循环指标（也就是无标记划分），在不超过50个子树的情况下我们也可以不算太慢地枚举，参考[http://oeis.org/A000041](http://oeis.org/A000041){:target="_blank"}。而直接枚举所有置换需要$50!$的枚举量，大概是3.04e64。

所以求解过程变成
* 枚举循环指标
* 对于每个循环指标求解后乘以对应的置换数
  * 和求问题Q步骤2中得到的的方程的解数一样。一个循环就是一个无标记划分中的一个部分。要求同一划分中的树同构和要求一个循环中的树同构是同一回事。
  * 设循环指标是$\prod a_i^{b_i}$，也就是说长度为$a_i$的循环有$b_i$个，令$f(x)=\sum_{i < \text{node_count}}v[i] x^i$,  那么$\prod f(x_i^{a_i})^{b_i}$中$x^{\text{node_count}-1}$的系数表示在该循环指标对应的置换下不变，结点数为$\text{node_count}-1$，有$\text{child_count}$个子树的森林的个数。
* 加起来除以$\text{child_count}!$。

用$P_{t,i}$表示$t$个子树下的一个循环指标，令$g(P_{t,i}) = C(P_{t,i}) \prod f(x_i^{a_i})^{b_i}$，其中$C(P_{t,i}) = \frac{该循环指标对应的置换数}{t!}$。可以得到关于$f(x)$的方程

$$f(x) = x + x \sum_{t,i} g(P_{t,i})$$

其中求和前的$x$表示有根树和森林之间刚好相差一个点。这个方程可以通过从小到大枚举$x$的指数求解。也就是说，将$f(x)=\sum_{i< \text{node_count}} v[i] x^i$，代入右边，取$x^{\text{node_count}}$的系数，得到$v[\text{node_count}]$。（参考：pe677 cz_xuyixuan的解法）

而该方程右边可以利用FFT计算，单次计算一个$v[\text{node_count}]$的复杂度为$O(单次计算右边时多项式乘法的次数 * \text{node_count} * \log(\text{node_count}))$。用$\text{maxn}$表示需要计算的最大顶点数，$\text{node_count} \le \text{maxn}$，由于方程只要前$O(\text{maxn})$项的值，所以整体复杂度是$O(单次计算右边时多项式乘法的次数 * \text{maxn}^2 * \log(\text{maxn}))$。

估计单次计算右边时多项式乘法的次数。对于固定的子树个数c，有$P(c)$个无标记划分。对于固定的划分，考虑$\prod f(x_i^{a_i})^{b_i}$，最多有$c^{\frac{1}{2}}$个i，每个$f(x_i^{a_i})^{b_i}$在求$b_i$次方时需要的乘法次数$\log(b_i) \le \log(c)$，所以上界为$P(c)(c^{\frac{1}{2}} + c^{\frac{1}{2}} \log(c))$。最后需要考虑$c$从$1$到$\text{maxc}$加起来，乘法的数量为$O(\text{maxc}^{\frac{3}{2}} P(\text{maxc}) \log(\text{maxc}))$。

整体复杂度为$O(\text{maxc}^{\frac{3}{2}} P(\text{maxc}) \log(\text{maxc}) \text{maxn}^2 \log(\text{maxn}))$。考虑到$\text{maxc} \le \text{maxn}$，
得到$O(\text{maxn}^{\frac{7}{2}} P(\text{maxn}) \log^2(\text{maxn}))$。

至此，基于思路1给出了两种算法。

**思路2** 直接$\text{dp}$，$\text{dp}[i][j]$表示考虑到子树的最大$\text{size}$为$i$，顶点个数为$j$的有根树的数目。

如果有必要，还要带上其它维度信息
* rc554 需要带上子树个数的信息，最终用于顶点的度限制。
* rc564 需要带上子树的深度信息，最终用于顶点距离的限制。

**更新** 假定$\text{dp}[i\le a][j\le \text{maxn}]$已经知道，$s[a+1]=\sum_{i \le a+1}\text{dp}[i][a+1]$ 正好是顶点数为$a+1$的子树个数。我们可以考虑取$k$个顶点数是$a+1$的子树，加到$\text{dp}[i\le a][j\le \text{maxn}]$对应的树上，用于更新$dp[a+1][]$。而$s[a+1]$个不同树中取$k$个的方法数由重组合公式给出：$\binom{s[a+1]+k-1}{k}$。

**前缀和优化** 用$\text{dp}[i][j]$表示子树最大大小不超过$i$，顶点个数为$j$的有根树的数目。$\text{dp}[a][a+1]$正好是前面提到的$s[a+1]$，然后用同样的方法更新$\text{dp}[a][]$得到$\text{dp}[a+1][]$。

**滚动数组优化** 注意到$\text{dp}[i+1][]$只依赖于$\text{dp}[i][]$，所以可以只用$\text{dp}[2][\text{maxn}+1]$的空间。

**原地更新** 如果按一定顺序更新，可以原地更新。

思路2主要参考了shs.10978在pe677和rc554中的做法。我在rc564中使用了该思路，耗时为0.372秒。

# 3. 应用

* rc554 可以用思路1算法1.2，或思路2。
* rc564 可以用思路2。
* pe677 可以用思路1算法1.1，或思路1算法1.2，或思路2。我使用的是思路1算法1.1，其中手写了2到4个无标记元素的划分。


**例子** 给定顶点个数，有多少不同的自由树，同构的自由树只计算一次。

**做法** 直接使用思路2进行$\text{dp}$。

```cpp
#include <pe.hpp>

// http://oeis.org/A000055

const int64 mod = 1000000007;
const int maxn = 10000;
using MT = NMod64<mod>;

const int64 inv2 = ModInv(2LL, mod);

MT dp[maxn + 1];

int64 invs[maxn + 1];
MT pre[maxn + 1];

SL void update(int size, int n, MT val) {
  const int maxk = n / size;
  MT now = 1;
  for (int k = 1; k <= maxk; ++k) {
    now *= (val + k - 1) * invs[k];
    pre[k] = now;
  }
  for (int a = n; a >= 0; --a)
    if (dp[a].value()) {
      const auto t = dp[a];
      for (int k = 1; a + k * size <= n; ++k) {
        dp[a + size * k] += t * pre[k];
      }
    }
}

MT solve(int n) {
  memset(dp, 0, sizeof dp);
  dp[1] = 1;
  for (int i = 1; i < (n + 1) / 2; ++i) {
    update(i, n, dp[i]);
  }
  MT ans = dp[n];
  if (n % 2 == 0) {
    ans += dp[n / 2] * (dp[n / 2] + 1) * inv2;
  }
  return ans;
}

int main() {
  InitInv(invs, maxn, mod);
  for (int i = 1; i <= 20; ++i) {
    cout << i << " " << solve(i) << endl;
  }
  return 0;
}
```

输出
```
1 1
2 1
3 1
4 2
5 3
6 6
7 11
8 23
9 47
10 106
11 235
12 551
13 1301
14 3159
15 7741
16 19320
17 48629
18 123867
19 317955
20 823065
```

参考值在[http://oeis.org/A000055](http://oeis.org/A000055){:target="_blank"} （就是打开OEIS时输入框里作为placeholder的那个序列）

{% include mathjax.html %}
