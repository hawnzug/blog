---
title: 翻译：暴力 Agda 入门教程
---
> 本文翻译自 [Brutal [Meta]Introduction to Dependent Types in Agda](http://oxij.org/note/BrutalDepTypes/)  
> 本作品采用[知识共享署名 4.0 国际许可协议]("http://creativecommons.org/licenses/by/4.0/")进行许可。

## 引言

Agda 并不缺乏入门教程，你可以在 Agda Wiki
上找到一整页的教程 [1]（更全面的文档参见 [2]）。我个人比较推荐：

- Anton Setzer 的介绍 (对有逻辑学背景的人来说效果非常好，普通的读者也能比较容易地跟上) [3]
- Ana Bove 和 Peter Dybjer 的介绍 [4].
- Ulf Norell 的面向函数式程序员的介绍 [5].
- Thorsten Altenkirch 的讲稿 [6].

(这个列表不是按特定顺序排列的，最好同时阅读它们（包括本文）。此外，本文尚未完成，但是已经足够实用。）

同样的说法对 Coq [7]， Idris [8] 也成立，甚至还包括 Epigram [9]。

更详细的对类型理论的介绍可以看：

- Morten Heine B. Sørensen 和 Pawel Urzyczyn 的讲稿 [10]。
- Simon Thompson 的书 [11]。

还有一些和上述语言密切相关的理论书籍：

- Per Martin-Löf (Agda， Coq， Idris 和 Epigram 使用的核心类型理论的创始人) 的讲稿 [12]， [13]。
- Bengt Nordström et al 的更实用向的书 [14]。

以及一些教你如何实现一门依赖类型的语言的教程：

- 「Simpler Easier」[15]。
- Andrej Bauer 的教程 [16]-[18]。

既然已经有了这么多的教程，为什么我还要再写一份呢？因为在教程与背后理论之间有这么一个缺口。
理论非常复杂并且充满了细节，这些细节在语言教程和玩具实现中往往被忽略（以免吓退初学者）。
这一点也不令人感到惊讶，因为现在的成果用了很多年才正确地实现，即便如此，仍然存在不少的问题。

然而，我认为，正是这些困难的地方才是重要的，我也一直想要看到一份教程，一份至少提及了这些问题的教程。
（显然有一些依赖类型的问题被人们所重视，比如，不可判断的类型推导，但是仍然有很多问题没有被很好地理解）。
此外，在我对这些关于依赖类型编程的问题感到困惑之后，我开始觉得，将这些问题隐藏在语言好的一面的后面，
实际上让人更加难以理解。Agda 中的「Dotted patterns」和「unification stuck」错误就是很好的例子。我认为：

- 人们觉得「Dotted patterns」难以理解正是因为我们很难从语言表层来解释它们。
- 显式地接触归一化引擎对于交互式程序的构建非常有帮助。通过手工归一化表达式，我完成了许多之前看来不能完成
的证明。据我所知，目前为止没有一个证明检查器能够有效地自动化这个过程。
这是我对`agda2-mode`的一份[提案](https://github.com/agda/agda/issues/771)和一些关于如何实现的想法。

说了这么多，本文主要有以下几个目的：

- 本文是一篇 Agda 的教程，从最基本的知识开始，面向有基本的离散数学，数论，集合论和 Haskell 基础的读者群体。
事实上我向本科生教授这些内容并取得了一定的效果。
- 但是本文的目的并不是教你学会 Agda，而是向你展现依赖类型语言究竟是如何工作的，
而不用深入地去研究背后的理论（因为正如上文所说，研究理论可能需要几年的时间）。当然我们也可以为
Coq，Idris，Epigram 或者其他什么语言写一份相似的教程，但是由于 Agda
的语法和它经常被使用的归一化，使得我选择 Agda 来撰写这份教程。
- 文中也会有一些【*中括号里的斜体内容*】，通常是写给那些有类型理论背景的读者。不要恐慌，你可以完全忽略它们。
不过如果你研究一下这些内容，它们会给你更深刻的洞见和启发。
- 最后的两个部分完全是类型理论的内容。这是我开始写这篇文章的原因，但是你仍然可以完全无视它们。
- 你需要理解其余的所有部分。完成练习，当你被难住的时候，去看看其他的教程。

最后，在我们开始之前，我需要声明一下：通过阅读（部分的）Agda
源代码，我检验了我关于这些东西是如何工作的核心的想法，但是，正如古人所说：我知道我一无所知。

## 缓慢启动

#### 相信我，你会想要使用 Emacs 的

Emacs 有一个 *agda2-mode*，它可以让你：

- 输入有趣的 UNICODE 字符，比如ℕ或者Σ，
- 和 Agda 进行交互（具体见下）。

安装：

- 安装 `emacs`，
- 通过你的包管理器或者 cabal 安装和 Agda 有关的一切，
- 执行 `agda-mode setup`。

运行：

- 运行 `emacs`，
- `C-x C-f FileName RET`（Control+x，Control+f，输入文件名，按下回车）。

你可以在 Emacs 中直接载入[这篇文章的 Agda 文字版](http://oxij.org/note/BrutalDepTypes.lagda)，
这实际上我比较推荐的阅读本文的方式，毕竟你不能在 HTML 版里做练习。

## 语法

在 Agda 中，模块的声明永远放在最前面：
``` Agda
module BrutalDepTypes where
```
Agda也支持嵌套的模块和带参数的模块。嵌套模块的一个常见的用途就是将一些定义从顶层的名字空间中隐藏起来：
``` Agda
module ThrowAwayIntroduction where
```
数据类型以 GADT 的风格写出：
``` Agda
  data Bool : Set where
    true false : Bool
    -- 注意到我们可以在一行里写下
    -- 多个构造子，用空格分隔

  -- 输入 \bn 来输入ℕ ，
  -- 输入 \to 来输入→，但是->也可以
  -- 自然数.
  data ℕ : Set where
    zero : ℕ
    succ : ℕ → ℕ

  -- Identity container
  data Id (A : Set) : Set where
    pack : A → Id A

  -- 输入 \bot 来输入⊥
  -- 空类型。无意义。假命题。
  data ⊥ : Set where
```
这里的 `Set` 和 Haskell 里的 `*` 是一个东西，也就是类型的类型（具体见下）。

Agda 是一个 total 的语言。它没有 Haskell 里的
`undefined`，所有的函数都保证对所有可能的输入会终止（除非显式地被声明），
这就意味着`⊥`类型真的是空的。

函数的声明和 Haskell 非常像：
``` Agda
  -- 输入 \_0 来输入₀，输入 \_1 来输入₁，以此类推
  idℕ₀ : ℕ → ℕ
  idℕ₀ x = x
```
除了函数的参数即使在函数的类型中也有名字：
``` Agda
  -- 注意，类型中参数的名字和在模式匹配中使用的参数名可能不相同
  idℕ₁ : (n : ℕ) → ℕ
  idℕ₁ x = x -- 这个 `x` 和类型中的 `n` 指的是同一个参数
```
实际上`idℕ₀`的定义是下面这段定义的语法糖：
``` Agda
  idℕ₂ : (_ : ℕ) → ℕ
  idℕ₂ x = x
```
这里的下划线表示「我不在意这个参数的名字」，就像 Haskell 里一样。

依赖类型使得在一个箭头后面的类型表达式能够依赖箭头前的类型表达式，
这可以被用来构造多态函数：
``` Agda
  id₀ : (A : Set) → A → A
  id₀ _ a = a
```
现在类型里面的 A 不能被下划线替代，但是在模式匹配中我们可以忽略这个名字。

模式匹配看起来和一般的没什么区别：
``` Agda
  not : Bool → Bool
  not true  = false
  not false = true
```
除非你写错了构造子的名字：
``` Agda
  not₀ : Bool → Bool
  not₀ true  = false
  not₀ fals  = true
```
Agda 什么都不会提示。有时候这可能非常危险。
``` Agda
  data Three : Set where
    COne CTwo CThree : Three

  three2ℕ : Three → ℕ
  three2ℕ COne = zero
  three2ℕ Ctwo = succ zero
  three2ℕ _    = succ (succ zero) -- 和之前的模式匹配重复
```
最后，Agda 支持隐式参数：
``` Agda
  id : {A : Set} → A → A
  id a = a

  idTest₀ : ℕ → ℕ
  idTest₀ = id
```
隐式参数的值通过解类型等式（具体见下）从其他参数的值和类型推导而来。
你不必显式地应用它们或者对它们进行模式匹配，但是如果你想要的话，
你仍然可以这样做：
``` Agda
  -- 位置的:
  id₁ : {A : Set} → A → A
  id₁ {A} a = a

  idTest₁ : ℕ → ℕ
  idTest₁ = id {ℕ}

  -- 命名的:
  const₀ : {A : Set} {B : Set} → A → B → A
  const₀ {B = _} a _ = a

  constTest₀ : ℕ → ℕ → ℕ
  constTest₀ = const₀ {A = ℕ} {B = ℕ}
```
*【注意这里没有进行任何的证明搜索。隐式参数和程序的计算完全是正交的概念，隐式参数
并不意味着任何事情。隐式参数并不会被特殊对待，也没有类型擦除。它们只不过是一种在解方程
帮助下的语法糖】*

小括号或大括号之间的箭头可以被省略：
``` Agda
  id₃ : {A : Set} (a : A) → A
  id₃ a = a
```
相同类型的参数名可以放在同一个括号里：
``` Agda
  const : {A B : Set} → A → B → A
  const a _ = a
```
下划线的用法让 Agda 的语法容易让人感到困惑。在 Haskell 中下划线仅仅表示「我不在意这个参数的名字」，
在 Agda 中下划线还有两个半定义。第一种是「你自己推测这个值」：
``` Agda
  idTest₃ : ℕ → ℕ
  idTest₃ = id₀ _
```
它的工作原理和隐式参数是一样的。

或者更准确地说，它就是隐式地应用参数，只不过 Agda 只在函数定义的时候执行一次，而不是每次调用的时候执行一次。

另一半叫做「你自己推测这个类型」
``` Agda
  unpack₀ : {A : _} → Id A → A
  unpack₀ (pack a) = a
```
它有专门的`∀`语法糖：
``` Agda
  -- 输入 \forall 来输入∀
  unpack : ∀ {A} → Id A → A
  unpack (pack a) = a

  -- 显式参数版本:
  unpack₁ : ∀ A → Id A → A
  unpack₁ _ (pack a) = a
```
`∀`的作用域一直到第一个箭头：
``` Agda
  unpack₂ : ∀ {A B} → Id A → Id B → A
  unpack₂ (pack a) _ = a

  unpack₃ : ∀ {A} (_ : Id A) {B} → Id B → A
  unpack₃ (pack a) _ = a
```
在数据类型的语法中，如果没有类型的声明，则默认`∀`：
``` Agda
  data ForAllId A (B : Id A) : Set where
```
注意，Agda 的`∀`和 Haskell 的`∀`（`forall`）完全不一样。在 Agda 中当我们说`∀ n`的时候，我们很有可能推断出
`n : ℕ`，但是在 Haskell 中`∀ n`永远表示`{n : Set}`。*【也就是说，Haskell 中的`∀`是一种隐式（Hindley-Milner）
版本的二阶全称量词，而在 Agda 中这只是个语法糖】*

语法的错误解释会造成很大的问题，特别是当你处理一个以上的 universe level（具体见下）的时候。
因此训练你下意识地解语法糖（首先有意识地训练）就非常重要。这会省下你大量的时间。比如，
`∀ {A} → Id A → A` 表示 `{A : _} → (_ : Id A) → A`（最后的 `→ A` 应该被解释成 `→ (_ : A)`），
也就是说，第一个 `A` 是一个变量名，而其余的则是类型。

下划线的最后一种用途，就是它可以作为中缀函数的参数位置标识符，也就是说，函数名中的下划线标识着参数的位置：
``` Agda
  if_then_else_ : {A : Set} → Bool → A → A → A
  if true then a else _ = a
  if false then _ else b = b

  -- 两个自然数相等吗？
  _=ℕ?_ : ℕ → ℕ → Bool
  zero   =ℕ? zero   = true
  zero   =ℕ? succ m = false
  succ m =ℕ? zero   = false
  succ n =ℕ? succ m = n =ℕ? m

  -- 自然数加法
  infix 6 _+_
  _+_ : ℕ → ℕ → ℕ
  zero   + n = n
  succ n + m = succ (n + m)

  ifthenelseTest₀ : ℕ
  ifthenelseTest₀ = if (zero + succ zero) =ℕ? zero
    then zero
    else succ (succ zero)

  -- Lists
  data List (A : Set) : Set where
    []  : List A
    _∷_ : A → List A → List A

  [_] : {A : Set} → A → List A
  [ a ] = a ∷ []

  listTest₁ : List ℕ
  listTest₁ = []

  listTest₂ : List ℕ
  listTest₂ = zero ∷ (zero ∷ (succ zero ∷ []))
```
注意 `infix` 的声明和 Haskell 中具有相同的意义。由于某种原因我们不写 `infixl`。
在声明了结合性之后，Agda 就不会打印多余的括号。这一般来说比较好，但是有时候会使得一些解释变得复杂。

和 Haskell 一样，我们有 `where` 语法：
``` Agda
  ifthenelseTest₁ : ℕ
  ifthenelseTest₁ = if (zero + succ zero) =ℕ? zero
    then zero
    else x
    where
    x = succ (succ zero)
```
在模式匹配的时候，有一种特殊的情况：我们想要模式匹配的类型显然是空的
（*【type inhabitance 问题在通常情况下是不可判定的】*）。这种特殊情况叫做「absurd pattern」：
``` Agda
  -- ⊥ 可以推导出一切。
  ⊥-elim : {A : Set} → ⊥ → A
  ⊥-elim ()
```
这让我们可以跳过定义的右半部分。

你仍然可以绑定变量：
``` Agda
  -- ⊥ 可以推导出一切。
  ⊥-elim₀ : {A : Set} → ⊥ → A
  ⊥-elim₀ x = ⊥-elim x
```
Agda 也有 records，它和 Haskell 中的 `newtype` 非常像，也就是说，
它们是只有单个不被保存的构造子的数据类型。
``` Agda
  record Pair (A B : Set) : Set where
    field
      first  : A
      second : B

  getFirst : ∀ {A B} → Pair A B → A
  getFirst = Pair.first
```
注意，为了避免名字冲突，records 生成了一个具有 field extrators 的新模块。

按照传统，我们将只有一个元素的类型定义为没有 fields 的 record。
``` Agda
  -- 输入 \top 来输入⊤
  -- 单个元素的类型。没有 fields 的 record。真命题。
  record ⊤ : Set where

  tt : ⊤
  tt = record {}
```
关于这个传统还有一个特殊的注意点，当隐式地被应用或者用下划线的时候，一个空 record 类型的参数会自动得到 `record {}` 的值。

最后，Agda 用了极其简化的词法分析器，它用空格，小括号，大括号来分割 token。
比如（注意变量名）：
``` Agda
  -- 输入 \` 来输入‵
  -- 输入 \' 来输入′
  ⊥-elim‵′ : {A : Set} → ⊥ → A
  ⊥-elim‵′ ∀x:⊥→-- = ⊥-elim ∀x:⊥→--
```
这是完全可以的。注意到这里的 `--` 不会生成注释。

## 依赖类型的魔法

让我们来定义除以二：
``` Agda
  div2 : ℕ → ℕ
  div2 zero = zero
  div2 (succ (succ n)) = succ (div2 n)
```
这种定义的问题在于 Agda 是 total 的。我们必须给奇数拓展函数定义。
``` Agda
  div2 (succ zero) = {!check me!}
```
想要把 `{!check me!}` 改成某一 term，最常见的选择就是 `zero`。

现在假设，我们知道 `div2` 的输入永远是偶数，所以我们不想为奇数拓展函数定义。
我们如何限制 `div2` 的输入只能为偶数呢？通过谓词！下面是 `even` 谓词：
``` Agda
  even : ℕ → Set
  even zero = ⊤
  even (succ zero) = ⊥
  even (succ (succ n)) = even n
```
当参数是偶数的时候，`even` 返回 `⊤`。当参数是奇数的时候，`even` 返回 `⊥`。

现在 `div2e` 的定义仅限于偶数：
``` Agda
  div2e : (n : ℕ) → even n → ℕ -- 这里对第一个参数我们必须起一个名字 `n`
  div2e zero p = zero
  div2e (succ zero) ()
  div2e (succ (succ y)) p = succ (div2e y p)
  -- 根据 `even` 的定义，`even (succ (succ n))` 的证明
  -- 可以转变为 `even n` 的证明。
```
在用依赖类型编程的时候，关于 `A` 的谓词，是一个类型为从 `A` 到类型的函数，
也就是，`A → Set`。如果 `a : A` 满足谓词 `P : A → Set`，那么函数 `P`
返回一个类型，这个类型的每一个元素都是 `P a` 的一个证明。

## Type families 和 Unification

还有另外一种定义「even」的方式。这次我们使用被ℕ索引的数据类型：
``` Agda
  data Even : ℕ → Set where
    ezero  : Even zero
    e2succ : {n : ℕ} → Even n → Even (succ (succ n))

  twoIsEven : Even (succ (succ zero))
  twoIsEven = e2succ ezero
```
`Even : ℕ → Set`是被ℕ索引的一组类型，并且遵循如下规则：

- `Even zero` 有一个元素 `ezero`。
- 对于任意给定的 `n`，类型 `Even (succ (succ n))` 有一个元素如果 `Even n` 非空。
- 没有其他的元素。

将这种定义和 `even : ℕ → Set` 进行对比：

- 对于 `zero` 具有性质 `even`，存在一个平凡的证明。
- 对于 `succ zero` 具有性质 `even`，不存在证明。
- 如果 `n` 具有性质 `even`，那么 `succ (succ n)` 也具有性质 `even`。

换句话说，它们之间的主要区别在于，`Even : ℕ → Set` 构造一个类型，
而 `even : ℕ → Set` 返回一个类型，在被应用了一个属于 `ℕ` 的元素后。

二是偶数的证明 `even (succ (succ zero))`
字面上来看就是「二是偶数因为存在一个平凡的证明」，而另一种证明
`twoIsEven` 则是说「二是偶数因为零是偶数并且二是零的后继的后继」。

数据类型 `Even` 让我们可以定义另一种非拓展版本的自然数除以二函数：
``` Agda
  div2E : (n : ℕ) → Even n → ℕ
  div2E zero ezero = zero
  div2E (succ zero) ()
  div2E (succ (succ n)) (e2succ stilleven) = succ (div2E n stilleven) -- 将这种情况和 div2e 进行比较。
```
注意这里不会出现 `div2E zero (e2succ x)` 这种情况，因为 `e2succ x`
具有错误的类型，`Even zero` 类型不存在这样的构造子。对于 `succ zero` 的情况，
第二个参数的类型不是 `⊥`，而是空。我们是怎么知道的呢？Unification！

Unification 是依赖类型编程中最重要（算上对归纳类型的模式匹配）而且很容易被遗忘的部分。
给定两项 `M` 和 `N`，unification 试图找到一个替换项 `s`，使得在 `M` 中使用 `s`
和在 `N` 中使用 `s` 有着相同的结果。详细的算法非常长，但是背后的想法很简单：
想要判断两个表达式能否被 unified，我们

- 尽可能地化简它们，
- 然后遍历它们的 spine 直到
    - 发现两者明显的区别，
    - 找到一个我们不能确定的地方，
    - 或者成功地完成遍历，生成一个替换项 `s`。

举个例子：

- 为了 unify `(succ a) + b` 和 `succ (c + d)`，我们需要化简它们，
接下来我们需要 unify `succ (a + b)` 和 `succ (c + d)`，也就是说我们要 unify
`a + b` 和 `c + d`，这意味着我们要 unify `a` 和 `c`，还有 `b` 和 `d`，
也就是说 `a = c`，`b = d`。
- 另一方面，对于任意的 `a`，`succ a` 都不能和 `zero` unify，
`succ b` 不能和任意的 `b` unify。
- 我们不知道 `foo n` 和 `zero` 能不能 unify，如果 `foo`
是一个未知的函数的话（对于某些 `n` 它可能被化简到 `zero`）。

在上面的代码中，`succ zero`不能和任何的 `Even` 的构造子的索引[`zero`，`succ
(succ n)`] unify，根据定义，它的类型显然为空。

*【想要对 type family 的模式匹配有更多的了解，请参考 McBride 和 McKinna 的论文「The view from the left」[20]】*

## Type family 的更多介绍

在数据类型的声明中，`:` 前面的部分被叫做「参数」，在冒号后面但是在 `Set`
前面的部分被叫做「索引」。

下面是一个著名的同时包括这两者的数据类型：
``` Agda
  data Vec (A : Set) : ℕ → Set where
    []  : Vec A zero
    _∷_ : ∀ {n} → A → Vec A n → Vec A (succ n)
```
`Vec A n` 是一个长度为 `n`，元素类型为 `A` 的向量，`Vec` 拥有一个类型为 `Set`
的参数，并且被类型 `ℕ` 的值索引。将上面的定义和 `List` 和 `Even`
的定义进行比较。另外我们注意到，Agda 允许不同的数据类型的构造子具有相同的名字
（关于这一问题是如何被解决的，详见下文）。

在定义取「`List` 的第一个元素」这样一个函数的时候，我们不可避免地要对 `[]` 进行模式匹配：
``` Agda
  head₀ : ∀ {A} → List A → A
  head₀ []       = {!check me!}
  head₀ (a ∷ as) = a
```
但是在 `{!check me!}` 里面我们写不了任何东西（如果我们想要 total 的话）。

但另一方面，类型 `Vec A (succ n)` 没有 `[]` 这样的构造子：
``` Agda
  head : ∀ {A n} → Vec A (succ n) → A
  head (a ∷ as) = a
```
注意到这里没有任何无意义的情况，`Vec A (succ n)` 已经 inhabited 了，这里没有 `[]` 这种情况。

顺便提一下，`Vec` 类型也以串联函数著称：
``` Agda
  -- `List` 的串联
  _++_ : ∀ {A} → List A → List A → List A
  []       ++ bs = bs
  (a ∷ as) ++ bs = a ∷ (as ++ bs)

  -- `Vec` 的串联
  -- 串联后的长度是两个参数长度之和，两者的长度都可以从类型中得到。
  _++v_ : ∀ {A n m} → Vec A n → Vec A m → Vec A (n + m)
  []       ++v bs = bs
  (a ∷ as) ++v bs = a ∷ (as ++v bs)
```
比较一下 `_+_`，`_++_` 和 `_++v_` 的定义。

为什么 `_++v_` 的定义能够起效呢？因为我们也用同样的方式定义了 `_+_`！
在 `_++v_` 的第一种情况中，通过 unification 我们可以从类型 `[]` 得到 `n = zero`，
根据 `_+_` 的定义我们可以得到 `zero + m = m`，`bs : Vec A
m`。相似地，在第二种情况中，
`n = succ n0`，
`as : Vec A n0`，
`(succ n0) + m = succ (n0 + m)`，
`a ∷ (as ++ bs) : succ (n0 + m)`。

## Dotted Patterns 和 Unification

让我们来定义减法：
``` Agda
  infix 6 _-_
  _-_ : ℕ → ℕ → ℕ
  zero   - _      = zero
  succ n - zero   = succ n
  succ n - succ m = n - m
```
注意到对 `m > n` 的情况，`n - m = zero`。

让我们用 `_≤_` 关系来避免这种情况：
``` Agda
  data _≤_ : ℕ → ℕ → Set where
    z≤n : ∀ {n}           → zero ≤ n
    s≤s : ∀ {n m} → n ≤ m → succ n ≤ succ m
```
现在我们可以写出没有 `m > n` 这种情况的减法：
``` Agda
  sub₀ : (n m : ℕ) → m ≤ n → ℕ
  sub₀ n zero (z≤n .{n}) = n
  sub₀ .(succ n) .(succ m) (s≤s {m} {n} y) = sub₀ n m y
```
注意到这些点，它们被叫做「Dotted Pattern」。我们暂时先忽略它们。

考虑 `sub₀ n zero (z≤n {k})` 的情况。第三个参数的类型是 `zero ≤ n`。
`z≤n {k}` 的类型是 `zero ≤ k`。通过这两个类型的 unification 我们得到
[`k = n`，`m = zero`]。在替换之后我们得到 `sub₀ n zero (z≤n {n})`。
我们想要匹配哪一个 `n` 呢？在上面的代码中我们告诉 Agda「匹配第一个」，
所以我们在第二个 `n` 之前写一个点来标识这个信息。Dotted Pattern 告诉编译器，
不要对它进行匹配，这是唯一可能的值。

第二种情况是 `sub₀ n m (s≤s {n'} {m'} y)`。第三个参数的类型是 `m ≤ n`。
`s≤s {n'} {m'} y` 的类型是 `succ n' ≤ succ m'`。这说明
[`n = succ n'`，`m = succ m'`]。这次我们决定对 `n'` 和 `m'` 进行匹配。

如果用 Haskell 里的 `case` 来重写的话（Agda 没有 `case`，详见下文），
那么上面的代码就会变成这样（伪 Haskell 代码）：
``` Haskell
  sub₀ n m even = case even of
    z≤n {k}     -> case m of -- [`k = n`, `m = zero`]
      zero    -> n
      succ m' -> __IMPOSSIBLE__  -- 因为 `m = zero` 和 `m = succ m'` 不能 unify
    s≤s n' m' y -> sub₀ n' m' y  -- [`n = succ n'`, `m = succ n'`]
```
这里的 `__IMPOSSIBLE__` 就和 `undefined` 差不多，但是永远不会被执行。

对于 even 的第一种情况，我们有[`k = n`，`m = zero`]。这意味着我们可以在第一个 `zero`
之前加上点，来优化对 `m` 的匹配：
``` Agda
  sub₁ : (n m : ℕ) → m ≤ n → ℕ
  sub₁ n .zero (z≤n .{n}) = n
  sub₁ .(succ n) .(succ m) (s≤s {m} {n} y) = sub₁ n m y
```
这会被翻译成：
``` Haskell
sub₁ n m even = case even of
  z≤n {k}     -> n
  s≤s n' m' y -> sub₁ n' m' y
```
最后，我们可以先匹配 `sub` 的前两个参数（通常的定义）：
``` Agda
  sub : (n m : ℕ) → m ≤ n → ℕ
  sub n zero (z≤n .{n}) = n
  sub (succ n) (succ m) (s≤s .{m} .{n} y) = sub n m y
```
这会被翻译成：
``` Haskell
  sub n m even = case m of
    zero   -> case even of
        z≤n {k}       -> n
        s≤s {k} {l} y -> __IMPOSSIBLE__ -- 因为 `zero` (`m`) 和 `succ k`
                                        -- 不能 unify
    succ m' -> case n of
      zero   -> case even of
        z≤n {k}       -> __IMPOSSIBLE__ -- 因为 `succ m'` (`m`) 和 `zero`
                                        -- 不能 unify
        s≤s {k} {l} y -> __IMPOSSIBLE__ -- 因为 `zero` (`n`) 和 `succ l`
                                        -- 不能 unify
      succ n' -> case even of
        z≤n {k}       -> __IMPOSSIBLE__ -- 因为 `succ n'` (`n`) 和 `zero`
                                        -- 不能 unify
        s≤s {k} {l} y -> sub n' m' y
```
**练习**。写出上面伪 Haskell 翻译的 unification 限制条件。

注意 `sub n m p` 计算 `m` 和 `n` 的差，而 `sub₀` 和 `sub₁` 从证明 `p`
中得到结果。同样也注意到，对于 `sub n zero`，第三参数永远是 `z≤n {n}`，
因此我们可能会想要这样写：
``` Agda
  sub₂ : (n m : ℕ) → m ≤ n → ℕ
  sub₂ n zero .(z≤n {n}) = n
  sub₂ (succ n) (succ m) (s≤s .{m} .{n} y) = sub₂ n m y
```
但是 Agda 不允许这样写，原因见下。

但是我们仍然可以这样写：
``` Agda
  sub₃ : (n m : ℕ) → m ≤ n → ℕ
  sub₃ n zero _ = n
  sub₃ (succ n) (succ m) (s≤s .{m} .{n} y) = sub₃ n m y
```
**练习**。写出下面伪 Haskell 翻译的 unification 限制条件。
``` Agda
  sub₄ : (n m : ℕ) → m ≤ n → ℕ
  sub₄ n zero (z≤n .{n}) = n
  sub₄ (succ .n) (succ .m) (s≤s {m} {n} y) = sub₄ n m y
```
**Dotted Pattern 实际上就是内联的 unification 限制**。
这就是为什么在 `sub₂` 的第一种情况中我们不能给 `z≤n {n}` 加点，
Agda 不能够生成这样一种限制（实际上是可以的，如果它努力尝试一下的话）。

## Propositional equality 和 Unification

我们现在要定义最有用的type family，那就是， Martin-Löf
的相等（尽管是只有值的版本）：
``` Agda
  -- ≡ 是 \==
  infix 4 _≡_
  data _≡_ {A : Set} (x : A) : A → Set where
    refl : x ≡ x
```

对于 `x y : A`，如果 `x` 和 `y` 能互相转换的话，类型 `x ≡ y` 仅有一个构造子 `refl`，
也就是说，存在 `z` 使得 `z →β✴ x` 和 `z →β✴ y`，`→β✴`表示「零次或任意多次β规约」[15]。
根据 Church-Rosser 定理和 strong normalization 定理，能否相互转换可以由
normalization 解决。这就意味着 unification
会检查能否相互转换并且填入一些没有写出的项。换句话说，如果 `x` 和 `y` 能 unify ，
那么 `x y : A` 的类型 `x ≡ y` 仅具有一个构造子 `refl`，

让我们来证明 `_≡_` 的一些性质：
``` Agda
  -- _≡_ 具有对称性
  sym : {A : Set} {a b : A} → a ≡ b → b ≡ a
  sym refl = refl

  -- 传递性
  trans : {A : Set}{a b c : A} → a ≡ b → b ≡ c → a ≡ c
  trans refl refl = refl

  -- 和一致性
  cong : {A B : Set} {a b : A} → (f : A → B) → a ≡ b → f a ≡ f b
  cong f refl = refl
```
考虑 `sym {A} {a} {b} (refl {x = a})` 的情况。对 `refl` 进行模式匹配可以得出
[`b = a`]，也就是说，这种情况实际上就是 `sym {A} {a} .{a} (refl {x = a})`。
这就允许我们在右边写 `refl`。其余的证明都是类似的。

注意我们可以用另一种方式证明 `sym`：
``` Agda
  sym′ : {A : Set}{a b : A} → a ≡ b → b ≡ a
  sym′ {A} .{b} {b} refl = refl
```
`sym` 把 `a` 放进 `refl`，而 `sym′` 放了 `b`。
「这两种定义是否等价」是一个有趣的哲学问题。（从 Agda 的角度来看它们是等价的。）

因为 dotted pattern 实际上是 unification 限制，如果你不匹配隐式参数的话，你不必给隐式参数加点。

`_≡_` type family 被称作 「propositional equality」。
在 Agda 的标准库中它有一个更通用的定义，具体见下。

## 交互式证明
在 `_≡_` 的帮助下我们终于可以证明一些基本的数论的结论。让我们用交互式的方式来证明。

我们的第一个目标是 `_+_` 的结合律。
``` Agda
  +-assoc₀ : ∀ a b c → (a + b) + c ≡ a + (b + c)
  +-assoc₀ a b c = {!!}
```
注意 `{!!}` 这个标记。所有 `{!expr!}`（expr
是任意的字符串，可以为空）这种形式的项，在 agda2-mode 被载入后都会变成一个目标。
输入 `{!!}` 非常麻烦，所以有一种方便的缩写 `?`。所有的 `?`
在源码文件被载入后都会被自动转变成 `{!!}`。

在编辑区中目标的颜色是绿色的，当光标在目标里的时候，按下特定的键之后就会向 Agda
提问，然后对代码执行某些操作。在这篇文档中，目标中的「check
me」意味着这个目标不用被填写，这只是个样例。

按下 `C-c C-l` 来载入代码并进行类型检查。

把光标放在目标中（文本中绿色的那一块）然后按下 `C-c C-c a RET`（对 `a`
进行模式匹配），代码就会变成（下面请忽略函数名的变化和所有的「check me」）：
``` Agda
  +-assoc₁ : ∀ a b c → (a + b) + c ≡ a + (b + c)
  +-assoc₁ zero b c = {!check me!}
  +-assoc₁ (succ a) b c = {!check me!}
```
在目标中按下 `C-c C-,`（目标的类型和上下文）。这会显示目标的类型和上下文。

在目标中写下 `refl` 然后按下 `C-c C-r`（refine），这会产生：
``` Agda
  +-assoc₂ : ∀ a b c → (a + b) + c ≡ a + (b + c)
  +-assoc₂ zero b c = refl
  +-assoc₂ (succ a) b c = {!check me!}
```
在下个目标中按下 `C-c C-f`，写下 `cong succ`，按下 `C-c C-r`：
``` Agda
  +-assoc₃ : ∀ a b c → (a + b) + c ≡ a + (b + c)
  +-assoc₃ zero b c = refl
  +-assoc₃ (succ a) b c = cong succ {!check me!}
```
下个目标，按下 `C-c C-a`（自动证明搜索）：
``` Agda
  +-assoc : ∀ a b c → (a + b) + c ≡ a + (b + c)
  +-assoc zero b c = refl
  +-assoc (succ a) b c = cong succ (+-assoc a b c)
```
做完了。

（在 Agda 2.3.2 中你需要重新载入代码，证明搜索才能正常工作。这可能是个 Bug。）

类似地，我们可以证明：
``` Agda
  lemma-+zero : ∀ a → a + zero ≡ a
  lemma-+zero zero = refl
  lemma-+zero (succ a) = cong succ (lemma-+zero a)

  lemma-+succ : ∀ a b → succ a + b ≡ a + succ b
  lemma-+succ zero b = refl
  lemma-+succ (succ a) b = cong succ (lemma-+succ a b)
```
`_+_` 的结合性也就不难证明：
``` Agda
  -- 换种有趣的方式来写 trans
  infixr 5 _~_
  _~_ = trans

  +-comm : ∀ a b → a + b ≡ b + a
  +-comm zero b = sym (lemma-+zero b)
  +-comm (succ a) b = cong succ (+-comm a b) ~ lemma-+succ b a
```
想要一步一步地看证明过程，我们可以用 `{! !}` 来包住某个表达式，比如：
``` Agda
  +-comm (succ a) b = cong succ {!(+-comm a b)!} ~ lemma-+succ b a
```
按下 `C-c C-l`，然后按下 `C-c C-.`，我们就可以得到类型，上下文和推导出的类型。
refine，包住另一个表达式，重复。我期待一个更好的方式。

## 解类型等式

`+-comm` 的第二种情况非常有趣，值得我们手动推导隐式参数。让我们开始吧，算法如下：

- 首先，把所有的隐式参数和 `_` 都展开为「元变量」，也就是特殊的，
在程序中找不到的元层面的变量。
- 观察所有符号的类型，然后构造类型方程组。比如，如果你看到 `term1 term2 : D`，
`term1 : A → B` 和 `term2 : C`，就可以在方程组中加入 `A == C` 和 `B == D`。
- 在 unification 的帮助下解方程组。有两种可能：
    - 所有的元变量都解出来了。成功。
    - 有些时候解不出来。这种情况会被报告给用户，作为「未被解出的元变量」类型检查结果。
    当你不想编译或者不想在安全模式下类型检查，它们就表现得像警告一样，否则它们就会报错。
- 把所有的元变量用它们的解来替换。

对下面这个表达式使用上述算法：
``` Agda
trans (cong succ (+-comm1 a b)) (lemma-+succ b a)
```
得到
``` Agda
trans {ma} {mb} {mc} {md} (cong {me} {mf} {mg} {mh} succ (+-comm a b)) (lemma-+succ b a)
```
这里的 `m*` 都是元变量。

在 `+comm` 的类型中，`a b : ℕ` 因为 `_+_ : ℕ → ℕ →
ℕ`。这就得到了下面的方程组（去掉了重复的方程和元变量的应用）：
``` Agda
trans (cong succ (+-comm a b)) (lemma-+succ b a) : _≡_ {ℕ} (succ a + b) (b + succ a)
trans (cong succ (+-comm a b)) (lemma-+succ b a) : _≡_ {ℕ} (succ (a + b)) (b + succ a) -- normalization 之后
ma = ℕ
mb = succ (a + b)
md = b + succ a
+-comm a b : _≡_ {ℕ} (a + b) (b + a)
mg = (a + b)
me = ℕ
mh = (b + a)
mf = ℕ
cong succ (+-comm a b) : _≡_ {ℕ} (succ (a + b)) (succ (b + a))
mc = succ (b + a)
lemma-+succ b a : _≡_ {ℕ} (succ b + a) (b + succ a)
lemma-+succ b a : _≡_ {ℕ} (succ (b + a)) (b + succ a) -- normalization 之后
trans (cong succ (+-comm a b)) (lemma-+succ b a) : _≡_ {ℕ} (succ a + b) (b + succ a)
```
令人感到惊讶的是，在 Agda 看来，一个目标其实只是一种特殊的元变量。
当你按下 `C-c C-t` 或者 `C-c C-,` 来向 Agda 询问一个目标的类型时，
Agda 会打印出所有它知道的关于这个元变量的东西。
在 agda2-mode 中一些形如 `?0`，`?1` 之类的东西，实际上就是那些元变量。
比如在下面的代码中：
``` Agda
  metaVarTest : Vec ℕ (div2 (succ zero)) → ℕ
  metaVarTest = {!check me!}
```
这个目标的类型提到了这篇文章中最先的目标元类型。

顺便提一下，为了解决数据类型构造子重载的问题，Agda
首先推断在该位置的构造子应有的类型，然后和所有可能的同名构造子进行 unify。
如果没有匹配的构造子，那就报错。如果找到了多个，那么一个未解的元变量就会产生。

## Termination checking, well-founded induction
正在撰写

## Propositional equality 练习
**练习**。对第一个参数进行归纳来定义乘法：
``` Agda
  module Exercise where
    infix 7 _*_
    _*_ : ℕ → ℕ → ℕ
    n * m = {!!}
```
使得下面的证明可以通过：
``` Agda
    -- 分配律。
    *+-dist : ∀ a b c → (a + b) * c ≡ a * c + b * c
    *+-dist zero b c = refl
    -- λ 是 \lambda
    *+-dist (succ a) b c = cong (λ x → c + x) (*+-dist a b c) ~ sym (+-assoc c (a * c) (b * c))
```
现在，填写下面的目标：
``` Agda
    *-assoc : ∀ a b c → (a * b) * c ≡ a * (b * c)
    *-assoc zero b c = refl
    *-assoc (succ a) b c = *+-dist b (a * b) c ~ cong {!!} (*-assoc a b c)

    lemma-*zero : ∀ a → a * zero ≡ zero
    lemma-*zero a = {!!}

    lemma-+swap : ∀ a b c → a + (b + c) ≡ b + (a + c)
    lemma-+swap a b c = sym (+-assoc a b c) ~ {!!} ~ +-assoc b a c

    lemma-*succ : ∀ a b → a + a * b ≡ a * succ b 
    lemma-*succ a b = {!!}

    *-comm : ∀ a b → a * b ≡ b * a
    *-comm a b = {!!}
```
`C-c C-.` 在交互式证明中是非常有用的，它能显示目标的类型，上下文和推断出的类型。

## 用 with 来模式匹配
考虑 Haskell 中 `filter` 函数的实现：
``` Haskell
  filter :: (a → Bool) → [a] → [a]
  filter p [] = []
  filter p (a : as) = case p a of
    True  -> a : (filter p as)
    False -> filter p as
```
在 Agda 中可以这样写：
``` Agda
  filter : {A : Set} → (A → Bool) → List A → List A
  filter p [] = []
  filter p (a ∷ as) with p a
  ... | true  = a ∷ (filter p as)
  ... | false = filter p as
```
看上去区别不大。但是在根据 Agda 的语法规则来解语法糖 `...`
之后，它们看起来就不太像了：
``` Agda
  filter₀ : {A : Set} → (A → Bool) → List A → List A
  filter₀ p [] = []
  filter₀ p (a ∷ as) with p a
  filter₀ p (a ∷ as) | true  = a ∷ (filter₀ p as)
  filter₀ p (a ∷ as) | false = filter₀ p as
```
在 Agda 里并没有直接和 `case` 对应的关键字，`with`
让我们可以对某个表达式进行模式匹配（就像 Haskell 里的 `case`），
但是（不像 `case`）只能在最顶层进行。因此 `with`
只是给函数增加了一个「衍生」的参数。正如普通的参数那样，
对衍生的参数进行模式匹配可能会改变上下文中的某些类型。

顶层的限制可以简化所有和依赖类型相关的事情（主要和 dotted pattern 有关），
但是让一些事情变得有点尴尬（大多数情况下你可以用 `where` 来模拟 `case`）。
从语义上来说，竖线分隔了普通的参数和衍生的参数。

让我们把上面这个函数变得混乱一点：
``` Agda
  filterN : {A : Set} → (A → Bool) → List A → List A
  filterN p [] = []
  filterN p (a ∷ as) with p a
  filterN p (a ∷ as) | true  with as
  filterN p (a ∷ as) | true | [] = a ∷ []
  filterN p (a ∷ as) | true | b ∷ bs with p b
  filterN p (a ∷ as) | true | b ∷ bs | true  = a ∷ (b ∷ filterN p bs)
  filterN p (a ∷ as) | true | b ∷ bs | false = a ∷ filterN p bs
  filterN p (a ∷ as) | false = filterN p as
  -- 或者
  filterP : {A : Set} → (A → Bool) → List A → List A
  filterP p [] = []
  filterP p (a ∷ []) with p a
  filterP p (a ∷ []) | true = a ∷ []
  filterP p (a ∷ []) | false = []
  filterP p (a ∷ (b ∷ bs)) with p a | p b
  filterP p (a ∷ (b ∷ bs)) | true  | true  = a ∷ (b ∷ filterP p bs)
  filterP p (a ∷ (b ∷ bs)) | true  | false = a ∷ filterP p bs
  filterP p (a ∷ (b ∷ bs)) | false | true  = b ∷ filterP p bs
  filterP p (a ∷ (b ∷ bs)) | false | false = filterP p bs
```
这说明 `with` 可以嵌套，而且多个匹配可以同时进行。

让我们来证明所有这些函数对于相同的参数会产生相同的结果：
``` Agda
  filter≡filterN₀ : {A : Set} → (p : A → Bool) → (as : List A) → filter p as ≡ filterN p as
  filter≡filterN₀ p [] = refl
  filter≡filterN₀ p (a ∷ as) = {!check me!}
```
注意目标的类型 `(filter p (a ∷ as) | p a) ≡ (filterN p (a ∷ as) | p a)`
说明 `p a` 是 `filter` 函数的一个衍生的参数。

在上面的证明中，想要化简 `a + b` 我们首先要对 `a` 进行匹配。对 `b`
进行匹配不会产生任何有用的结果，因为我们是通过对第一个参数的归纳来定义 `_+_`的。
类似的，要完成 `filter≡filterN` 的证明，我们要对 `p a`，`as`，`p b` 进行匹配，
就像 `filterN` 那样：
``` Agda
  filter≡filterN : {A : Set} → (p : A → Bool) → (as : List A) → filter p as ≡ filterN p as
  filter≡filterN p [] = refl
  filter≡filterN p (a ∷ as) with p a
  filter≡filterN p (a ∷ as) | true with as
  filter≡filterN p (a ∷ as) | true | [] = refl
  filter≡filterN p (a ∷ as) | true | b ∷ bs with p b
  filter≡filterN p (a ∷ as) | true | b ∷ bs | true = cong (λ x → a ∷ (b ∷ x)) (filter≡filterN p bs)
  filter≡filterN p (a ∷ as) | true | b ∷ bs | false = cong (_∷_ a) (filter≡filterN p bs)
  filter≡filterN p (a ∷ as) | false = filter≡filterN p as
```
**练习**。猜测 `filter≡filterP` 和 `filterN≡filterP`
的类型。哪一个更容易证明？证明它（另一个的证明可以由传递性很容易得到）。

## 用 `with` 来重写和 unification
在进行和 filter 有关的证明时，你可能已经注意到 `with` 对目标做了一些有趣的事情。

在下面的目标中：
``` Agda
  filter≡filterN₁ : {A : Set} → (p : A → Bool) → (as : List A) → filter p as ≡ filterN p as
  filter≡filterN₁ p [] = refl
  filter≡filterN₁ p (a ∷ as) = {!check me!}
```
目标的类型是 `(filter p (a ∷ as) | p a) ≡ (filterN p (a ∷ as) | p a)`。
但是在下面的 `with` 之后：
``` Agda
  filter≡filterN₂ : {A : Set} → (p : A → Bool) → (as : List A) → filter p as ≡ filterN p as
  filter≡filterN₂ p [] = refl
  filter≡filterN₂ p (a ∷ as) with p a | as
  ... | r | rs = {!check me!}
```
它就变成了 `(filter p (a ∷ rs) | r) ≡ (filterN p (a ∷ rs) | r)`。

同样的事情不仅会出现在目标上，而且会出现在整个上下文中：
``` Agda
  strange-id : {A : Set} {B : A → Set} → (a : A) → (b : B a) → B a
  strange-id {A} {B} a ba with B a
  ... | r = {!check me!}
```
`ba` 的类型和目标的类型都是 `r`。

从这些观察中我们可以得出这样的结论，`with expr` 创建一个新的变量，比如叫 `w`，
然后将之前的上下文中的 `expr` 替换成 `w`。也就是说，在最后的上下文中，
所有含有 `expr` 的项都会依赖 `w`。

这个性质让我们可以用 `with` 来重写。
``` Agda
  lemma-+zero′ : ∀ a → a + zero ≡ a
  lemma-+zero′ zero = refl
  lemma-+zero′ (succ a) with a + zero | lemma-+zero′ a
  lemma-+zero′ (succ a) | ._ | refl = refl

  -- 相同的表达式，但是把下划线展开：
  lemma-+zero′₀ : ∀ a → a + zero ≡ a
  lemma-+zero′₀ zero = refl
  lemma-+zero′₀ (succ a) with a + zero | lemma-+zero′₀ a
  lemma-+zero′₀ (succ a) | .a | refl = refl
```
在这些项中，`a + zero` 被替换为一个新的变量，比如叫 `w`，它告诉我们
`lemma-+zero‵ a : a ≡ w`。对 `refl` 进行模式匹配，我们可以得到[`w = a`]，
因此 dotted pattern 就出现了。之后目标类型就变成了 `a ≡ a`。

这种模式：
``` Agda
f ps with a | eqn
... | ._ | refl = rhs
```
非常常见，以至于产生了这样的[缩写](https://lists.chalmers.se/pipermail/agda/2009/001513.html)：
``` Agda
f ps rewrite eqn = rhs
```
**练习**。在纸上证明，用 `with` 和 propositional equality 来重写目标类型，
只是某个由 `refl`，`sym`，`trans`，`cong` 构建得到的表达式的语法糖。

## Universes 和 postulates
在 Haskell 中，我们说「所有的类型都是 kind `*`，也就是说，对于任意的类型 `X`，`X : *`」。
到了 Agda 里，这句话就变成了「所有的基础类型的类型都是 `Set`，也就是说，对于任意的类型 `X`，`X : Set`」。
如果我们想要有一致性，我们就不能允许 `Set : Set`，因为这会导致一系列的悖论（具体见下）。
但我们仍然想构造一些类似于「元素是类型的列表」之类的东西，而且我们当前定义的列表不能做到这一点。

为了解决这个问题，Agda 引入了无穷多层的 `Set`，也就是说，`Set0 : Set1`，`Set1 : Set2`，
以此类推，`Set` 就是 `Set0` 的别名。注意，这些层次不是累积的，比如，
`Set0 : Set2` 和 `Set0 → Set1 : Set3` 就是错误的类型判定。

【*据我所知，让这些层次变得可以累积，在理论上没有任何问题，只不过 Agda
刚好选择了这种方式。谓语性则更加微妙一些（具体见下）。*】

元素是类型的列表就可以这样定义：
``` Agda
  data List1 (A : Set1) : Set1 where
    []  : List1 A
    _∷_ : A → List1 A → List1 A
```
看起来很像正常的 `List` 的定义。

为了避免这种重复代码，Agda 允许 universe 多态的定义。
为了定义 universe 的层级 `Level`，我们需要使用一些 `postulate` 黑魔法：
``` Agda
  postulate Level : Set
  postulate lzero : Level
  postulate lsucc : Level → Level
  postulate _⊔_   : Level → Level → Level
```
`postulate` 定义了命题而没有证明它们，也就是说，`postulate` 告诉
Agda「相信我，我知道这是对的」。显然，这可以用来构造矛盾：
``` Agda
  postulate undefined : {A : Set} → A
```
但是对于 Agda 觉得是安全的 `postulate`，有一个 `BUILTIN` 关键词，
它会检查 `postulate` 的定义，然后把它从简单的 `postulate` 变成公理。
对于 `Level` 有以下的 `BUILTIN`：
``` Agda
  {-# BUILTIN LEVEL     Level #-}
  {-# BUILTIN LEVELZERO lzero #-}
  {-# BUILTIN LEVELSUC  lsucc #-}
  {-# BUILTIN LEVELMAX  _⊔_   #-}
```
类型 `Level` 和 `ℕ` 很像。它有两个构造子 `lzero` 和 `lsucc`。另外也有一个运算符
`_⊔_`，它返回两者的最大值。`ℕ` 和 `Level` 的区别在于我们不能对后者进行模式匹配。

有了上述的定义，对于 `α : Level`，表达式 `Set α` 就表示第 `α` 层的 `Set`。

现在我们就可以用下面的方式来定义 universe 多态的列表：
``` Agda
  data PList₀ {α : Level} (A : Set α) : Set α where
    []  : PList₀ A
    _∷_ : A → PList₀ A → PList₀ A
  -- 或者更好看一点
  data PList₁ {α} (A : Set α) : Set α where
    []  : PList₁ A
    _∷_ : A → PList₁ A → PList₁ A
```
有趣的是，Agda 可以用另一种方式，叫做「GHC
的方式」，也就是用固定的名字来定义所有内置的东西。相反地，
`BUILTIN`
关键词让我们可以重新定义内置函数的名字，这在我们写自己的标准库的时候很有帮助。
这正是我们接下来将要做的事情。

# 库

## Module，结束要舍弃的代码
注意我们写的所有东西都在一个叫 `ThrowAwayIntroduction` 的 module 里。
从现在开始我们（几乎）要忘记它，然后从头开始写一个小型的 Agda 标准库。
我们想把所有的以「ThrowAway」开头的 module
全部从这个文件中移除，来生成标准库代码。为了让这个实现尽可能简单，
我们像这样放置一个标记：
``` Agda
{- end of ThrowAwayIntroduction -}
```
在要舍弃的代码的结尾。这就允许我们用简单的命令生成这个库：
``` Bash
cat BrutalDepTypes.lagda | sed '/^\\begin{code}/,/^\\end{code}/ ! d; /^\\begin{code}/ d; /^\\end{code}/ c \
' | sed '/^ *module ThrowAway/,/^ *.- end of ThrowAway/ d;'
```
我们需要以universe polymorphic的方式重新定义所有有用的东西（如果可以的话），从 `Level` 开始：
``` Agda
module Level where
  -- Universe 层级
  postulate Level : Set
  postulate lzero : Level
  postulate lsucc : Level → Level
  -- ⊔ 是\sqcup
  postulate _⊔_   : Level → Level → Level

  infixl 5 _⊔_

  -- 让他们能工作
  {-# BUILTIN LEVEL     Level #-}
  {-# BUILTIN LEVELZERO lzero #-}
  {-# BUILTIN LEVELSUC  lsucc #-}
  {-# BUILTIN LEVELMAX  _⊔_   #-}
```
Agda 中每一个 module 都有一个导出列表。所有在这个 module
里面被定义的东西都会被添加到这个列表里。要想把在另一个 module
导出的定义引入到当前上下文中，需要用 `open` 关键词：
``` Agda
open ModuleName
```
这不会把 `ModuleName` 的导出列表添加到当前 module 的导出列表中。
想要做到这一点，我们需要在后面加上 `public` 关键词。
``` Agda
open Level public
```

##  类型诡异的常用函数
**练习**。理解下面这些函数的类型是怎么回事：
``` Agda
module Function where
  -- Dependent application
  infixl 0 _$_
  _$_ : ∀ {α β}
      → {A : Set α} {B : A → Set β}
      → (f : (x : A) → B x)
      → ((x : A) → B x)
  f $ x = f x

  -- Simple application
  infixl 0 _$′_
  _$′_ : ∀ {α β}
      → {A : Set α} {B : Set β}
      → (A → B) → (A → B)
  f $′ x = f $ x

  -- input for ∘ is \o
  -- Dependent composition
  _∘_ : ∀ {α β γ}
      → {A : Set α} {B : A → Set β} {C : {x : A} → B x → Set γ}
      → (f : {x : A} → (y : B x) → C y)
      → (g : (x : A) → B x)
      → ((x : A) → C (g x))
  f ∘ g = λ x → f (g x)

  -- Simple composition
  _∘′_ : ∀ {α β γ}
      → {A : Set α} {B : Set β} {C : Set γ}
      → (B → C) → (A → B) → (A → C)
  f ∘′ g = f ∘ g

  -- Flip
  flip : ∀ {α β γ}
       → {A : Set α} {B : Set β} {C : A → B → Set γ} 
       → ((x : A) → (y : B) → C x y)
       → ((y : B) → (x : A) → C x y)
  flip f x y = f y x

  -- Identity
  id : ∀ {α} {A : Set α} → A → A
  id x = x

  -- Constant function
  const : ∀ {α β}
       → {A : Set α} {B : Set β}
       → (A → B → A)
  const x y = x

open Function public
```
特别注意类型中的变量绑定域。

## 逻辑
直觉主义逻辑：
``` Agda
module Logic where
  -- input for ⊥ is \bot
  -- False proposition
  data ⊥ : Set where

  -- input for ⊤ is \top
  -- True proposition
  record ⊤ : Set where

  -- ⊥ implies anything at any universe level
  ⊥-elim : ∀ {α} {A : Set α} → ⊥ → A
  ⊥-elim ()
```
命题的否定定义如下：
``` Agda
  -- ¬ 是 \lnot
  ¬ : ∀ {α} → Set α → Set α
  ¬ P = P → ⊥
```
这种定义源自于爆炸原理（矛盾可以推导出一切）。

**练习**。证明下面的命题：
``` Agda
  module ThrowAwayExercise where
    contradiction : ∀ {α β} {A : Set α} {B : Set β} → A → ¬ A → B
    contradiction = {!!}

    contraposition : ∀ {α β} {A : Set α} {B : Set β} → (A → B) → (¬ B → ¬ A)
    contraposition = {!!}

    contraposition¬ : ∀ {α β} {A : Set α} {B : Set β} → (A → ¬ B) → (B → ¬ A)
    contraposition¬ = {!!}

    →¬² : ∀ {α} {A : Set α} → A → ¬ (¬ A)
    →¬² a = {!!}

    ¬³→¬ : ∀ {α} {A : Set α} → ¬ (¬ (¬ A)) → ¬ A
    ¬³→¬ = {!!}
```
提示。使用 `C-c C-,` 来看正规化的目标类型。

从一个更有逻辑的立场来看，`¬` 背后的原理在于，假命题 `P` 和 `⊥` 是同构的
（也就是说，它们可以互相推导：`⊥ → P ∧ P → ⊥`）。因为 `⊥ → P` 对所有的 `P`
都成立，因此我们只需证明 `P → ⊥`。

从计算的角度来看，在上下文中出现类型 `⊥`
的一个元素就意味着这个程序的执行不可能到达这里。
这也就是说我们可以对这个变量进行匹配并且使用不合理的模式，
`⊥-elim` 正是做了这件事。

注意，作为直觉主义逻辑系统，Agda 不能证明双重否定律。不妨一试：
``` Agda
    ¬²→ : ∀ {α} {A : Set α} → ¬ (¬ A) → A
    ¬²→ ¬¬a = {!check me!}
  {- end of ThrowAwayExercise -}
```
顺便提一下，上述练习的证明导致了20世纪初一系列论文的产生。

练习的答案：
``` Agda
  private
   module DummyAB {α β} {A : Set α} {B : Set β} where
    contradiction : A → ¬ A → B
    contradiction a ¬a = ⊥-elim (¬a a)

    contraposition : (A → B) → (¬ B → ¬ A)
    contraposition = flip _∘′_

    contraposition¬ : (A → ¬ B) → (B → ¬ A)
    contraposition¬ = flip

  open DummyAB public

  private
   module DummyA {α} {A : Set α} where
    →¬² : A → ¬ (¬ A)
    →¬² = contradiction

    ¬³→¬ : ¬ (¬ (¬ A)) → ¬ A
    ¬³→¬ ¬³a = ¬³a ∘′ →¬²

  open DummyA public
```
**练习**。理解上面的答案：

注意这里关于 module 使用的技巧。打开一个带参数的 module 会使得这个 module
里面定义的东西都带上这个参数。我们会大量地使用这个技巧。

让我们来定义合取，析取，和逻辑上的等价：
``` Agda
  -- ∧ 是 \and
  record _∧_ {α β} (A : Set α) (B : Set β) : Set (α ⊔ β) where
    constructor _,′_
    field
      fst : A
      snd : B

  open _∧_ public

  -- ∨ 是 \or
  data _∨_ {α β} (A : Set α) (B : Set β) : Set (α ⊔ β) where
    inl : A → A ∨ B
    inr : B → A ∨ B

  -- ↔  是 \<->
  _↔_ : ∀ {α β} (A : Set α) (B : Set β) → Set (α ⊔ β)
  A ↔ B = (A → B) ∧ (B → A)
```
把这些好东西都开放：
``` Agda
open Logic public
```

## MLTT：类型和性质
一些来自于 Per Martin-Löf 类型理论中的定义：
``` Agda
module MLTT where
  -- ≡ 是 \==
  -- Propositional equality
  infix 4 _≡_
  data _≡_ {α} {A : Set α} (x : A) : A → Set α where
    refl : x ≡ x

  -- Σ 是 \Sigma
  -- Dependent pair
  record Σ {α β} (A : Set α) (B : A → Set β) : Set (α ⊔ β) where
    constructor _,_
    field
      projl : A
      projr : B projl

  open Σ public

  -- 让 rewrite 语法能够工作
  {-# BUILTIN EQUALITY _≡_ #-}
  {-# BUILTIN REFL    refl #-}
```
`Σ` 类型是依赖版本的 `_∧_`（第二个参数依赖第一个），也就是说，`_∧_` 是一种特殊的
`Σ`：
``` Agda
  -- × 是 \x
  _×_ : ∀ {α β} (A : Set α) (B : Set β) → Set (α ⊔ β)
  A × B = Σ A (λ _ → B)

  ×↔∧ : ∀ {α β} {A : Set α} {B : Set β} → (A × B) ↔ (A ∧ B)
  ×↔∧ = (λ z → projl z ,′ projr z) ,′ (λ z → fst z , snd z)
```
我个人都很少用 `_∧_` 和 `_×_` 因为 `_×_` 在规约形式中很丑，使得目标类型很难读。

一些性质：
``` Agda
  module ≡-Prop where
   private
    module DummyA {α} {A : Set α} where
      -- _≡_ 具有对称性
      sym : {x y : A} → x ≡ y → y ≡ x
      sym refl = refl

      -- _≡_ 具有传递性
      trans : {x y z : A} → x ≡ y → y ≡ z → x ≡ z
      trans refl refl = refl

      -- _≡_ 具有可替换性
      subst : ∀ {γ} {P : A → Set γ} {x y} → x ≡ y → P x → P y
      subst refl p = p

    private
     module DummyAB {α β} {A : Set α} {B : Set β} where
      -- _≡_ 是一致的
      cong : ∀ (f : A → B) {x y} → x ≡ y → f x ≡ f y
      cong f refl = refl

      subst₂ : ∀ {ℓ} {P : A → B → Set ℓ} {x y u v} → x ≡ y → u ≡ v → P x u → P y v
      subst₂ refl refl p = p

    private
     module DummyABC {α β γ} {A : Set α} {B : Set β} {C : Set γ} where
      cong₂ : ∀ (f : A → B → C) {x y u v} → x ≡ y → u ≡ v → f x u ≡ f y v
      cong₂ f refl refl = refl

    open DummyA public
    open DummyAB public
    open DummyABC public
```
把这些好东西都开放：
``` Agda
open MLTT public
```

## 可判定的命题
``` Agda
module Decidable where
```
可判定命题是有显式证明或证伪的命题：
``` Agda
  data Dec {α} (A : Set α) : Set α where
    yes : ( a :   A) → Dec A
    no  : (¬a : ¬ A) → Dec A
```
这个数据类型非常像 `Bool`，除了它也解释了为什么命题成立或者为什么不成立。

可判定命题是让你的程序能和现实世界交互的胶水。

假设我们想要写一个程序，它从 `stdin` 读入一个自然数 `n`，然后用 `div2E`
来把它除以二。想要完成这件事我们需要一个 `n` 是 `Even`
的证明。最简单的方式就是定义一个判定一个自然数是不是 `Even` 的函数：
``` Agda
  module ThrowAwayExample₁ where
    open ThrowAwayIntroduction

    ¬Even+2 : ∀ {n} → ¬ (Even n) → ¬ (Even (succ (succ n)))
    ¬Even+2 ¬en (e2succ en) = contradiction en ¬en

    Even? : ∀ n → Dec (Even n)
    Even? zero        = yes ezero
    Even? (succ zero) = no (λ ()) -- 注意一个不合理的模式
                                  -- 在一个匿名函数里
    Even? (succ (succ n)) with Even? n
    ... | yes a       = yes (e2succ a)
    ... | no  a¬      = no (¬Even+2 a¬)
  {- end of ThrowAwayExample₁ -}
```
然后从 `stdin` 读入 `n`，把它交给 `Even?`，对结果进行匹配，如果 `n` 是 `Even`
的话就调用 `div2E`。

同样的想法适用于几乎所有事情：

- 想要写一个语法分析器？语法分析器是一个判断一个字符串是否符合语法的程序。
- 想要对一个程序进行类型检查？类型检查器是一个判断程序是否符合一系列类型规则的程序。
- 想要优化编译器？语法分析，对 `yes` 匹配，类型检查，对 `yes`
匹配，优化带类型的表示，生成结果。
- 还有很多。

用同样的想法我们可以定义可判定的二分和三分命题：
``` Agda
  data Di {α β} (A : Set α) (B : Set β) : Set (α ⊔ β) where
    diyes : ( a :   A) (¬b : ¬ B) → Di A B
    dino  : (¬a : ¬ A) ( b :   B) → Di A B

  data Tri {α β γ} (A : Set α) (B : Set β) (C : Set γ) : Set (α ⊔ (β ⊔ γ)) where
    tri< : ( a :   A) (¬b : ¬ B) (¬c : ¬ C) → Tri A B C
    tri≈ : (¬a : ¬ A) ( b :   B) (¬c : ¬ C) → Tri A B C
    tri> : (¬a : ¬ A) (¬b : ¬ B) ( c :   C) → Tri A B C
```
把这些好东西都开放：
``` Agda
open Decidable public
```

## 自然数：运算，性质和关系
这些基本上就是上面练习的答案（用 `rewrite` 加密过的）：
``` Agda
module Data-ℕ where
  -- 自然数
  data ℕ : Set where
    zero : ℕ
    succ : ℕ → ℕ

  module ℕ-Rel where
    infix 4 _≤_ _<_ _>_

    data _≤_ : ℕ → ℕ → Set where
      z≤n : ∀ {n}           → zero ≤ n
      s≤s : ∀ {n m} → n ≤ m → succ n ≤ succ m

    _<_ : ℕ → ℕ → Set
    n < m = succ n ≤ m

    _>_ : ℕ → ℕ → Set
    n > m = m < n

    ≤-unsucc : ∀ {n m} → succ n ≤ succ m → n ≤ m
    ≤-unsucc (s≤s a) = a 

    <-¬refl : ∀ n → ¬ (n < n)
    <-¬refl zero ()
    <-¬refl (succ n) (s≤s p) = <-¬refl n p

    ≡→≤ : ∀ {n m} → n ≡ m → n ≤ m
    ≡→≤ {zero}   refl = z≤n
    ≡→≤ {succ n} refl = s≤s (≡→≤ {n} refl) -- 注意这里

    ≡→¬< : ∀ {n m} → n ≡ m → ¬ (n < m)
    ≡→¬< refl = <-¬refl _

    ≡→¬> : ∀ {n m} → n ≡ m → ¬ (n > m)
    ≡→¬> refl = <-¬refl _

    <→¬≡ : ∀ {n m} → n < m → ¬ (n ≡ m)
    <→¬≡ = contraposition¬ ≡→¬<

    >→¬≡ : ∀ {n m} → n > m → ¬ (n ≡ m)
    >→¬≡ = contraposition¬ ≡→¬>

    <→¬> : ∀ {n m} → n < m → ¬ (n > m)
    <→¬> {zero} (s≤s z≤n) ()
    <→¬> {succ n} (s≤s p<) p> = <→¬> p< (≤-unsucc p>)

    >→¬< : ∀ {n m} → n > m → ¬ (n < m)
    >→¬< = contraposition¬ <→¬>

  module ℕ-Op where
    open ≡-Prop

    pred : ℕ → ℕ
    pred zero = zero
    pred (succ n) = n

    infixl 6 _+_
    _+_ : ℕ → ℕ → ℕ
    zero   + n = n
    succ n + m = succ (n + m)

    infixr 7 _*_
    _*_ : ℕ → ℕ → ℕ
    zero   * m = zero
    succ n * m = m + (n * m)

    private
     module Dummy₀ where
      lemma-+zero : ∀ a → a + zero ≡ a
      lemma-+zero zero = refl
      lemma-+zero (succ a) rewrite lemma-+zero a = refl

      lemma-+succ : ∀ a b → succ a + b ≡ a + succ b
      lemma-+succ zero b = refl
      lemma-+succ (succ a) b rewrite lemma-+succ a b = refl

    open Dummy₀

    -- + 结合律
    +-assoc : ∀ a b c → (a + b) + c ≡ a + (b + c)
    +-assoc zero b c = refl
    +-assoc (succ a) b c rewrite (+-assoc a b c) = refl

    -- + 交换律
    +-comm : ∀ a b → a + b ≡ b + a
    +-comm zero b = sym $ lemma-+zero b
    +-comm (succ a) b rewrite +-comm a b | lemma-+succ b a = refl

    -- * 分配律
    *+-dist : ∀ a b c → (a + b) * c ≡ a * c + b * c
    *+-dist zero b c = refl
    *+-dist (succ a) b c rewrite *+-dist a b c | +-assoc c (a * c) (b * c) = refl

    -- * 结合律
    *-assoc : ∀ a b c → (a * b) * c ≡ a * (b * c)
    *-assoc zero b c = refl
    *-assoc (succ a) b c rewrite *+-dist b (a * b) c | *-assoc a b c = refl

    private
     module Dummy₁ where
      lemma-*zero : ∀ a → a * zero ≡ zero
      lemma-*zero zero = refl
      lemma-*zero (succ a) = lemma-*zero a

      lemma-+swap : ∀ a b c → a + (b + c) ≡ b + (a + c)
      lemma-+swap a b c rewrite sym (+-assoc a b c) | +-comm a b | +-assoc b a c = refl

      lemma-*succ : ∀ a b → a + a * b ≡ a * succ b 
      lemma-*succ zero b = refl
      lemma-*succ (succ a) b rewrite lemma-+swap a b (a * b) | lemma-*succ a b = refl

    open Dummy₁

    -- * 交换律
    *-comm : ∀ a b → a * b ≡ b * a
    *-comm zero b = sym $ lemma-*zero b
    *-comm (succ a) b rewrite *-comm a b | lemma-*succ b a = refl

  module ℕ-RelOp where
    open ℕ-Rel
    open ℕ-Op
    open ≡-Prop

    infix 4 _≡?_ _≤?_ _<?_

    _≡?_ : (n m : ℕ) → Dec (n ≡ m)
    zero    ≡? zero   = yes refl
    zero    ≡? succ m = no (λ ())
    succ n  ≡? zero   = no (λ ())
    succ n  ≡? succ m with n ≡? m
    succ .m ≡? succ m | yes refl = yes refl
    succ n  ≡? succ m | no ¬a    = no (¬a ∘ cong pred) -- 注意这里

    _≤?_ : (n m : ℕ) → Dec (n ≤ m)
    zero ≤? m = yes z≤n
    succ n ≤? zero = no (λ ())
    succ n ≤? succ m with n ≤? m
    ... | yes a = yes (s≤s a)
    ... | no ¬a = no (¬a ∘ ≤-unsucc)

    _<?_ : (n m : ℕ) → Dec (n < m)
    n <? m = succ n ≤? m

    cmp : (n m : ℕ) → Tri (n < m) (n ≡ m) (n > m)
    cmp zero zero     = tri≈ (λ ()) refl (λ ())
    cmp zero (succ m) = tri< (s≤s z≤n) (λ ()) (λ ())
    cmp (succ n) zero = tri> (λ ()) (λ ()) (s≤s z≤n)
    cmp (succ n) (succ m) with cmp n m
    cmp (succ n) (succ m) | tri< a ¬b ¬c = tri< (s≤s a) (¬b ∘ cong pred) (¬c ∘ ≤-unsucc)
    cmp (succ n) (succ m) | tri≈ ¬a b ¬c = tri≈ (¬a ∘ ≤-unsucc) (cong succ b) (¬c ∘ ≤-unsucc)
    cmp (succ n) (succ m) | tri> ¬a ¬b c = tri> (¬a ∘ ≤-unsucc) (¬b ∘ cong pred) (s≤s c)

open Data-ℕ public
```
**练习**。理解这些。现在，删除 `ℕ-RelProp` 和 `ℕ-RelOp` 的函数体然后自己实现它们。

## 列表和向量
``` Agda
module Data-List where
  -- 列表
  infixr 5 _∷_
  data List {α} (A : Set α) : Set α where
    []  : List A
    _∷_ : A → List A → List A

  module List-Op where
  private
   module DummyA {α} {A : Set α} where
    -- 单个元素的 `List`
    [_] : A → List A
    [ a ] = a ∷ []

    -- `List` 串联
    infixr 5 _++_
    _++_ : List A → List A → List A
    []       ++ bs = bs
    (a ∷ as) ++ bs = a ∷ (as ++ bs)

    -- 用可判定命题进行过滤
    filter : ∀ {β} {P : A → Set β} → (∀ a → Dec (P a)) → List A → List A
    filter p [] = []
    filter p (a ∷ as) with p a
    ... | yes _ = a ∷ (filter p as)
    ... | no  _ = filter p as

  open DummyA public

module Data-Vec where
  -- 向量
  infixr 5 _∷_
  data Vec {α} (A : Set α) : ℕ → Set α where
    []  : Vec A zero
    _∷_ : ∀ {n} → A → Vec A n → Vec A (succ n)

  module Vec-Op where
    open ℕ-Op

    private
     module DummyA {α} {A : Set α} where
      -- 单个元素的 `Vec`
      [_] : A → Vec A (succ zero)
      [ a ] = a ∷ []

      -- `Vec` 串联
      infixr 5 _++_
      _++_ : ∀ {n m} → Vec A n → Vec A m → Vec A (n + m)
      []       ++ bs = bs
      (a ∷ as) ++ bs = a ∷ (as ++ bs)

      head : ∀ {n} → Vec A (succ n) → A
      head (a ∷ as) = a

      tail : ∀ {n} → Vec A (succ n) → A
      tail (a ∷ as) = a

    open DummyA public
```
``` Agda
{-
正在撰写。TODO

我发现下面的定义很有趣：

module VecLists where
  open Data-Vec

  private
   module DummyA {α} {A : Set α} where
     VecList = Σ ℕ (Vec A)
-}
```

## 在 `List` 里
索引允许我们定义有趣的东西：
``` Agda
module ThrowAwayMore₁ where
  open Data-List
  open List-Op

  -- ∈ 是 \in
  -- `a` 在 `List` 里
  data _∈_ {α} {A : Set α} (a : A) : List A → Set α where
    here  : ∀ {as}   → a ∈ (a ∷ as)
    there : ∀ {b as} → a ∈ as → a ∈ (b ∷ as)

  -- ⊆ 是 \sub= 
  -- `xs` 是 `ys` 的子列表
  _⊆_ : ∀ {α} {A : Set α} → List A → List A → Set α
  as ⊆ bs = ∀ {x} → x ∈ as → x ∈ bs
```
`_∈_` 关系的含义是，如果一个元素 `a : A`「在一个 `List`」里，那就说明 `a` 是
`List` 的头，或者 `a` 在 `List` 的其余元素中。对于某个 `a` 和 `as`，类型 `a ∈ as` 的一个值，
也就是「`a` 在列表 `as` 里面」，这个值表示 `a` 在 `as`
中的位置（在这个类型中可能有任意多个元素）。关系 `⊆`，也就是「是一个子列表」，
是这样一个函数：对每一个 `xs` 中的 `a`，可以给出它在 `as` 中的位置。

一些例子：
``` Agda
  listTest₁ = zero ∷ zero ∷ succ zero ∷ []
  listTest₂ = zero ∷ succ zero ∷ []

  ∈Test₀ : zero ∈ listTest₁
  ∈Test₀ = here

  ∈Test₁ : zero ∈ listTest₁
  ∈Test₁ = there here

  ⊆Test : listTest₂ ⊆ listTest₁
  ⊆Test here = here
  ⊆Test (there here) = there (there here)
  ⊆Test (there (there ()))
```
让我们来证明关系 `⊆` 的一些性质：
``` Agda
  ⊆-++-left : ∀ {A : Set} (as bs : List A) → as ⊆ (bs ++ as)
  ⊆-++-left as [] n = n
  ⊆-++-left as (b ∷ bs) n = there (⊆-++-left as bs n)

  ⊆-++-right : ∀ {A : Set} (as bs : List A) → as ⊆ (as ++ bs)
  ⊆-++-right [] bs ()
  ⊆-++-right (a ∷ as) bs here = here
  ⊆-++-right (a ∷ as) bs (there n) = there (⊆-++-right as bs n)
{- end of ThrowAwayMore₁ -}
```
注意对于给定的列表，这些证明是如何对元素重新计数的。

## 推广的在 `List` 里：Any
通过将关系 `⊆` 从 propositional equality（在 `x ∈ (x ∷ xs)` 中两个 `x` 是 propositionally equal 的）
推广到任意的谓词，我们可以得到：
``` Agda
module Data-Any where
  open Data-List
  open List-Op

  -- `List` 中的某个元素满足 `P`
  data Any {α γ} {A : Set α} (P : A → Set γ) : List A → Set (α ⊔ γ) where
    here  : ∀ {a as} → (pa  : P a)      → Any P (a ∷ as)
    there : ∀ {a as} → (pas : Any P as) → Any P (a ∷ as)

  module Membership {α β γ} {A : Set α} {B : Set β} (P : B → A → Set γ) where
    -- ∈ 是 \in
    -- 对于 `List` 中的某个 `a`，`P b a` 成立
    -- 当 P 是 `_≡_` 时，这就变成了上面的「在里面」的关系
    _∈_ : B → List A → Set (α ⊔ γ)
    b ∈ as = Any (P b) as

    -- ∉ 是 \notin
    _∉_ : B → List A → Set (α ⊔ γ)
    b ∉ as = ¬ (b ∈ as)

    -- ⊆ 是 \sub=
    _⊆_ : List A → List A → Set (α ⊔ β ⊔ γ)
    as ⊆ bs = ∀ {x} → x ∈ as → x ∈ bs

    -- ⊈ 是 \sub=n
    _⊈_ : List A → List A → Set (α ⊔ β ⊔ γ)
    as ⊈ bs = ¬ (as ⊆ bs)

    -- ⊇ 是 \sup=
    _⊆⊇_ : List A → List A → Set (α ⊔ β ⊔ γ)
    as ⊆⊇ bs = (as ⊆ bs) ∧ (bs ⊆ as)

    ⊆-refl : ∀ {as} → as ⊆ as
    ⊆-refl = id

    ⊆-trans : ∀ {as bs cs} → as ⊆ bs → bs ⊆ cs → as ⊆ cs
    ⊆-trans f g = g ∘ f

    ⊆⊇-refl : ∀ {as} → as ⊆⊇ as
    ⊆⊇-refl = id ,′ id

    ⊆⊇-sym : ∀ {as bs} → as ⊆⊇ bs → bs ⊆⊇ as
    ⊆⊇-sym (f ,′ g) = g ,′ f

    ⊆⊇-trans : ∀ {as bs cs} → as ⊆⊇ bs → bs ⊆⊇ cs → as ⊆⊇ cs
    ⊆⊇-trans f g = (fst g ∘ fst f) ,′ (snd f ∘ snd g)

    ∉[] : ∀ {b} → b ∉ []
    ∉[]()

    -- 当 P 是 `_≡_` 时，这就变成 `b ∈ [ a ] → b ≡ a`
    ∈singleton→P : ∀ {a b} → b ∈ [ a ] → P b a
    ∈singleton→P (here pba) = pba
    ∈singleton→P (there ())

    P→∈singleton : ∀ {a b} → P b a → b ∈ [ a ]
    P→∈singleton pba = here pba

    ⊆-++-left : (as bs : List A) → as ⊆ (bs ++ as)
    ⊆-++-left as [] n = n
    ⊆-++-left as (b ∷ bs) n = there (⊆-++-left as bs n)

    ⊆-++-right : (as : List A) (bs : List A) → as ⊆ (as ++ bs)
    ⊆-++-right [] bs ()
    ⊆-++-right (x ∷ as) bs (here pa) = here pa
    ⊆-++-right (x ∷ as) bs (there n) = there (⊆-++-right as bs n)

    ⊆-filter : ∀ {σ} {Q : A → Set σ} → (q : ∀ x → Dec (Q x)) → (as : List A) → filter q as ⊆ as
    ⊆-filter q [] ()
    ⊆-filter q (a ∷ as) n with q a
    ⊆-filter q (a ∷ as) (here pa) | yes qa = here pa
    ⊆-filter q (a ∷ as) (there n) | yes qa = there (⊆-filter q as n)
    ⊆-filter q (a ∷ as) n         | no ¬qa = there (⊆-filter q as n)
```
**练习**。注意这里的代码非常具有一般性。`⊆-filter` 覆盖了很多命题，
而「筛选后的列表是筛选前列表的一个子列表（常规意义上的）」就是其中一个特例。
在下面的目标中按下 `C-c C-.` 并解释它的类型：
``` Agda
module ThrowAwayMore₂ where
  goal = {!Data-Any.Membership.⊆-filter!}
{- end of ThrowAwayMore₂ -}<Paste>
```
解释 `Membership` module 中所有项的类型。

## 对偶谓词：All
``` Agda
{-
Work in progress. TODO.

I didn't have a chance to use `All` yet (and I'm too lazy to implement this module right now),
but here is the definition:

module Data-All where
  open Data-List
  -- All elements of a `List` satisfy `P`
  data All {α β} {A : Set α} (P : A → Set β) : List A → Set (α ⊔ β) where
    []∀  : All P []
    _∷∀_ : ∀ {a as} → P a → All P as → All P (a ∷ as)
-}
```

## 布尔类型
有了 `Dec`，我们实际上不需要布尔类型。
``` Agda
module Data-Bool where
  -- 布尔
  data Bool : Set where
    true false : Bool

  module Bool-Op where
    if_then_else_ : ∀ {α} {A : Set α} → Bool → A → A → A
    if true  then a else _ = a
    if false then _ else b = b

    not : Bool → Bool
    not true  = false
    not false = true

    and : Bool → Bool → Bool
    and true  x = x
    and false _ = false

    or : Bool → Bool → Bool
    or false x = x
    or true  x = true

open Data-Bool public
```

## 其他
正在撰写。TODO。我们要证明一些东西，也许是快排。

# 理论的角落
这一节我们将要讨论 Agda 中处于理论和实际中间的一些有趣的东西。
``` Agda
module ThrowAwayPreTheory where
  open ≡-Prop
  open ℕ-Op
```
## 等价和 unification
利用等价来重写的过程隐藏了一些细节。

回忆一下 `lemma-+zero′` 的定义：
``` Agda
  lemma-+zero′ : ∀ a → a + zero ≡ a
  lemma-+zero′ zero = refl
  lemma-+zero′ (succ a) with a + zero | lemma-+zero′ a
  lemma-+zero′ (succ a) | ._ | refl = refl
```
它能通过类型检查，但是下面的证明就不能：
``` Agda
  lemma-+zero′′ : ∀ a → a + zero ≡ a
  lemma-+zero′′ zero = refl
  lemma-+zero′′ (succ a) with a | lemma-+zero′′ a
  lemma-+zero′′ (succ a) | ._ | refl = refl
```
这里的问题在于对于任意的 `A` 和 `B`，想要对 `refl : A ≡ B`
进行模式匹配，这里的 `A` 和 `B` 必须 unify。在 `lemma-+zero′` 中，
我们把 `a + zero` 替换为一个新变量 `w`，然后我们对 `refl`
进行模式匹配后得到 `w ≡ a`。另一方面，在 `lemma-+zero′′` 中 `a`
变成了 `w`，对 `refl` 进行模式匹配后得到 `w + zero ≡ w`，
这个类型是一个畸形的（递归的）unification 限制。

另外一点，我们现在的 `_≡_` 的定义允许我们表达类型层面的相等，
比如，`Bool ≡ ℕ`。

这就使我们可以写出下面的定义：
``` Agda
  lemma-unsafe-eq : (P : Bool ≡ ℕ) → Bool → ℕ
  lemma-unsafe-eq P b with Bool | P
  lemma-unsafe-eq P b | .ℕ | refl = b + succ zero
```
它能通过类型检查。

但是，`lemma-unsafe-eq` 不能通过简单的对 `P` 的模式匹配来证明。
``` Agda
  lemma-unsafe-eq₀ : (P : Bool ≡ ℕ) → Bool → ℕ
  lemma-unsafe-eq₀ refl b = b
```
``` Agda
{- end of ThrowAwayPreTheory -}
```
**练习**。`lemma-unsafe-eq` 可以让我们思考在错误假设下的计算可靠性问题。

# 纯理论的角落

在这一节里我们将要讨论一些理论上的东西，比如数据类型的编码和一些悖论。
你可能会想要先读一些理论书籍，比如[10]，[12]。
``` Agda
module ThrowAwayTheory where
```
Agda 的箭头 `(x : X) → Y`（`Y` 里面可能没有 `x`）叫做
依赖积类型，或者简称 Π 类型（Pi-类型）。依赖对 `Σ` 被叫做
依赖和类型，或者简称 Σ 类型（Sigma-类型）

## 有限类型
有了 `⊥`，`⊤` 和 `Bool`，我们就可以定义任意的有限类型，
也就是拥有有限个元素的类型。
``` Agda
  module FiniteTypes where
    open Bool-Op

    _∨′_ : (A B : Set) → Set
    A ∨′ B = Σ Bool (λ x → if x then A else B)

    zero′  = ⊥
    one′   = ⊤
    two′   = Bool
    three′ = one′ ∨′ two′
    four′  = two′ ∨′ two′
    --- 以此类推
```
TODO。讨论一些有关存在性和 `⊤ = ⊥ → ⊥` 的问题。

## 简单的数据类型
``` Agda
  module ΠΣ-Datatypes where
```
有了有限数据类型，Π-类型和 Σ-类型，我们就可以定义一些非归纳的数据类型，
利用和 `_∨′_` 差不多的方式。

没有索引的非递归数据类型可以用以下的方案来定义：
``` Agda
data DataTypeName (Param1 : Param1Type) (Param2 : Param2Type) ... : Set whatever
  Cons1 : (Cons1Arg1 : Cons1Arg1Type) (Cons1Arg2 : Cons1Arg2Type) ... → DataTypeName Param1 Param2 ...
  Cons2 : (Cons2Arg1 : Cons2Arg1Type) ... → DataTypeName Param1 Param2 ...
  ...
  ConsN : (ConsNArg1 : ConsNArg1Type) ... → DataTypeName Param1 Param2 ...
```
用有限数据类型，Π-类型和 Σ-类型重新编码，得到：
``` Agda
DataTypeName : (Param1 : Param1Type) (Param2 : Param2Type) ... → Set whatever
DataTypeName Param1 Param2 ... = Σ FiniteTypeWithNElements choice where
  choice : FiniteTypeWithNElements → Set whatever
  choice element1 = Σ Cons1Arg1Type (λ Cons1Arg1 → Σ Cons1Arg2Type (λ Cons1Arg2 → ...))
  choice element2 = Σ Cons2Arg1Type (λ Cons2Arg1 → ...)
  ...
  choice elementN = Σ ConsNArg1Type (λ ConsNArg1 → ...)
```
比如，类型 `Di` 就可以这样定义：
``` Agda
    Di′ : ∀ {α β} (A : Set α) (B : Set β) → Set (α ⊔ β)
    Di′ {α} {β} A B = Σ Bool choice where
      choice : Bool → Set (α ⊔ β)
      choice true  = A × ¬ B
      choice false = ¬ A × B
```

## 带索引的数据类型
正在撰写。TODO。总体的想法：把它们作为参数，然后在里面加上等价性的证明。

## 递归数据类型
正在撰写。TODO。总体的想法：W-类型和 μ。

### 库里悖论
Negative occurrences 使得系统不一致。

把下面的代码拷贝到某个文件，然后类型检查：
``` Agda
{-# OPTIONS --no-positivity-check #-}
module CurrysParadox where
  data CS (C : Set) : Set where
    cs : (CS C → C) → CS C

  paradox : ∀ {C} → CS C → C
  paradox (cs b) = b (cs b)

  loop : ∀ {C} → C
  loop = paradox (cs paradox)

  contr : ⊥
  contr = loop
```

## Universes 和 impredicativity
正在撰写。TODO。罗素悖论。赫肯斯悖论。
``` Agda
{- end of ThrowAwayTheory -}
```
