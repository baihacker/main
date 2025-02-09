---
layout: default
title: "A Survey on C++ Class Static Data Members"
mathjax: true
categories: [math]
---

<h1>{{ page.title }}</h1>
{: style="text-align: center;"}

[baihacker](https://github.com/baihacker){:target="_blank"}
[ChatGPT](https://chatgpt.com/){:target="_blank"}
{: style="text-align: center;"}

2025.02.09
{: style="text-align: center;"}

Static data members in C++ have evolved significantly over different language standards. This article provides an overview of their definition, initialization, and how C++ has improved their usage over time.

For further details, refer to the official documentation on **[cppreference](https://en.cppreference.com/w/cpp/language/static#Static_data_members){:target="_blank"}**.

Special thanks to **ChatGPT** for assisting in refining this article.

---

## **Static Data Members in C++03**

In **C++03**, static data members must be **declared inside the class** but **defined separately** in a `.cpp` file:

```cpp
// header file
class A {
    static AllType a;
    static const AllType b;
};

// cpp file
AllType A::a;
const AllType A::b;
```

For **`const` integral types**, C++03 allows **in-class initialization** to avoid a separate definition in the `.cpp` file:

```cpp
// header file
class A {
    static const IntegralType b = initial_value;
};

// cpp file
// This definition is required if b is ODR-used (e.g., taking &A::b).
const IntegralType A::b;
```

However, **reinitializing the static member in the `.cpp` file is not allowed** in C++03:

```cpp
// header file
class A {
    static const IntegralType b = initial_value;
};

// cpp file
const IntegralType A::b = initial_value; // ❌ Not allowed in C++03
```

---

## **Changes in C++11**

**C++11 introduced `constexpr`**, which has stricter requirements on initialization. Unlike `const`, `constexpr` variables can be used in **constant expressions**, making them useful for:
- **Array sizes**
- **`switch` conditions**
- **Template parameters**

```cpp
constexpr int initial_value = 1;
constexpr int different_initial_value = 2;
class A {
  static const Type a = initial_value;
  static constexpr Type b = initial_value;
  static Type d;
};

// cpp file

// const Type A::a = initial_value; // ❌ Error: duplicate initialization
// const Type A::a = different_initial_value; // ❌ Error: duplicate initialization
const Type A::a;  // ✅

// constexpr Type A::b = initial_value; // ❌ Error: duplicate initialization
// constexpr Type A::b = different_initial_value; // ❌ Error: duplicate initialization
constexpr Type A::b;  // ✅

Type A::d;      // ✅
Type A::d = 1;  // ✅
```

---

## **Enhancements in C++17: Inline Static Variables**

C++17 introduced **inline static variables**, which greatly simplify static data member handling:

- **No longer required to be const integral types**.
- **No longer need to worry about ODR-use** (One Definition Rule use).

### **Example: Inline Static Variable in C++17**

```cpp
struct A {
    inline static Type a = initial_value;  // Defined in the class
    inline static const Type b = initial_value;  // Defined in the class
    inline static constexpr Type c = initial_value;  // Defined in the class
};
```

### **Optional External Redeclaration**

This redeclaration without an initializer is permitted for constexpr, but it is deprecated.

```cpp
// header file
class A {
  inline static const Type a = initial_value;
  inline static constexpr Type b = initial_value;
  inline static Type c = initial_value;
  inline static Type d;
};

// cpp file (redundant but valid)

// const Type A::a = initial_value; // ❌ Error: duplicate initialization, redefinition
// const Type A::a = different_initial_value; // ❌ Error: duplicate initialization, redefinition
// const Type A::a; // ❌ Error: redefinition

// constexpr Type A::b = initial_value; // ❌ Error:duplicate initialization
// constexpr Type A::b = different_initial_value; // ❌ Error:duplicate initialization
constexpr Type A::b; // ✅ Allowed but redundant

// Type A::c = initial_value; // ❌ Error: duplicate initialization, redefinition
// Type A::c = different_initial_value; // ❌ Error: duplicate initialization, redefinition
// Type A::c; // ❌ Error: redefinition

// Type A::d; // ❌ Error: redefinition
// Type A::d = 1; // ❌ Error: redefinition

```

### **`constexpr` Implies `inline` in C++17**

A key improvement in **C++17** is that **`constexpr` static members are implicitly `inline`**, meaning they **no longer require** a separate definition in a `.cpp` file.

Thus, we can define static members in different ways and pick the first matching option:

1. `static constexpr Type a;`
2. `static inline const Type a;`
3. `static inline Type a;`

For more details, see the **[cppreference article on static data members](https://en.cppreference.com/w/cpp/language/static#Static_data_members){:target="_blank"}**.

---

## **Conclusion**

The evolution of **static data members** from **C++03** to **C++17** has significantly improved usability, reducing boilerplate and eliminating many previously required `.cpp` file definitions. Thanks to **C++17's inline static variables**, defining and using static members has never been easier.

This article was refined with the help of **ChatGPT**, ensuring accuracy, readability, and best practices in modern C++. 🚀

{% include mathjax.html %}
