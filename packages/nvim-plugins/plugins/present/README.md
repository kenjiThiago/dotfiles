# Presentation

This is a plugin for presenting markdown files.

# Features

Can execute code in lua blocks, when you have them in a slide

```lua
print("Hello World", 10)
```

# Features

Can execute code in lua blocks, when you have them in a slide

```js
console.log({ myfield: true, other: false })
```

# Features

Can execute code in lua blocks, when you have them in a slide

```py
a = [
    {0, 1, 2},
    {0, 1, 2}
]

print(a)
```

# Usage

```lua
require("present").start_presentation {}
```

Use `n`, and `p` to navigate markdown slides
Use `q` to exit the presentation or exit the codeblock execution

# Description

Colocar alguma coisa
