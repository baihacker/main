---
layout: default
title: Comments on two counting formulas
mathjax: true
categories: [math]
---

<h1>{{ page.title }}</h1>
{: style="text-align: center;"}

[baihacker](https://github.com/baihacker){:target="_blank"}
{: style="text-align: center;"}

2020.04.07
{: style="text-align: center;"}


*[optional] read the first 3 chapters of generatingfunctionology [1] to help understand this article.*

# Two counting formulas
In generatingfunctionology [1] [p.81,p.93], we have two counting formulas

**Theorem 3.4.1 (The exponential formula).** Let $\mathcal{F}$ be an exponential be an exponential family whose deck and hand enumerators are $\mathcal{D}(x)$ and $\mathcal{H}(x,y)$, respectively. Then

$$
\mathcal{H}(x,y) = e^{y\mathcal{D}(x)}
$$

In detail, the number of hands of weight n and k cards is

$$
\text{h}(n,k) = \left [\frac{x^n}{n!} \right ] \left \{ \frac{\mathcal{D}(x)^k}{k!} \right \}
$$

**Theorem 3.14.1.** In a prefab P whose hand enumerator is H(x,y) we have

$$
\mathcal{H}(x,y)=\prod_{n=1}^{\infty}\frac{1}{(1-yx^n)^{d_n}}
$$

where $d_n$ is the number of cards in the $n_{th}$ deck ($n \ge 1$).

The **deck** can be viewed as standard **structure pattern** and **hand** can be viewed as the **target with structure pattern**. These two theorems tell us how to compute the hand if the deck enumerator is known. Moreover, inside the target, 3.4.1 is for the target whose element has labels while 3.14.1 is for the target whose element doesn’t have labels.

## Labeled ball unlabeled box 
Based on theorem 3.4.1, the generating function is

$$
\mathcal{H}(x,y)=e^{y(\sum_{i=1}^{\infty}\frac{x^i}{i!})}=e^{y(e^x-1)}
$$

And if there are $n$ balls $m$ boxes, the answer is

$$
\left [ \frac{x^n}{n!}y^m\right ]\left \{ \mathcal{H}(x,y) \right \}=S(n,m)
$$

See [Stirling_numbers_of_the_second_kind](https://en.wikipedia.org/wiki/Stirling_numbers_of_the_second_kind#Generating_functions){:target="_blank"}.

## Unlabeled ball unlabeled box 
Based on theorem 3.14.1, the generating function is

$$
\mathcal{H}(x,y)=\prod_{i=1}^{\infty}\frac{1}{1-yx^i}
$$

And if there are $n$ balls $m$ boxes, the answer is

$$
\left [ \frac{x^n}{n!}y^m\right ]\left \{ \mathcal{H}(x,y) \right \}
$$

See [Partition_function_(number_theory)](https://en.wikipedia.org/wiki/Partition_function_(number_theory)){:target="_blank"}.

# Consider labeled boxes
Actually, the two formulas are applied to the problems where the box is not labeled. (Each structure in the target has a label). So what’s the formula? The answer is simpler.

## Labeled ball labeled box 
**Theorem 3.4.1’.**

$$
\mathcal{H}(x,y) = \sum_{i=0}^{\infty}(y\mathcal{D}(x))^i
$$

*H,D are exponential generating function*

So, for the problem we have

$$
\mathcal{H}(x,y) = \sum_{i=0}^{\infty}(y\sum_{j=0}^{\infty}\frac{x^j}{j!})^{i}=\sum_{i=0}^{\infty}e^{ix}y^i
$$

And if there are n balls m boxes, the answer is 

$$
\left [ \frac{x^n}{n!}y^m\right ]\left \{ \mathcal{H}(x,y) \right \}=m^n
$$

## Unlabeled ball labeled box 
**Theorem 3.14.1’.**

$\mathcal{H}(x,y) = \sum_{i=0}^{\infty}(y\mathcal{D}(x))^i$

*H,D are normal generating function*

So, for this problem we have 

$$
\mathcal{H}(x,y) = \sum_{i=0}^{\infty}(y\sum_{j=0}^{\infty}x^j)^{i}=\sum_{i=0}^{\infty}(\frac{y}{1-x})^{i}
$$

And if there are n balls m boxes, the answer is

$$
\left [ x^ny^m\right ]\left \{ \mathcal{H}(x,y) \right \}=\left [ x^n\right ]\left \{ \frac{1}{(1-x)^m} \right \}=\binom{m+n-1}{n}
$$

See [Number_of_combinations_with_repetition](https://en.wikipedia.org/wiki/Combination#Number_of_combinations_with_repetition#Number_of_combinations_with_repetition){:target="_blank"}

# A trick of theorem 3.14.1.
Since $F(x)=\prod \frac{1}{(1-x^k)^{g(k)}}$, we have

$$
\log(F(x))=\sum g(k)\log(\frac{1}{1-x^k})=\sum g(k)\sum\frac{x^{km}}{m}=\sum\frac{1}{m}G(x^m)
$$

then

$$
F(x)=\exp^{\sum\frac{1}{k}G(x^k)}
$$

It gives a way to compute $F(x)$ fast if G is known. (based on generatingfunctionology [1], [pp.93-94]).

# Another trick of both theorems
Let $y=1$ (we don’t care the number of used patterns), and use $x \text{D} \log$ trick, we can get the relationship between $\mathcal{H}$ and $\mathcal{D}$。If $\mathcal{H},\mathcal{D}$ are the same, maybe they are off by $x$ (usually off by $x$), we can get the formula which can be used to compute $\mathcal{H}$. It happens when the problem itself has an off by one structure, e.g. forest and tree. (generatingfunctionology [1], [p87,pp.89-90,pp.93-94,pp.102-103]).

# References
1. Herbert S. Wilf, 1992, generatingfunctionology (second edition)


{% include mathjax.html %}