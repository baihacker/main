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

Test for integral types.
```cpp
// header file
using IntegralType = int;
constexpr int initial_integral_value = 1;
constexpr int different_integral_value = 2;
class A {
public:
  static const IntegralType a = initial_integral_value;
  static const IntegralType b;

  static constexpr IntegralType c = different_integral_value;
  // static constexpr IntegralType d; // ❌ Error: uninitialized

  // static IntegralType e = initial_integral_value; // ❌ Error:
  static IntegralType f;
};

// cpp file

// const IntegralType A::a = initial_integral_value; // ❌ Error: duplicate initialization
// const IntegralType A::a = different_integral_value; // ❌ Error: duplicate initialization
const IntegralType A::a;  // ✅ Reauired if ODR-used

const IntegralType A::b = different_integral_value; // ✅ Required if used
// const IntegralType A::b;  // ❌ Error: uninitialized

// constexpr IntegralType A::c = initial_integral_value; // ❌ Error: duplicate initialization
// constexpr IntegralType A::c = different_integral_value; // ❌ Error: duplicate initialization
constexpr IntegralType A::c;  // ✅ Reauired if ODR-used

IntegralType A::f = 1;      // ✅ Required if used
IntegralType A::f;          // ✅ Required if used
```

Test for class types.
```cpp
// header file
class Value {
  public:
   constexpr Value(int v = 0) : v(v) {}
   int v;
 };

 using ClassType = Value;
 constexpr Value initial_class_value(1);
 constexpr Value different_class_value(2);

 class B {
  public:
   // static const ClassType a = initial_class_value; // ❌ Error
   static const ClassType b;

   static constexpr ClassType c = initial_class_value;
   // static constexpr ClassType d; // ❌ Error: must have an initializer

   // static ClassType e = initial_class_value; // ❌ Error
   static ClassType f;
 };

 // cpp file

 const ClassType B::b = different_class_value; // ✅ Required if used
 const ClassType B::b; // ✅ Required if used

 // constexpr ClassType B::c = initial_class_value; // ❌ Error: duplicate initialization
 // constexpr ClassType B::c = different_class_value; // ❌ Error: duplicate initialization
 constexpr ClassType B::c; // ✅ Required when ODR-used

 ClassType B::f = different_class_value; // ✅ Required if used
 ClassType B::f; // ✅ Required if used

```

---

## **Enhancements in C++17: Inline Static Variables**

C++17 introduced **inline static variables**, which greatly simplify static data member handling:

- **No longer need to worry about ODR-use**.

Test for integral types.
```cpp
// header file
using IntegralType = int;
constexpr int initial_integral_value = 1;
constexpr int different_integral_value = 2;
class A {
public:
  inline static const IntegralType a = initial_integral_value;
  // inline static const IntegralType b; // ❌ Error: uninitialized

  inline static constexpr IntegralType c = initial_integral_value;
  // inline static constexpr IntegralType d; // ❌ Error: must have an initializer

  inline static IntegralType e = initial_integral_value;
  inline static IntegralType f;
};

// cpp file

// const IntegralType A::a = initial_integral_value; // ❌ Error: duplicate initialization, redefinition
// const IntegralType A::a = different_integral_value; // ❌ Error: duplicate initialization, redefinition
// const IntegralType A::a; // ❌ Error: redefinition

// constexpr IntegralType A::c = initial_integral_value; // ❌ Error: duplicate initialization
// constexpr IntegralType A::c = different_integral_value; // ❌ Error: duplicate initialization
constexpr IntegralType A::c; // ✅ Allowed but redundant

// IntegralType A::e = initial_integral_value; // ❌ Error: duplicate initialization, redefinition
// IntegralType A::e = different_integral_value; // ❌ Error: duplicate initialization, redefinition
// IntegralType A::e; // ❌ Error: redefinition

// IntegralType A::f = 1; // ❌ Error: redefinition
// IntegralType A::f; // ❌ Error: redefinition

```

Test for class types.
```cpp
// header file
class Value {
  public:
   constexpr Value(int v = 0) : v(v) {}
   int v;
 };
 using ClassType = Value;
 constexpr Value initial_class_value(1);
 constexpr Value different_class_value(2);

 class B {
  public:
   inline static const ClassType a = initial_class_value;
   inline static const ClassType b;

   inline static constexpr ClassType c = initial_class_value;
   // inline static constexpr ClassType d; // ❌ Error: must have an initializer

   inline static ClassType e = initial_class_value;
   inline static ClassType f;
 };

 // cpp file

 // const ClassType B::a = initial_class_value; // ❌ Error: duplicate initialization, redefinition
 // const ClassType B::a = different_class_value; // ❌ Error: duplicate initialization, redefinition
 // const ClassType B::a; // ❌ Error: redefinition

 // const ClassType B::b = different_class_value; // ❌ Error: redefinition
 // const ClassType B::b; // ❌ Error: redefinition

 // constexpr ClassType B::c = initial_class_value; // ❌ Error: duplicate initialization
 // constexpr ClassType B::c = different_class_value; // ❌ Error: duplicate initialization
 constexpr ClassType B::c; // ✅ Allowed but redundant

 // ClassType B::e = initial_class_value; // ❌ Error: duplicate initialization, redefinition
 // ClassType B::e = different_class_value; // ❌ Error: duplicate initialization, redefinition
 // ClassType B::e; // ❌ Error: redefinition

 // ClassType B::f = different_class_value; // ❌ Error: redefinition
 // ClassType B::f; // ❌ Error: redefinition

```

Not that in **C++17** is that **`constexpr` static members are implicitly `inline`**.

We can choose the first matching option to define static data member since **C++17**:

1. `static constexpr Type a = initial_value;`
2. `static inline const Type a = initial_value;`
3. `static inline const Type a;`
4. `static inline Type a = intialize_value;`
5. `static inline Type a;`

---

## **Conclusion**

The evolution of **static data members** from **C++03** to **C++17** has significantly improved usability, reducing boilerplate and eliminating many previously required `.cpp` file definitions. Thanks to **C++17's inline static variables**, defining and using static members has never been easier.

This article was refined with the help of **ChatGPT**, ensuring accuracy, readability, and best practices in modern C++. 🚀

{% include mathjax.html %}
