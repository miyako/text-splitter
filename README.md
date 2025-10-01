![version](https://img.shields.io/badge/version-20%2B-E23089)
![platform](https://img.shields.io/static/v1?label=platform&message=mac-intel%20|%20mac-arm%20|%20win-64&color=blue)
[![license](https://img.shields.io/github/license/miyako/text-splitter)](LICENSE)
![downloads](https://img.shields.io/github/downloads/miyako/text-splitter/total)

# text-splitter
split text into semantic chunks, up to a desired chunk size (namespace: `text_splitter`)

### usage

```4d
$file:=File("/DATA/sample.txt")

var $text_splitter : cs.text_splitter
$text_splitter:=cs.text_splitter.new()
/*
	file can be file, text, BLOB
	capacity can be a size (1000) or range ("500..1500")
	overlap must be smaller than size
	trim: default is true
	markdown: default is false
	tiktoken: default is false
*/
$results:=$text_splitter.chunk({file: $file; capacity: "100..200"; overlap: 10})
```

* with callback function

```4d
$text_splitter.chunk({file: $file; capacity: "100..200"; overlap: 50}; Formula(onResponse))
```

## acknowledgements

[text-splitter](https://crates.io/crates/text-splitter)


```json
[
	{
		"text": "Exploring 4th Dimension: A Pioneer in Database Software Development",
		"start": 0,
		"end": 67
	},
	{
		"text": "4th Dimension, often abbreviated as 4D, is a powerful and mature software development platform that has",
		"start": 69,
		"end": 172
	},
	{
		"text": "that has played a significant role in the evolution of database and application development since the 1980s.",
		"start": 164,
		"end": 272
	},
	{
		"text": "Originally launched in 1984 by Laurent Ribardière and later developed and distributed by the French company",
		"start": 273,
		"end": 381
	},
	{
		"text": "company 4D SAS, 4D is renowned for its integrated environment that combines a relational database engine with a programming language and graphical user interface tools.",
		"start": 374,
		"end": 542
	},
	{
		"text": "At its core, 4D is designed to allow developers to create customized business solutions rapidly and efficiently.",
		"start": 543,
		"end": 655
	},
	{
		"text": "What makes 4D unique is its all-in-one approach.",
		"start": 657,
		"end": 705
	},
	{
		"text": "Unlike many modern development stacks that require external tools and complex integrations, 4D delivers",
		"start": 706,
		"end": 809
	},
	{
		"text": "delivers a unified development experience where the database, programming logic, user interface, and server capabilities coexist within a single framework.",
		"start": 801,
		"end": 956
	},
	{
		"text": "This reduces the learning curve for new developers and accelerates the prototyping and deployment process.",
		"start": 957,
		"end": 1063
	},
	{
		"text": "The 4D environment includes its own programming language—4D Language—which is both powerful and accessible",
		"start": 1064,
		"end": 1174
	},
	{
		"text": "accessible, offering support for object-oriented programming, SQL commands, and modern coding practices.",
		"start": 1164,
		"end": 1268
	},
	{
		"text": "Over the decades, 4D has adapted to technological changes and maintained relevance by incorporating modern",
		"start": 1270,
		"end": 1376
	},
	{
		"text": "modern features such as support for REST APIs, JSON, ORDA (Object Relational Data Access), and mobile development integrations.",
		"start": 1370,
		"end": 1497
	},
	{
		"text": "This forward-thinking approach allows legacy applications to be maintained while also giving developers the tools they need to build cutting-edge web and cloud-based applications.",
		"start": 1498,
		"end": 1677
	},
	{
		"text": "Additionally, 4D Server enables scalable deployment options, allowing businesses to host multi-user applications on networks or in cloud environments with ease.",
		"start": 1678,
		"end": 1838
	},
	{
		"text": "4D is especially popular among small to medium-sized businesses, software consultants, and in-house IT departments looking for flexibility and speed without sacrificing power.",
		"start": 1840,
		"end": 2015
	},
	{
		"text": "Its cross-platform capabilities ensure that applications can run on both macOS and Windows systems seamlessly.",
		"start": 2016,
		"end": 2126
	},
	{
		"text": "Moreover, 4D’s built-in security features, backup management, and database integrity tools make it a",
		"start": 2127,
		"end": 2229
	},
	{
		"text": "make it a dependable choice for mission-critical applications across industries such as healthcare, finance, logistics, and education.",
		"start": 2220,
		"end": 2354
	},
	{
		"text": "Another strength of 4D is its dedicated community and comprehensive documentation.",
		"start": 2356,
		"end": 2438
	},
	{
		"text": "The company behind 4D provides frequent updates, professional support services, and active forums where developers can share knowledge, solve problems, and collaborate on best practices.",
		"start": 2439,
		"end": 2625
	},
	{
		"text": "4D World Tour events and technical blogs further enrich the ecosystem, helping new and experienced users stay current with platform advancements.",
		"start": 2626,
		"end": 2771
	},
	{
		"text": "In summary, 4th Dimension stands as a testament to the enduring value of integrated development environments.",
		"start": 2773,
		"end": 2882
	},
	{
		"text": "While it may not have the widespread name recognition of newer tools, it offers a mature, stable, and feature-rich environment for building custom applications tailored to business needs.",
		"start": 2883,
		"end": 3070
	},
	{
		"text": "For developers who value productivity, reliability, and deep control over both data and interface, 4D remains a compelling option in the modern software landscape.",
		"start": 3071,
		"end": 3234
	}
]
```
