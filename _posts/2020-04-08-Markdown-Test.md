---
layout: default
title: Markdown test
mathjax: true
---

<h1>{{ page.title }}</h1>

# 一级标题

## 二级标题

### 三级标题

- bullet_name

- ~~被划掉的文字~~
- ~~被划掉的文字~~

1. number1
2. number2

- [x] 选中了的框
- [ ] 未选中的框

> 文字
> 文字

[文字内容](链接)

{% highlight cpp linenos%}
using int64 = long long;
{% endhighlight %}

$$
a+b\le c
$$

$\int x^2 dx$

{% include mathjax.html %}