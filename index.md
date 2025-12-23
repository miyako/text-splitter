---
layout: default
---

![version](https://img.shields.io/badge/version-20%2B-E23089)
![platform](https://img.shields.io/static/v1?label=platform&message=mac-intel%20|%20mac-arm%20|%20win-64&color=blue)
[![license](https://img.shields.io/github/license/miyako/text-splitter)](LICENSE)
![downloads](https://img.shields.io/github/downloads/miyako/text-splitter/total)

# Tool to split text into semantic chunks 

#### Abstract

Using [text-splitter](https://crates.io/crates/text-splitter) crate.

#### Usage

Instantiate `cs.text_splitter.text_splitter`  with no parameters:

```4d
var $text_splitter : cs.text_splitter.text_splitter
$text_splitter:=cs.text_splitter.text_splitter.new()   
```

there are 2 ways to invoke `.chunk()`; synchronous and asynchronous.

**synchronous**: pass a single parameter and receive a collection of results in return.

```4d
$results:=$text_splitter.chunk({file: $file; capacity: "100..200"; overlap: 10})
```

you can pass a single object or a collection of objects in a single call.

**asynchronous**: pass a second formula parameter. an empty collection is returned at this point.

the formula should have the following signature:

```4d
#DECLARE($worker : 4D.SystemWorker; $params : Object)

var $text : Text
$text:=$worker.response
```

> [!TIP]
> whatever value you pass in `data` is returned in `context`.

```4d
$text_splitter.chunk({file: $file.getContent(); data: $file}; Formula(onResponse))
```
```4d
#DECLARE($worker : 4D.SystemWorker; $params : Object)

var $text : Text
$text:=$worker.response
$file:=$params.context
```

use `$params.context` to match input against output.

|property|type|description|
|-|-|-|
|`file`|`4D.File` `4D.Blob` `Text`|input|
|`capacity`|`Integer` `Text`|can be a size (`1000`) or range (`"500..1500"`)|
|`overlap`|`Integer`|should be smaller than `capacity`|
|`trim`|`Boolean`|default: `False`|
|`markdown`|`Boolean`|default: `False`|
|`tiktoken`|`Boolean`|default: `False`|
|`compact`|`Boolean`|output without inclde text. default: `False`|
|`batch`|`Boolean`|input is JSON collection of text. default: `False`|

> [!NOTE]
> Results are returned as collection of JSON text, not collection of collections. Use `JSON Parse` if necessary.
