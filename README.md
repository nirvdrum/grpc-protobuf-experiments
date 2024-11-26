# Overview

This repository demonstrates a memory leak we've encountered using the
_google-protobuf_ gem. To help isolate the cause of the leak, this repository
contains a few scripts that vary in their Protobuf definitions.

# Protobuf vs Protoboeuf

It wasn't clear when this investigation was started what the nature of the leak
may be, if it existed at all. E.g., it could have been due to the growth of an
array over time or something along those lines where the memory growth was
observable but the memory was not truly leaked.

To help determine whether this memory growth was due to a misunderstanding of
Protobuf semantics or whether it was due an implementation issue in the
_google-protobuf_ gem, we've also included a version that uses the Protoboeuf
library. Protoboeuf is an implementation of Protocol Buffers in pure Ruby.

# Setup

To run the scripts, you'll need to install the dependencies:

```sh
bundle install
```

Then you'll need to generate the Ruby code from the Protobuf definitions:

```sh
bundle exec rake
```

# Running the Scripts

To run the scripts, you can use:

```sh
bundle exec ruby leak-bigtable.rb
bundle exec ruby leak-bigtable-extracted.rb
bundle exec ruby leak-simple.rb
```

By default, only the memory growth of the primary loop is printed at the end of
the execution. If you'd like to see the memory usage at each iteration, you can
set the `VERBOSE` environment variable:

```sh
VERBOSE=true bundle exec ruby leak-bigtable.rb
```

By default, the _google-protobuf_ gem is used. If you'd like to see the results
using Protoboeuf, you can set the `USE_PROTOBOEUF` environment variable:

```sh
USE_PROTOBOEUF=true bundle exec ruby leak-simple.rb
```

## leak-bigtable.rb

This script uses the Protobuf definitions from the official _google-cloud-bigtable_
gem. We isolated the memory leak to the creation of nested `RowFilter::Chain`
objects. If one of the parent filters is retained, each link in the chain will
grow unbounded even if the the child otherwise becomes inaccessible.


## leak-bigtable-extracted.rb

This script uses an extracted set of Protobuf definitions from Bigtable. It is
functionally similar to _leak-bigtable.rb_ but uses a smaller set of definitions
to help isolate the issue of concern.

## leak-simple.rb

This script takes what we learned by investing Bigtable and simplifies to a
small message with a recursive definition. It then measures the memory growth
over time. By demonstrating the issue without Bigtable or gRPC, we can focus
on the _google-protobuf_ gem without external factors influencing the results.
